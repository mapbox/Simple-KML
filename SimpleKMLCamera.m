//
//  SimpleKMLCamera.m
//
//  Created by Andrea Cremaschi on 5/10/12
//  Copyright 2012, redcluster.eu
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//  
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//      * Neither the names of redcluster, nor the names of its contributors may be used to endorse or
//        promote products derived from this software without specific prior
//        written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  http://code.google.com/apis/kml/documentation/kmlreference.html#photooverlay
//

#import "SimpleKMLCamera.h"

NSString *kKMLAltitudeModeRelativeToGround = @"relativeToGround";
NSString *kKMLAltitudeModeClampToGround = @"clampToGround";
NSString *kKMLAltitudeModeAbsolute = @"absolute";

@implementation SimpleKMLCamera
@synthesize coordinate;
@synthesize altitude;
@synthesize heading;
@synthesize tilt;
@synthesize roll;
@synthesize altitudeMode;


- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    
    if (self != nil)
    {        
        NSArray *requiredKeys = [NSArray arrayWithObjects: @"longitude", @"latitude", @"altitude", @"heading", @"tilt", @"roll", @"altitudeMode", nil];
        
        NSMutableDictionary *parsedElements = [NSMutableDictionary dictionary];
        for (CXMLNode *grandchild in [node children])
        {
            if ([grandchild kind] == CXMLElementKind)
            {
                if ([requiredKeys containsObject: grandchild.name])
                    [parsedElements setObject: grandchild forKey: grandchild.name];

            }
        }
        
        NSMutableArray *intermediate = [NSMutableArray arrayWithArray: requiredKeys];
        [intermediate removeObjectsInArray: parsedElements.allKeys];
        NSUInteger difference = [intermediate count];
        
        if (difference != 0)
        {
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat: @"Improperly formed KML (%@ are required for Camera)", requiredKeys]
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
            
        coordinate.longitude    = [[[parsedElements objectForKey: @"longitude"] stringValue] doubleValue];
        coordinate.latitude    = [[[parsedElements objectForKey: @"latitude"] stringValue] doubleValue];
        altitude     = [[[parsedElements objectForKey: @"altitude"] stringValue] doubleValue];
        heading     = [[[parsedElements objectForKey: @"heading"] stringValue] doubleValue];
        tilt        = [[[parsedElements objectForKey: @"tilt"] stringValue] doubleValue];
        roll     = [[[parsedElements objectForKey: @"roll"] stringValue] doubleValue];
        altitudeMode     = [[parsedElements objectForKey: @"altitudeMode"] stringValue];
            
        if (coordinate.longitude < -180  || coordinate.longitude > 180  ||
            coordinate.latitude < -90  || coordinate.latitude > 90  ||
            roll < -180  || roll > 180  ||
            tilt < 0 || tilt > 180 ||
            ![[NSArray arrayWithObjects: kKMLAltitudeModeAbsolute, kKMLAltitudeModeClampToGround, kKMLAltitudeModeRelativeToGround, nil] containsObject: altitudeMode])
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (out-of-range longitude, latitude, altitude, heading, tilt, roll or altitudeMode specified for Camera element)" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
            
        
    }
    
    return self;
}



@end

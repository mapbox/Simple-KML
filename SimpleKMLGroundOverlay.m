//
//  SimpleKMLGroundOverlay.m
//
//  Created by Justin R. Miller on 7/22/11
//  Copyright 2011, Development Seed, Inc.
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
//      * Neither the names of Code Sorcery Workshop, LLC or Development Seed,
//        Inc., nor the names of its contributors may be used to endorse or
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

#import "SimpleKMLGroundOverlay.h"

@implementation SimpleKMLGroundOverlay

@synthesize north;
@synthesize south;
@synthesize east;
@synthesize west;
@synthesize rotation;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        for (CXMLNode *child in [node children])
        {
            if ([[child name] isEqualToString:@"LatLonBox"])
            {
                CXMLNode *northNode    = nil;
                CXMLNode *southNode    = nil;
                CXMLNode *eastNode     = nil;
                CXMLNode *westNode     = nil;
                CXMLNode *rotationNode = nil;
                
                for (CXMLNode *grandchild in [child children])
                {
                    if ([grandchild kind] == CXMLElementKind)
                    {
                        if ([[grandchild name] isEqualToString:@"north"])
                            northNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"south"])
                            southNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"east"])
                            eastNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"west"])
                            westNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"rotation"])
                            rotationNode = grandchild;
                    }
                }
                
                if ( ! (northNode && southNode && eastNode && westNode))
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (north, south, east, and west are required for GroundOverlay LatLonBox)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                
                north    = [[northNode    stringValue] doubleValue];
                south    = [[southNode    stringValue] doubleValue];
                east     = [[eastNode     stringValue] doubleValue];
                west     = [[westNode     stringValue] doubleValue];

                rotation = (rotationNode ? [[rotationNode stringValue] floatValue] : 0.0);
                
                if (north < -90  || north > 90  ||
                    south < -90  || south > 90  ||
                    east  < -180 || east  > 180 ||
                    west  < -180 || west  > 180)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (out-of-range north, south, east, or west specified for GroundOverlay LatLonBox)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                    
                if (rotation < -180 || rotation > 180)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (out-of-range rotation specified for GroundOverlay LatLonBox)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
            }
        }
    }
    
    return self;
}

@end
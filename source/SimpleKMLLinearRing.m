//
//  SimpleKMLLinearRing.m
//
//  Created by Justin R. Miller on 7/6/10.
//  Copyright 2010, Code Sorcery Workshop, LLC and Development Seed, Inc.
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

#import "SimpleKMLLinearRing.h"
#import <CoreLocation/CoreLocation.h>

@implementation SimpleKMLLinearRing

@synthesize coordinates;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        coordinates = nil;
        
        for (CXMLNode *child in [node children])
        {
            if ([[child name] isEqualToString:@"coordinates"])
            {
                NSMutableArray *parsedCoordinates = [NSMutableArray array];
                
                NSArray *coordinateStrings = [[child stringValue] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                for (__strong NSString *coordinateString in coordinateStrings)
                {
                    coordinateString = [coordinateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                    if ([coordinateString length])
                    {
                        // coordinates should not have whitespace
                        //
                        if ([[coordinateString componentsSeparatedByString:@" "] count] > 1)
                        {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (LinearRing coordinates have whitespace)" 
                                                                                 forKey:NSLocalizedFailureReasonErrorKey];
                            
                            if (error)
                                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                            
                            return nil;
                        }
                        
                        NSArray *parts = [coordinateString componentsSeparatedByString:@","];
                        
                        // there should be longitude, latitude, and optionally, altitude
                        //
                        if ([parts count] < 2 || [parts count] > 3)
                        {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Invalid number of LinearRing coordinates)" 
                                                                                 forKey:NSLocalizedFailureReasonErrorKey];
                            
                            if (error)
                                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                            
                            return nil;
                        }
                        
                        double longitude = [[parts objectAtIndex:0] doubleValue];
                        double latitude  = [[parts objectAtIndex:1] doubleValue];
                        
                        // there should be valid values for latitude & longitude
                        //
                        if (longitude < -180 || longitude > 180 || latitude < -90 || latitude > 90)
                        {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Invalid LinearRing coordinates values)" 
                                                                                 forKey:NSLocalizedFailureReasonErrorKey];
                            
                            if (error)
                                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                            
                            return nil;
                        }
                        
                        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                        
                        [parsedCoordinates addObject:coordinate]; 
                    }
                }
                
                coordinates = [NSArray arrayWithArray:parsedCoordinates];
                
                // there should be four or more coordinates
                //
                if ([coordinates count] < 4)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (LinearRing has less than four coordinates)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
            }
        }
        
        if ( ! coordinates)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (LinearRing has no coordinates)" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
        
        // the first and last coordinate should be the same
        //
        if (((CLLocation *)[coordinates objectAtIndex:0]).coordinate.latitude  != ((CLLocation *)[coordinates lastObject]).coordinate.latitude ||
            ((CLLocation *)[coordinates objectAtIndex:0]).coordinate.longitude != ((CLLocation *)[coordinates lastObject]).coordinate.longitude)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (LinearRing does not form complete path)" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
    }
    
    return self;
}

@end
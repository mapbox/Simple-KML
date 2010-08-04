//
//  SimpleKMLPolygon.m
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

#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"

@implementation SimpleKMLPolygon

@synthesize outerBoundary;
@synthesize firstInnerBoundary;
@synthesize innerBoundaries;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        outerBoundary      = nil;
        firstInnerBoundary = nil;
        innerBoundaries    = nil;
        
        NSMutableArray *parsedInnerBoundaries = [NSMutableArray array];
        
        for (CXMLNode *child in [node children])
        {
            if ([[child name] isEqualToString:@"outerBoundaryIs"])
            {
                NSArray *boundaryChildren = [child children];
                
                // there should only be one child of this boundary
                //
                if ([boundaryChildren count] != 3)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Invalid number of LinearRings in Polygon boundary)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                
                outerBoundary = [[SimpleKMLLinearRing alloc] initWithXMLNode:[boundaryChildren objectAtIndex:1] sourceURL:sourceURL error:NULL];
            }
            else if ([[child name] isEqualToString:@"innerBoundaryIs"])
            {
                NSArray *boundaryChildren = [child children];
                
                // there should only be one child of this boundary
                //
                if ([boundaryChildren count] != 3)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Invalid number of LinearRings in Polygon boundary)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                
                SimpleKMLLinearRing *thisBoundary = [[[SimpleKMLLinearRing alloc] initWithXMLNode:[boundaryChildren objectAtIndex:1] sourceURL:sourceURL error:NULL] autorelease];
                
                if ( ! firstInnerBoundary)
                    firstInnerBoundary = thisBoundary;
                
                [parsedInnerBoundaries addObject:thisBoundary];
            }
        }
        
        innerBoundaries = [[NSArray arrayWithArray:parsedInnerBoundaries] retain];

        // there should be one outer boundary
        //
        if ( ! outerBoundary)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Missing outer boundary in Polygon)" 
                                                                 forKey:NSLocalizedFailureReasonErrorKey];
            
            if (error)
                *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
            
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [outerBoundary release];
    [firstInnerBoundary release];
    [innerBoundaries release];
    
    [super dealloc];
}

@end
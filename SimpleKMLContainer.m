//
//  SimpleKMLContainer.m
//
//  Created by Justin R. Miller on 6/29/10.
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

#import "SimpleKMLContainer.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLDocument.h"

@implementation SimpleKMLContainer

@synthesize features;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        NSMutableArray *featuresArray = [NSMutableArray array];
        
        for (CXMLNode *child in [node children])
        {
            Class featureClass = NSClassFromString([NSString stringWithFormat:@"SimpleKML%@", [child name]]);
            
            if (featureClass)
            {
                NSError *parseError = nil;
                
                id feature = [[[featureClass alloc] initWithXMLNode:child sourceURL:sourceURL error:&parseError] autorelease];
                
                // only add the feature if it's one we know how to handle
                //
                if ( ! parseError && [feature isKindOfClass:[SimpleKMLFeature class]])
                {
                    ((SimpleKMLFeature *)feature).container = self;
                    
                    if ([self isMemberOfClass:[SimpleKMLDocument class]])
                        ((SimpleKMLFeature *)feature).document = (SimpleKMLDocument *)self;
                    
                    [featuresArray addObject:feature];
                }
            }
        }
        
        features = [[NSArray arrayWithArray:featuresArray] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [features release];
    
    [super dealloc];
}

@end
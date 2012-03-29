//
//  SimpleKMLGeometry.h
//
//  Created by Andrew Griffiths on 27/3/2012.
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
//  http://developers.google.com/kml/documentation/kmlreference#multigeometry
// 

#import "SimpleKMLMultiGeometry.h"

@implementation SimpleKMLMultiGeometry
@synthesize geometry=_geometry;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self)
    {
        geometry = nil;
        
        for (CXMLNode *child in [node children])
        {
            // we only support parsing one geometry for now so skip if we have one
            if ( ! self.geometry)
            {
                // try to find class to parse the contained geometry element
                NSString* className = [NSString stringWithFormat:@"SimpleKML%@", [child name]];
                Class geometryClass = NSClassFromString(className);
                
                if (geometryClass)
                {
                    NSError* error = nil;
                    id thisGeometry = [[[geometryClass alloc] initWithXMLNode:child sourceURL:sourceURL error:&error] autorelease];
                    
                    if (!error && [thisGeometry isKindOfClass:[SimpleKMLGeometry class]]) {
                        geometry = [thisGeometry retain]; // found a geometry element we can use, store it
                    }
                }
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [geometry release];
    [super dealloc];
}


-(SimpleKMLGeometry*) geometry {
    return geometry;
}


@end

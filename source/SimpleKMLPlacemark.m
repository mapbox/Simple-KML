//
//  SimpleKMLPlacemark.m
//
//  Created by Justin R. Miller on 6/29/10.
//  Copyright MapBox 2010-2013.
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
//      * Neither the name of MapBox, nor the names of its contributors may be
//        used to endorse or promote products derived from this software
//        without specific prior written permission.
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

#import "SimpleKMLPlacemark.h"
#import "SimpleKMLGeometry.h"
#import "SimpleKMLMultiGeometry.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLineString.h"
#import "SimpleKMLLinearRing.h"

@implementation SimpleKMLPlacemark

@synthesize geometry;
@synthesize point;
@synthesize polygon;
@synthesize lineString;
@synthesize linearRing;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    if (self != nil)
    {
        geometry = nil;
        
        for (CXMLNode *child in [node children])
        {
            // there should only be zero or one geometries
            //
            if ( ! geometry)
            {
                Class geometryClass = NSClassFromString([NSString stringWithFormat:@"SimpleKML%@", [child name]]);
                
                if (geometryClass)
                {
                    id thisGeometry = [[geometryClass alloc] initWithXMLNode:child sourceURL:sourceURL error:NULL];
                    
                    if (thisGeometry && [thisGeometry isKindOfClass:[SimpleKMLGeometry class]])
                        geometry = thisGeometry;
                }
            }
        }
    }
    
    return self;
}

#pragma mark -

- (SimpleKMLGeometry *)firstGeometry
{
    if (self.geometry && [self.geometry isKindOfClass:[SimpleKMLMultiGeometry class]])
        return ((SimpleKMLMultiGeometry *)self.geometry).firstGeometry;
    
    else if (self.geometry && [self.geometry isKindOfClass:[SimpleKMLGeometry class]])
        return self.geometry;
    
    return nil;
}

- (SimpleKMLPoint *)point
{
    if (self.firstGeometry && [self.firstGeometry isKindOfClass:[SimpleKMLPoint class]])
        return (SimpleKMLPoint *)self.firstGeometry;
    
    return nil;
}

- (SimpleKMLPolygon *)polygon
{
    if (self.firstGeometry && [self.firstGeometry isKindOfClass:[SimpleKMLPolygon class]])
        return (SimpleKMLPolygon *)self.firstGeometry;
    
    return nil;
}

- (SimpleKMLLineString *)lineString
{
    if (self.firstGeometry && [self.firstGeometry isKindOfClass:[SimpleKMLLineString class]])
        return (SimpleKMLLineString *)self.firstGeometry;
    
    return nil;
}

- (SimpleKMLLinearRing *)linearRing
{
    if (self.firstGeometry && [self.firstGeometry isKindOfClass:[SimpleKMLLinearRing class]])
        return (SimpleKMLLinearRing *)self.firstGeometry;
    
    return nil;
}

@end
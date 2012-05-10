//
//  SimpleKMLPhotoOverlay.m
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

#import "SimpleKMLPhotoOverlay.h"

NSString *kKMLPhotoOverlayShapeRectangle = @"rectangle";
NSString *kKMLPhotoOverlayShapeCylinder = @"cylinder";
NSString *kKMLPhotoOverlayShapeSphere = @"sphere";


@implementation SimpleKMLPhotoOverlay
@synthesize rotation;
@synthesize viewVolume;
@synthesize imagePyramid;
@synthesize shape;
@synthesize coordinates;


- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
    
    if (self != nil)
    {
        imagePyramid.isValid = NO;
        imagePyramid.tileSize = 0;
        imagePyramid.maxWidth = 0;
        imagePyramid.maxHeight = 0;
        imagePyramid.gridOrigin = 0;
        imagePyramid.near=0;
        shape = kKMLPhotoOverlayShapeRectangle;
        rotation = 0;
        
        for (CXMLNode *child in [node children])
        {
            if ([[child name] isEqualToString:@"ViewVolume"])
            {
                CXMLNode *leftFovNode    = nil;
                CXMLNode *rightFovNode    = nil;
                CXMLNode *bottomFovNode     = nil;
                CXMLNode *topFovNode     = nil;
                CXMLNode *nearNode = nil;
                
                for (CXMLNode *grandchild in [child children])
                {
                    if ([grandchild kind] == CXMLElementKind)
                    {
                        if ([[grandchild name] isEqualToString:@"leftFov"])
                            leftFovNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"rightFov"])
                            rightFovNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"bottomFov"])
                            bottomFovNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"topFov"])
                            topFovNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"near"])
                            nearNode = grandchild;
                    }
                }
                
                if ( ! (leftFovNode && rightFovNode && topFovNode && bottomFovNode && nearNode))
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (leftFov, rightFov, bottomFov, topFov, near are required for PhotoOverlay ViewVolume)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                
                viewVolume.leftFov    = [[leftFovNode    stringValue] doubleValue];
                viewVolume.rightFov    = [[rightFovNode    stringValue] doubleValue];
                viewVolume.bottomFov     = [[bottomFovNode     stringValue] doubleValue];
                viewVolume.topFov     = [[topFovNode     stringValue] doubleValue];

                viewVolume.near     = [[nearNode     stringValue] doubleValue];
                                
                if (viewVolume.leftFov < -180  || viewVolume.leftFov > 180  ||
                    viewVolume.rightFov < -180  || viewVolume.rightFov > 180  ||
                    viewVolume.bottomFov < -90  || viewVolume.bottomFov > 90  ||
                    viewVolume.topFov < -90  || viewVolume.topFov > 90)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (out-of-range leftFov, rightFov, bottomFov, or topFov specified for PhotoOverlay ViewVolume)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                }
                
            }

            else if ([[child name] isEqualToString:@"rotation"])
            {
                rotation = child.stringValue.doubleValue;                
            }

            else if ([[child name] isEqualToString:@"Point"])
            {
                CXMLNode *coordinatesNode    = [[child children] lastObject];

                if ([[coordinatesNode name] isEqualToString:@"coordinates"])
                {
                    NSMutableArray *parsedCoordinates = [NSMutableArray array];
                    
                    NSArray *coordinateStrings = [[coordinatesNode stringValue] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    for (__strong NSString *coordinateString in coordinateStrings)
                    {
                        coordinateString = [coordinateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([coordinateString length])
                        {
                            // coordinates should not have whitespace
                            //
                            if ([[coordinateString componentsSeparatedByString:@" "] count] > 1)
                            {
                                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (PhotoOverlay coordinates have whitespace)" 
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
                                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Invalid number of PhotoOverlay coordinates)" 
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
                                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (Invalid PhotoOverlay coordinates values)" 
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
                    
                    // there should be two or more coordinates
                    //
                    if ([coordinates count] < 2)
                    {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (PhotoOverlay has less than two coordinates)" 
                                                                             forKey:NSLocalizedFailureReasonErrorKey];
                        
                        if (error)
                            *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                        
                        return nil;
                    }
                }
            }

            else if ([[child name] isEqualToString:@"ImagePyramid"])
            {
                CXMLNode *tileSizeNode    = nil;
                CXMLNode *maxWidthNode    = nil;
                CXMLNode *maxHeightNode     = nil;
                CXMLNode *gridOriginNode     = nil;

                for (CXMLNode *grandchild in [child children])
                {
                    if ([grandchild kind] == CXMLElementKind)
                    {
                        if ([[grandchild name] isEqualToString:@"tileSize"])
                            tileSizeNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"maxWidth"])
                            maxWidthNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"maxHeight"])
                            maxHeightNode = grandchild;
                        
                        else if ([[grandchild name] isEqualToString:@"gridOrigin"])
                            gridOriginNode = grandchild;
                        
                    }
                }
                
                if ( ! (tileSizeNode && maxWidthNode && maxHeightNode && gridOriginNode))
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (tileSize, maxWIdth, maxHeight, gridOrigin are required for PhotoOverlay ImagePyramid)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;

                }
                
                imagePyramid.tileSize    = tileSizeNode.stringValue.integerValue;
                imagePyramid.maxWidth    = maxWidthNode.stringValue.integerValue;
                imagePyramid.maxHeight = maxHeightNode.stringValue.integerValue;
                imagePyramid.gridOrigin     = gridOriginNode.stringValue.integerValue;
                                
                NSUInteger num = imagePyramid.tileSize;
                if((num != 1) && (num & (num - 1))) 
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Improperly formed KML (tileSize specified for PhotoOverlay ImagePyramid is not power-of-2)" 
                                                                         forKey:NSLocalizedFailureReasonErrorKey];
                    
                    if (error)
                        *error = [NSError errorWithDomain:SimpleKMLErrorDomain code:SimpleKMLParseError userInfo:userInfo];
                    
                    return nil;
                    
                }
                // TODO: check if gridOrigin == 0 or == 1
                imagePyramid.isValid = YES;

            }

            else if ([[child name] isEqualToString:@"shape"])
            {
                NSArray * allowedValues = [NSArray arrayWithObjects: kKMLPhotoOverlayShapeSphere,
                                           kKMLPhotoOverlayShapeRectangle, 
                                           kKMLPhotoOverlayShapeCylinder,
                                           nil];
                shape = child.stringValue;
                if (![allowedValues containsObject: shape])
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Invalid value for shape value"
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

//
//  SimpleKMLPhotoOverlay.h
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

#import "SimpleKMLOverlay.h"
#import <CoreLocation/CoreLocation.h>

typedef struct
{
    double leftFov;  // Angle, in degrees, between the camera's viewing direction and the left side of the view volume.
    double rightFov;   // Angle, in degrees, between the camera's viewing direction and the right side of the view volume.
    double bottomFov;  // Angle, in degrees, between the camera's viewing direction and the bottom side of the view volume.
    double topFov; //Angle, in degrees, between the camera's viewing direction and the top side of the view volume.
    double near;    // Measurement in meters along the viewing direction from the camera viewpoint to the PhotoOverlay shape.
} KMLViewVolume;

typedef enum
{
    lowerLeft = 0,
    upperLeft = 1
} KMLGridOrigin;

typedef struct
{
    bool isValid;
    NSUInteger tileSize;  // Angle, in degrees, between the camera's viewing direction and the left side of the view volume.
    NSUInteger maxWidth;   // Angle, in degrees, between the camera's viewing direction and the right side of the view volume.
    NSUInteger maxHeight;  // Angle, in degrees, between the camera's viewing direction and the bottom side of the view volume.
    KMLGridOrigin gridOrigin; //Angle, in degrees, between the camera's viewing direction and the top side of the view volume.
    double near;    // Measurement in meters along the viewing direction from the camera viewpoint to the PhotoOverlay shape.
} KMLImagePyramid;

extern NSString *kKMLPhotoOverlayShapeRectangle;
extern NSString *kKMLPhotoOverlayShapeCylinder;
extern NSString *kKMLPhotoOverlayShapeSphere;

// Interface
@interface SimpleKMLPhotoOverlay : SimpleKMLOverlay

@property (nonatomic, readonly) double rotation;
@property (nonatomic, readonly) KMLViewVolume viewVolume;
@property (nonatomic, readonly) KMLImagePyramid imagePyramid;
@property (nonatomic, assign, readonly) NSArray* coordinates;
@property (nonatomic, strong, readonly) NSString *shape;

@end

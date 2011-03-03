//
//  Simple_KML_Point_Placemark.h
//  Simple KML Example
//
//  Created by David Stuart on 3/3/11.
//  Copyright 2011 US Army Corps of Engineers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>

@class SimpleKMLStyleSelector;

@interface Simple_KML_Point_Placemark : NSObject <MKAnnotation> {
    float latitude;
    float longitude;
    UIImage *icon;
}

@property(nonatomic) float latitude;
@property(nonatomic) float longitude;
@property(nonatomic, retain) UIImage *icon;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end

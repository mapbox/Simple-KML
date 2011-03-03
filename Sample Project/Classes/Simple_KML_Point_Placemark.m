//
//  Simple_KML_Point_Placemark.m
//  Simple KML Example
//
//  Created by David Stuart on 3/3/11.
//  Copyright 2011 US Army Corps of Engineers. All rights reserved.
//

#import "Simple_KML_Point_Placemark.h"


@implementation Simple_KML_Point_Placemark

@synthesize latitude, longitude, icon, coordinate;

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord = {self.latitude, self.longitude};
    return coord;
}

@end

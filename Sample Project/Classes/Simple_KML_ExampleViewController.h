//
//  Simple_KML_ExampleViewController.h
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright Code Sorcery Workshop 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKMapView;
@class SimpleKML;
@class SimpleKMLFeature;
@class SimpleKMLStyle;

@interface Simple_KML_ExampleViewController : UIViewController
{
    IBOutlet MKMapView *mapView;
    SimpleKML *kml;
    int depth;
}

-(void) recursivelyDrawFeature:(SimpleKMLFeature*)parentFeature;
-(SimpleKMLStyle*) getStyleforFeature:(SimpleKMLFeature*)feature;

@end
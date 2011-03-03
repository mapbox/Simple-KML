//
//  Simple_KML_ExampleViewController.m
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright Code Sorcery Workshop 2010. All rights reserved.
//

#import "Simple_KML_ExampleViewController.h"

#import <MapKit/MapKit.h>

#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"
#import "SimpleKMLFolder.h"
#import "SimpleKMLStyleSelector.h"
#import "SimpleKMLStyleMap.h"
#import "SimpleKMLIconStyle.h"
#import "Simple_KML_Point_Placemark.h"

@implementation Simple_KML_ExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // grab the example KML file (which we know will have no errors, but you should ordinarily check)
    //
    // Uncomment the one you want to look at
    //
    //kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"kml"] error:NULL];
    kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChineseAviation" ofType:@"kmz"] error:NULL];
    //kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NID_Demo" ofType:@"kmz"] error:NULL];
    
    // look for a document feature in it per the KML spec
    //
    if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]])
    {
        // see if the document has features of its own
        //
        SimpleKMLDocument *doc = (SimpleKMLDocument*)kml.feature;
        
        [self recursivelyDrawFeature:doc];
    }
}

-(void) recursivelyDrawFeature:(SimpleKMLFeature*)parentFeature
{
    for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)parentFeature).features)
    {
        // see if this is a folder, then draw contents
        //
        if ([feature isKindOfClass:[SimpleKMLFolder class]]) {
            [self recursivelyDrawFeature:feature];
        }
    
        // see if we have any placemark features with a point
        //
        if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).point)
        {
            SimpleKMLPoint *point = ((SimpleKMLPlacemark *)feature).point;
            SimpleKMLStyle *style = [self getStyleforFeature:feature];
        
            Simple_KML_Point_Placemark *placemark = [[[Simple_KML_Point_Placemark alloc] init] autorelease];
        
            placemark.latitude = point.coordinate.latitude;
            placemark.longitude = point.coordinate.longitude;
            placemark.icon = style.iconStyle.icon;
        
            [mapView addAnnotation:placemark];
        
        }
    
        // otherwise, see if we have any placemark features with a polygon
        //
        else if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).polygon)
        {
            SimpleKMLPolygon *polygon = (SimpleKMLPolygon *)((SimpleKMLPlacemark *)feature).polygon;
        
            SimpleKMLLinearRing *outerRing = polygon.outerBoundary;
        
            CLLocationCoordinate2D points[[outerRing.coordinates count]];
            NSUInteger i = 0;
        
            for (CLLocation *coordinate in outerRing.coordinates)
                points[i++] = coordinate.coordinate;
        
            // create a polygon annotation for it
            //
            MKPolygon *overlayPolygon = [MKPolygon polygonWithCoordinates:points count:[outerRing.coordinates count]];
        
            [mapView addOverlay:overlayPolygon];
        
            // zoom the map to the polygon bounds
            //
            [mapView setVisibleMapRect:overlayPolygon.boundingMapRect animated:YES];
        }
    }
}

-(SimpleKMLStyle*) getStyleforFeature:(SimpleKMLFeature*)feature
{
    SimpleKMLStyleSelector *selector = feature.style;
    SimpleKMLStyle *style=nil;

    if(selector == nil){
        selector = [((SimpleKMLDocument*)kml.feature) sharedStyleWithID:feature.sharedStyleID];
    }
    
    if ([selector isKindOfClass:[SimpleKMLStyle class]]) {
        style = (SimpleKMLStyle*)selector;
    }
    else if([selector isKindOfClass:[SimpleKMLStyleMap class]]){
        if (((SimpleKMLStyleMap*)selector).normalStyle != nil) {
            style = ((SimpleKMLStyleMap*)selector).normalStyle;
        }
        else {
            style = (SimpleKMLStyle*)[((SimpleKMLDocument*)kml.feature) sharedStyleWithID:((SimpleKMLStyleMap*)selector).normalSharedStyleID];
        }
    }
    
    return style;
}


#pragma mark -

// NOTE:  This is very inefficient.  Need to connect the reuseIdentifier with our sharedStyle's.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *iconView;
    
    UIImage *iconImage = ((Simple_KML_Point_Placemark*)annotation).icon;
    
    if(iconImage != nil)
    {
        iconView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];        
        iconView.image = iconImage;
    }
    else{
        iconView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    }
    return iconView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // we get here in order to draw any polygon
    //
    MKPolygonView *polygonView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay] autorelease];
    
    // use some sensible defaults - normally, you'd probably look for LineStyle & PolyStyle in the KML
    //
    polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
    polygonView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
    
    polygonView.lineWidth = 2.0;
    
    return polygonView;
}

@end
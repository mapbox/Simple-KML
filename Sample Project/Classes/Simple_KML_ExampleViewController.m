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

@implementation Simple_KML_ExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // grab the example KML file (which we know will have no errors, but you should ordinarily check)
    //
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"kml"] error:NULL];
    
    // look for a document feature in it per the KML spec
    //
    if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]])
    {
        // see if the document has features of its own
        //
        for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features)
        {
            // see if we have any placemark features with a point
            //
            if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).point)
            {
                SimpleKMLPoint *point = ((SimpleKMLPlacemark *)feature).point;
                
                // create a normal point annotation for it
                //
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                
                annotation.coordinate = point.coordinate;
                annotation.title      = feature.name;
                
                [mapView addAnnotation:annotation];
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
}

#pragma mark -

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // we get here in order to draw any polygon
    //
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
    
    // use some sensible defaults - normally, you'd probably look for LineStyle & PolyStyle in the KML
    //
    polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
    polygonView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
    
    polygonView.lineWidth = 2.0;
    
    return polygonView;
}

@end
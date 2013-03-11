//
//  SKExampleViewController.m
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright MapBox 2010-2013. All rights reserved.
//

#import "SKExampleViewController.h"

#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"

#import <MapBox/MapBox.h>

@implementation SKExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup the map view
    //
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds];

    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:mapView];

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
                RMPointAnnotation *annotation = [[RMPointAnnotation alloc] initWithMapView:mapView coordinate:point.coordinate andTitle:feature.name];
                
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
                RMPolygonAnnotation *overlayPolygon = [[RMPolygonAnnotation alloc] initWithMapView:mapView points:outerRing.coordinates interiorPolygons:nil];

                [mapView addAnnotation:overlayPolygon];
                
                // zoom the map to the polygon bounds
                //
                [mapView setProjectedBounds:overlayPolygon.projectedBoundingBox animated:YES];
            }
        }
    }
}

@end
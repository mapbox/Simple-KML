# Simple KML: Cocoa parsing library for Keyhole Markup Language

Simple KML is a simple & lightweight parsing library for KML written in Objective-C for the iOS platform.

It is not meant for *drawing*, but rather for *parsing*. That is, it is up to the developer to turn the data structures returned by Simple KML into drawing code, be it for annotations in MapKit, constructs in an external mapping library, drawing paths on a `UIImage`, or otherwise.

Simple KML is basically an XML parser with smarts about KML. It presents a hierarchical view of KML data and can turn things like Simple KML color definitions into `UIColor` and text coordinates into `CLLocation` so that you don't have to.

## Requirements

Simple KML has been designed & built for iOS 5.0 and greater. There's no particular reason it couldn't be adapted to Mac OS X; it just hasn't been done yet out of lack of necessity. 

Simple KML is built for [ARC](http://clang.llvm.org/docs/AutomaticReferenceCounting.html). 

Simple KML previously depended on external XML parsing and zip libraries. These have been removed.

## Features

* Support for most of the base KML entities.

    Basic support for `Object`, `Feature`, `Placemark`, `Container`, `Document`, `Folder`, `Geometry`, `Point`, `LineString`, `LinearRing`, `Polygon`, `StyleSelector`, `Style`, `SubStyle`, `BalloonStyle`, `ColorStyle`, `LineStyle`, `PolyStyle`, `IconStyle` and `ExtendedData`.

* Simple invocation.

    `SimpleKML *myKML = [SimpleKML KMLWithContentsOfFile:@"/path/to/file.kml" error:&error]`  
    `SimpleKML *myKML = [SimpleKML KMLWithContentsOfURL:[NSURL URLWithString:@"http://example.com/file.kml"] error:&error]`  

* Support for KMZ archives. 

    Currently searches for a top-level KML file in the archive and retrieves icon data for bundled `IconStyle` entities.

* Cocoa-native behavior.

    Native types:

    `SimpleKMLLineStyle *lineStyle = myPolygon.lineStyle; UIColor *lineColor = lineStyle.color;`  
    `NSArray *polygonPoints = myPolygon.outerBoundary.coordinates; // CLLocation objects`  
    `UIColor *textColor = myPlacemark.style.balloonStyle.textColor;`  
    `UIImage *icon = myPlacemark.style.iconStyle.icon; // planned: automatically apply scale, heading, and parent style color`  

    Intelligent parsing:

    `SimpleKMLStyle *inlineStyle = myPlacemark.inlineStyle; // within <Placemark>`  
    `SimpleKMLStyle *sharedStyle = myPlacemark.sharedStyle; // common to <Document>; no need to reference <StyleUrl>`  
    `SimpleKMLStyle *activeStyle = myPlacemark.style; // the inline style overrides the shared style`  

    `SimpleKMLGeometry *geometry = myPlacemark.geometry; // <Point>, <Polygon>, <LineString>, <MultiGeometry>, etc.`  
    `SimpleKMLPoint *point = myPlacemark.point; // shortcut if <Point> exists for <Placemark>`  

    Smart error handling:

    `NSError *error;`  
    `SimpleKML *myKML = [SimpleKML KMLWithContentsOfFile:@"invalid.kml" error:&error];`  
    `if (error) { NSLog(@"%@", error); } // SimpleKMLParseError: Improperly formed KML (LinearRing has less than four coordinates)`  

    Debugging:

    `gdb: po [mySimpleKMLObject source] // protected variable containing original XML source`  

    Hierarchies:

    `SimpleKMLDocument *document = myPlacemark.document;`  
    `NSArray *documentFeatures = document.features;`  

## Usage

Be sure to clone the repository and include all of the required source files in your Xcode project.

Include all of the Simple KML files in your Xcode project. You may need to add any required supporting libraries depending on your use case.

If using libxml2 directly, add /usr/include/libxml2 to your “Header Search Paths” and -lxml2 to your “Other Linker Flags`.

You'll also need to link against `CoreLocation.framework` and `libz.dylib`. 

## Plans, needs, bugs, etc.

If you find a bug or want to otherwise contribute, please fork the project on GitHub and contribute that way. In particular, I would like to start adding built-in testing with a library of accompanying KML test files to parse. 

## License

Copyright (c) 2010-2013 MapBox.

The Simple KML library should be accompanied by a LICENSE file. This file contains the license relevant to this distribution. If no license exists, please contact [MapBox](http://mapbox.com).

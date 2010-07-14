# Simple KML: Cocoa parsing library for Keynote Markup Language

Simple KML is a simple & lightweight parsing library for KML written in Objective-C for the iOS platform.

## Requirements

Simple KML has been designed & built for iOS 3.2 (the iPad). There's no particular reason it couldn't run on another iOS version or be adapted to Mac OS X; it just hasn't been done yet out of lack of necessity. 

Simple KML depends on [TouchXML](http://code.google.com/p/touchcode/wiki/TouchXML), an Objective-C library for DOM-based XML parsing based on libxml2. 

## Features

* Support for most of the base KML entities.

    Basic support for Object, Feature, Placemark, Container, Document, Folder, Geometry, Point, LineString, LinearRing, Polygon, StyleSelector, Style, SubStyle, BalloonStyle, ColorStyle, LineStyle, PolyStyle, and IconStyle.

* Simple invocation.

    `SimpleKML *myKML = [SimpleKML KMLWithContentsOfFile:@"/path/to/file.kml" error:&error]`  
    `SimpleKML *myKML = [SimpleKML KMLWithContentsOfURL:[NSURL URLWithString:@"http://example.com/file.kml"] error:&error]`  

* Cocoa-native behavior

    Native types:

    `SimpleKMLLineStyle *lineStyle = myPolygon.lineStyle; UIColor *lineColor = lineStyle.color;`  
    `NSArray *polygonPoints = myPolygon.outerBoundary.coordinates; // CLLocation objects`  
    `UIColor *textColor = myPlacemark.style.balloonStyle.textColor;`  
    `UIImage *icon = myPlacemark.style.iconStyle.icon; // planned: automatically apply scale, heading, and parent style color`  

    Intelligent parsing:

    `SimpleKMLStyle *inlineStyle = myPlacemark.inlineStyle; // within <Placemark>`  
    `SimpleKMLStyle *sharedStyle = myPlacemark.sharedStyle; // common to <Document>; no need to reference <StyleUrl>`  
    `SimpleKMLStyle *activeStyle = myPlacemark.style; // the inline style overrides the shared style`  

    `SimpleKMLGeometry *geometry = myPlacemark.geometry; // <Point>, <Polygon>, <LineString>, etc.`  
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

Include all of the Simple KML files in your Xcode project, as well as the files in the TouchXML subdirectory if you don't already use TouchXML in your project. Per TouchXML's [installation guide](http://foobarpig.com/iphone/touchxml-installation-guide.html), add `/usr/include/libxml2` to your "Header Search Paths" and `-lxml2` to your "Other Linker Flags" since TouchXML depends on libxml2.

## Plans, needs, bugs, etc.

If you find a bug or want to otherwise contribute, please fork the project on GitHub and contribute that way. In particular, I would like to start adding built-in testing with a library of accompanying KML test files to parse. 

## License

Copyright (c) 2010 Code Sorcery Workshop, LLC and Development Seed, Inc.

The Simple KML library should be accompanied by a LICENSE file. This file contains the license relevant to this distribution. If no license exists, please contact Justin R. Miller at <[incanus@codesorcery.net](mailto:incanus@codesorcery.net)>.
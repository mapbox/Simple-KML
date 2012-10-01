//
//  SimpleKMLLineString.m
//  SimpleKML
//
//  Created by Markus on 09.08.12.
//
//

#import "SimpleKMLLineStringTest.h"
#import "SimpleKML.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLMultiGeometry.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLLineString.h"
#import <CoreLocation/CoreLocation.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@implementation SimpleKMLLineStringTest


- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDefault
{
    NSError* error;
  
    NSString* coordinateString = @"-122.681944,45.52000000,32.000000\n-43.1963890,-22.9083330,6.0000000\n28.97601800,41.01224000,32.000000\n-21.9333330,64.13333300,13.000000\n-122.681944,45.52000000,32.000000";


    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];

    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];

    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
        
    assertThat(lineString, notNilValue());
    assertThat(lineString.coordinates, hasCountOf(5));
    
    CLLocationCoordinate2D location2D;
    location2D.latitude= 45.52000000;
    location2D.longitude=-122.681944;
    
    CLLocation* location = [[CLLocation alloc] initWithCoordinate:location2D altitude:32.000000 horizontalAccuracy:0 verticalAccuracy:0  timestamp:[NSDate date]];
    
    assertThat([NSNumber numberWithDouble:[[lineString.coordinates objectAtIndex:0] altitude]], equalToDouble(location.altitude));
    assertThat([NSNumber numberWithDouble:[[lineString.coordinates objectAtIndex:0] coordinate].latitude], equalToDouble(location.coordinate.latitude));
    assertThat([NSNumber numberWithDouble:[[lineString.coordinates objectAtIndex:0] coordinate].longitude], equalToDouble(location.coordinate.longitude));

}


- (void) testWithoutAltitude
{
    NSError* error;
    
    NSString* coordinateString = @"-122.681944,45.52000000\n-43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    assertThat(lineString, notNilValue());
    assertThat(lineString.coordinates, hasCountOf(2));
    
    CLLocationCoordinate2D location2D;
    location2D.latitude= 45.52000000;
    location2D.longitude=-122.681944;
    
    CLLocation* location = [[CLLocation alloc] initWithCoordinate:location2D altitude:0.000000 horizontalAccuracy:0 verticalAccuracy:0  timestamp:[NSDate date]];
    
    assertThat([NSNumber numberWithDouble:[[lineString.coordinates objectAtIndex:0] altitude]], equalToDouble(location.altitude));
    assertThat([NSNumber numberWithDouble:[[lineString.coordinates objectAtIndex:0] coordinate].latitude], equalToDouble(location.coordinate.latitude));
    assertThat([NSNumber numberWithDouble:[[lineString.coordinates objectAtIndex:0] coordinate].longitude], equalToDouble(location.coordinate.longitude));

    
}


- (void) testSinglePointException
{
    NSError* error;
    
    NSString* coordinateString = @"-122.681944,45.52000000";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
   
    
    
}


- (void) testLongitudeOnlyException
{
    NSError* error;
    
    NSString* coordinateString = @"-122.681944";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
    
    
    
}


- (void) testTooManyNumbersAltitude
{
    NSError* error;
    
    NSString* coordinateString = @"-122.681944,45.52000000,-43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
    
}


- (void) testNoPointException
{
    NSError* error;
    
    NSString* coordinateString = @"";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"NO coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
    
    
    
}

- (void) testWhiteSpaceException
{
    NSError* error;
    
    NSString* coordinateString = @"-122.681944, 45.52000000 -43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    assertThat(lineString, nilValue());
}


- (void) testLongitudeToSmallException
{
    NSError* error;
    
    NSString* coordinateString = @"-180.681944,45.52000000 -43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
     
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
}


- (void) testLongitudeToLargeException
{
    NSError* error;
    
    NSString* coordinateString = @"180.681944,45.52000000 -43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);

}

- (void) testLatitudeToSmallException
{
    NSError* error;
    
    NSString* coordinateString = @"-120.681944,-90.52000000 -43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
}


- (void) testLatitudeToLargeException
{
    NSError* error;
    
    NSString* coordinateString = @"120.681944,90.52000000 -43.1963890,-22.9083330";
    
    
    id xmlChildMock = [OCMockObject mockForClass:[CXMLElement class]];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:@"coordinates"] name];
    [(CXMLNode*)[[xmlChildMock stub] andReturn:coordinateString] stringValue];
    
    [[[self.xmlNodeMock stub] andReturn:@[xmlChildMock]] children];
    [[[self.xmlNodeMock stub] andReturn:@"xmlString"] XMLString];
    [[[self.xmlNodeMock stub] andReturn:nil] attributeForName:@"id"];
    
    
    
    SimpleKMLLineString* lineString = [[SimpleKMLLineString alloc] initWithXMLNode:self.xmlNodeMock sourceURL:[NSURL URLWithString:@"Dummy"] error:&error];
    
    
    assertThat(lineString, nilValue());
    
    NSLog(@"%@", error);
    
}

@end

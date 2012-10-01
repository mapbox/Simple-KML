//
//  SimpleKMLObjectTest.m
//  Simple-KML-Lib
//
//  Created by Markus on 01.10.12.
//  Copyright (c) 2012 jemm. All rights reserved.
//

#import "SimpleKMLObjectTest.h"

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@implementation SimpleKMLObjectTest

- (void)setUp
{
    [super setUp];
    
    
    // create coordinates to check against
    
    
    self.xmlNodeMock    = [OCMockObject mockForClass:[CXMLElement class]];
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


@end

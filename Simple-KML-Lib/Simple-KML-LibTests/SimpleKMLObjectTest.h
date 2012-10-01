//
//  SimpleKMLObjectTest.h
//  Simple-KML-Lib
//
//  Created by Markus on 01.10.12.
//  Copyright (c) 2012 jemm. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SimpleKML.h"

@interface SimpleKMLObjectTest : SenTestCase


@property SimpleKML*            kml;
@property NSMutableArray*       coordinates;
@property id                    xmlNodeMock;


@end

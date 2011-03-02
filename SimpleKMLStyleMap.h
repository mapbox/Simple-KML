//
//  SimpleKMLStyleMap.h
//  NGS Mobile
//
//  Created by David Stuart on 12/4/10.
//  Copyright 2010 U.S. Army Corps of Engineers. All rights reserved.
//

#import "SimpleKMLStyleSelector.h"
#import "SimpleKMLStyle.h"

@interface SimpleKMLStyleMap : SimpleKMLStyleSelector {
	SimpleKMLStyle *normalStyle;
	SimpleKMLStyle *highlightStyle;
	NSString *normalSharedStyleID;
	NSString *highlightSharedStyleID;
}

@property (nonatomic, retain) SimpleKMLStyle *normalStyle;
@property (nonatomic, retain) SimpleKMLStyle *highlightStyle;
@property (nonatomic, retain) NSString *normalSharedStyleID;
@property (nonatomic, retain) NSString *highlightSharedStyleID;

@end

//
//  SimpleKMLStyleMap.m
//  NGS Mobile
//
//  Created by David Stuart on 12/4/10.
//  Copyright 2010 U.S. Army Corps of Engineers. All rights reserved.
//

#import "SimpleKMLStyleMap.h"


@implementation SimpleKMLStyleMap

@synthesize normalStyle, highlightStyle, normalSharedStyleID, highlightSharedStyleID;

- (id)initWithXMLNode:(CXMLNode *)node sourceURL:sourceURL error:(NSError **)error
{
    self = [super initWithXMLNode:node sourceURL:sourceURL error:error];
    
	
    if (self != nil)
    {
		self.normalStyle = nil;
		self.highlightStyle = nil;
		self.normalSharedStyleID = nil;
		self.highlightSharedStyleID = nil;
		
		NSString *key;
		SimpleKMLStyle *style;
		NSString *styleurl;
		NSError *error;
		
        
        for (CXMLNode *child in [node children])
        {
			key = nil;
			styleurl = nil;
			style = nil;
			
			if([[child name] isEqualToString:@"Pair"])
			{
				for(CXMLNode *pchild in [child children])
				{
					if ([[pchild name] isEqualToString:@"key"]) {
						key = [pchild stringValue];
					}
					else if ([[pchild name] isEqualToString:@"styleUrl"]) {
						styleurl = [[[pchild stringValue] stringByReplacingOccurrencesOfString:@"#" withString:@""] retain];
						//styleurl = [pchild stringValue];
					}
					else if([[pchild name] isEqualToString:@"Style"]) {
						style = [[SimpleKMLStyle alloc] initWithXMLNode:pchild sourceURL:sourceURL error:&error];
						//style = [pchild stringValue];
					}
					
				}
				
				
				if (key != nil && (style != nil || styleurl != nil)) {
					if([key isEqualToString:@"normal"]){
						if (styleurl != nil) {
							self.normalSharedStyleID = styleurl;
						}
						else if(style != nil){
							self.normalStyle = style;
						}
					}
					else if([key isEqualToString:@"highlight"]){
						if (styleurl != nil) {
							self.highlightSharedStyleID = styleurl;
						}
						else if(style != nil){
							self.highlightStyle = style;
						}
						
					}
					
				}
			}
        }
		
    }
    
    return self;
}

- (void)dealloc
{
    [normalSharedStyleID release];
    [highlightSharedStyleID release];
    [highlightStyle release];
    [normalStyle release];
    [super dealloc];
}


@end

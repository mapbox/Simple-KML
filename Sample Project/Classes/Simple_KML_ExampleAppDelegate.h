//
//  Simple_KML_ExampleAppDelegate.h
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright Development Seed 2010-2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Simple_KML_ExampleViewController;

@interface Simple_KML_ExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    Simple_KML_ExampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Simple_KML_ExampleViewController *viewController;

@end


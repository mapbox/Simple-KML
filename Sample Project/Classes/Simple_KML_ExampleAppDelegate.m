//
//  Simple_KML_ExampleAppDelegate.m
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright Development Seed 2010-2012. All rights reserved.
//

#import "Simple_KML_ExampleAppDelegate.h"
#import "Simple_KML_ExampleViewController.h"

@implementation Simple_KML_ExampleAppDelegate
{
    IBOutlet Simple_KML_ExampleViewController *viewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:viewController.view];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] makeKeyAndVisible];

    return YES;
}

@end
//
//  SKExampleAppDelegate.m
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright MapBox 2010-2013. All rights reserved.
//

#import "SKExampleAppDelegate.h"
#import "SKExampleViewController.h"

@implementation SKExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.rootViewController = [SKExampleViewController new];

    [self.window makeKeyAndVisible];

    return YES;
}

@end
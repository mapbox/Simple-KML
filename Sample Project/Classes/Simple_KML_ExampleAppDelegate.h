//
//  Simple_KML_ExampleAppDelegate.h
//  Simple KML Example
//
//  Created by Justin R. Miller on 9/22/10.
//  Copyright Code Sorcery Workshop 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Simple_KML_ExampleViewController;

@interface Simple_KML_ExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    Simple_KML_ExampleViewController *viewController;
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet Simple_KML_ExampleViewController *viewController;

@end


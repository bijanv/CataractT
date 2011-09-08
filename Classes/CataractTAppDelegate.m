//
//  CataractTAppDelegate.m
//  CataractT
//
//  Created by Branislav Grujic on 1/15/11.
//  Copyright 2011 Bane's Tools. All rights reserved.
//

#import "CataractTAppDelegate.h"

@implementation RuntimeVariables
@synthesize switch1, switch2, switch3, switch4, switch5, switch6, switch7, switch8;
@synthesize DebugLog, THigh, TLow, uint8_1, FlashFlareSize;
@synthesize ZMax;
@end

@implementation CataractTAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize runtimeVars;
@synthesize cameraImages;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
  
    if (cameraImages == NULL)
    {
      cameraImages = [[CameraImages alloc] init];
      [cameraImages initImages];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	/*if ([[[[viewController aVCamViewController] captureManager] session] isRunning] == NO) {
        [[[[viewController aVCamViewController] captureManager] session] startRunning];
    }*/
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end

//
//  AppDelegate.m
//  SLLaunchDemo
//
//  Created by halong33 on 16/3/15.
//  Copyright © 2016年 com.halong. All rights reserved.
//

#import "AppDelegate.h"
#import "SLAppLaunchPanel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
        
    [SLAppLaunchPanel displayAppLaunchPanel];
    return YES;
}

@end

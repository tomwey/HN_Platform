//
//  AppDelegate.h
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppDelegate.h"

@interface AppDelegate : BaseAppDelegate <UIApplicationDelegate>

//@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) UIViewController *appRootController;

- (void)resetRootController;

- (void)showGuide:(BOOL)yesOrNo;

@end

@interface UIWindow (NavBar)

@property (nonatomic, strong, readonly) UINavigationController *navController;

@end


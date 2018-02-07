//
//  BaseAppDelegate.h
//  HN_ERP
//
//  Created by tomwey on 3/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)registerRemoteNotification;

@end

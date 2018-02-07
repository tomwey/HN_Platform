//
//  UIViewController+CreateFactory.h
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CreateFactory)

+ (instancetype)createControllerWithName:(NSString *)viewControllerName;

+ (instancetype)createControllerEmbedNavigationControllerWithName:(NSString *)viewControllerName;

@end

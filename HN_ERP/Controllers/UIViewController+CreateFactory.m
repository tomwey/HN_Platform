//
//  UIViewController+CreateFactory.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "UIViewController+CreateFactory.h"

@implementation UIViewController (CreateFactory)

+ (instancetype)createControllerWithName:(NSString *)viewControllerName
{
    if ( !viewControllerName ) return nil;
    
    id obj = [[NSClassFromString(viewControllerName) alloc] init];
    
    if ( [obj isKindOfClass:[UIViewController class]] == NO ) {
        return nil;
    }
    
    return obj;
}

+ (instancetype)createControllerEmbedNavigationControllerWithName:(NSString *)viewControllerName
{
    UIViewController *vc = [self createControllerWithName:viewControllerName];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}

@end

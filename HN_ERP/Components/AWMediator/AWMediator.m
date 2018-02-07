//
//  AWMediator.m
//  deyi
//
//  Created by tomwey on 9/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "AWMediator.h"
#import <objc/runtime.h>

/// 添加扩展
@interface UIViewController (AWInternalPrivateCategory)

@property (nonatomic, strong) NSDictionary *aw_customParams;

@end

@implementation AWMediator

+ (AWMediator *)sharedInstance
{
    static AWMediator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[AWMediator alloc] init];
        }
    });
    return instance;
}

- (UIViewController *)openVCWithName:(NSString *)vcClassName
                              params:(NSDictionary *)params
{
    if (!vcClassName) return nil;
    return [self openVCWithClass:NSClassFromString(vcClassName) params:params];
}

- (UIViewController *)openVCWithClass:(Class)vcClass
                               params:(NSDictionary *)params
{
    UIViewController *vc = [[vcClass alloc] init];
    if ( !vc ) {
        vc = [[UIViewController alloc] init];
    }
    
    vc.aw_customParams = params;
    
    return vc;
}

- (UIViewController *)openNavVCWithName:(NSString *)vcClassName
                                 params:(NSDictionary *)params
{
    UIViewController *vc = [self openVCWithName:vcClassName params:params];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}

@end

@implementation UIViewController (AWParamsCategory)

static char kAWCustomPrivateParamsKey;

- (NSDictionary *)params
{
    return [NSDictionary dictionaryWithDictionary:self.aw_customParams];
}

- (void)setAw_customParams:(NSDictionary *)aw_customParams
{
    objc_setAssociatedObject(self,
                             &kAWCustomPrivateParamsKey,
                             aw_customParams,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)aw_customParams
{
    return objc_getAssociatedObject(self, &kAWCustomPrivateParamsKey);
}

@end

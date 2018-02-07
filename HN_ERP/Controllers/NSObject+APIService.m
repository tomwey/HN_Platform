//
//  NSObject+APIService.m
//  HN_ERP
//
//  Created by tomwey on 1/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NSObject+APIService.h"
#import <objc/runtime.h>

@implementation NSObject (APIService)

static char kNetworkAPIServiceKey;

- (id <APIServiceProtocol>)apiServiceWithName:(NSString *)apiServiceName
{
    id obj = objc_getAssociatedObject(self, &kNetworkAPIServiceKey);
    if ( !obj ) {
        NSLog(@"执行了...");
        obj = [[NSClassFromString(apiServiceName) alloc] init];
        if ( [obj conformsToProtocol:@protocol(APIServiceProtocol)] == NO ) {
            NSLog(@"API Service 必须要实现APIServiceProtocol");
            return nil;
        }
        objc_setAssociatedObject(obj,
                                 &kNetworkAPIServiceKey,
                                 obj,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return (id <APIServiceProtocol>)obj;
}

@end

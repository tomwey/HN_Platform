//
//  UIViewController+NetworkService.m
//  RTA
//
//  Created by tomwey on 10/24/16.
//  Copyright © 2016 tomwey. All rights reserved.
//

#import "NSObject+RTIDataService.h"
#import <objc/runtime.h>

@implementation NSObject (RTIDataService)

static char kNetworkServiceKey;

- (RTIDataService *)dataService
{
    id obj = objc_getAssociatedObject(self, &kNetworkServiceKey);
    if ( !obj ) {
        obj = [[RTIDataService alloc] init];
        objc_setAssociatedObject(obj,
                                 &kNetworkServiceKey,
                                 obj,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return (RTIDataService *)obj;
}

@end

//
//  NSObject+UserData.m
//  HN_ERP
//
//  Created by tomwey on 3/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NSObject+UserData.h"
#import <objc/runtime.h>

@implementation NSObject (BindUserData)

static void *AWNSObjectBindUserData = &AWNSObjectBindUserData;

- (void)setUserData:(id)userData
{
    objc_setAssociatedObject(self, AWNSObjectBindUserData, userData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userData
{
    return objc_getAssociatedObject(self, AWNSObjectBindUserData);
}

@end


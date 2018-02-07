//
//  UserData.m
//  HN_ERP
//
//  Created by tomwey on 2/27/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "UIButton+UserData.h"
#import <objc/runtime.h>

@implementation UIButton (UserData)

static void *AWButtonUserData = &AWButtonUserData;

- (void)setUserData:(id)userData
{
    objc_setAssociatedObject(self, AWButtonUserData, userData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userData
{
    return objc_getAssociatedObject(self, AWButtonUserData);
}

@end

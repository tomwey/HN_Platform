//
//  UIActionSheet+DisabledButtons.m
//  HN_ERP
//
//  Created by tomwey on 2/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "UIActionSheet+DisabledButtons.h"
#import <objc/runtime.h>

static void * DisabledButtonsKey = &DisabledButtonsKey;

@implementation UIActionSheet (DisabledButtons)

- (void)setDisabledButtons:(NSArray *)disabledButtons
{
    objc_setAssociatedObject(self, DisabledButtonsKey, disabledButtons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSString *> *)disabledButtons
{
    return objc_getAssociatedObject(self, DisabledButtonsKey);
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *view in [actionSheet subviews]) {
        if ( [view isKindOfClass:NSClassFromString(@"UIAlertButton")] ) {
            if ( [view respondsToSelector:@selector(title)] ) {
                if ( [self.disabledButtons containsObject:[view performSelector:@selector(title)]] ) {
                    [view performSelector:@selector(setEnabled:) withObject:NO];
                }
            }
        }
    }
}

@end

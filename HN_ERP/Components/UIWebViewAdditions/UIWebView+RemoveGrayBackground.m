//
//  UIWebView+RemoveGrayBackground.m
//  BSA
//
//  Created by tangwei1 on 16/11/15.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "UIWebView+RemoveGrayBackground.h"

@implementation UIWebView (RemoveGrayBackground)

- (void)removeGrayBackground
{
    self.backgroundColor = [UIColor clearColor];
    for (UIView *subview in [self.scrollView subviews])
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
}

@end

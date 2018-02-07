//
//  UIButton+AWButtonLoading.m
//  deyi
//
//  Created by tomwey on 9/5/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "UIButton+AWButtonLoading.h"
#import <objc/runtime.h>

@interface UIButton (TempAttribute)

/** 如果按钮是有标题，那么先保存一份原来的标题 */
@property (nonatomic, copy) NSString *originTitle;

@end

@implementation UIButton (AWButtonLoading)

static char kButtonOriginTitleKey;

- (void)setOriginTitle:(NSString *)originTitle
{
    objc_setAssociatedObject(self,
                             &kButtonOriginTitleKey,
                             originTitle,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)originTitle
{
    return [objc_getAssociatedObject(self, &kButtonOriginTitleKey) description];
}

- (UIActivityIndicatorView *)aw_indicatorView
{
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self viewWithTag:10011];
    if ( !spinner ) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.tag = 10011;
        [self addSubview:spinner];
        
        spinner.hidesWhenStopped = YES;
        
        spinner.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                     CGRectGetHeight(self.frame) / 2);
    }
    
    [self bringSubviewToFront:spinner];
    
    return spinner;
}

- (UIActivityIndicatorView *)startLoading
{
    self.userInteractionEnabled = NO;
    
    self.originTitle = [self currentTitle];
    [self setTitle:nil forState:UIControlStateNormal];
    
    UIActivityIndicatorView *spinner = [self aw_indicatorView];
    
    if ( [spinner isAnimating] == NO ) {
        [spinner startAnimating];
    }
    
    return spinner;
}

- (void)finishLoading
{
    self.userInteractionEnabled = YES;
    
    [self setTitle:self.originTitle forState:UIControlStateNormal];
    self.originTitle = nil;
    
    [[self aw_indicatorView] stopAnimating];
}

@end

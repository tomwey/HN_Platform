//
//  LoadEmptyOrErrorHandle.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "UITableView+LoadEmptyOrErrorHandle.h"
#import <objc/runtime.h>

@implementation UITableView (LoadEmptyOrErrorHandle)

static char kLoadEmptyOrErrorHandleCallbackKey;
static char kLoadEmptyOrErrorHandleToastKey;
static char kLoadEmptyOrErrorHandleMessageKey;
static char kLoadEmptyOrErrorHandleImageKey;
static char kLoadEmptyOrErrorHandleGestureKey;

@dynamic reloadDelegate;

- (void)setReloadDelegate:(id<ReloadDelegate>)reloadDelegate
{
    objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleCallbackKey, reloadDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id <ReloadDelegate>)reloadDelegate
{
    return objc_getAssociatedObject(self, &kLoadEmptyOrErrorHandleCallbackKey);
}

- (UILabel *)toastLabel
{
    UILabel* toastLabel = objc_getAssociatedObject(self, &kLoadEmptyOrErrorHandleToastKey);
    if ( !toastLabel ) {
        toastLabel = [[UILabel alloc] init];
        objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleToastKey, toastLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        toastLabel.textAlignment = NSTextAlignmentLeft;
        toastLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        toastLabel.numberOfLines = 0;
        toastLabel.layer.cornerRadius = 6;
        toastLabel.clipsToBounds = YES;
        [self addSubview:toastLabel];
    }
    return toastLabel;
}

/** 显示吐司提示 */
- (void)showErrorOrEmptyToast:(NSString *)message
{
    UILabel *toastLabel = [self toastLabel];
    [toastLabel bringSubviewToFront:toastLabel];
    
    CGFloat width = CGRectGetWidth(self.frame) * 0.618;
    
//    CGSize size = [message sizeWithFont:toastLabel.font constrainedToSize:CGSizeMake(width, 5000) lineBreakMode:toastLabel.lineBreakMode];
    CGSize size = [message boundingRectWithSize:CGSizeMake(width, 5000)
                                        options:0
                                     attributes:@{ NSFontAttributeName: toastLabel.font }
                                        context:NULL].size;
//    CGFloat height = MIN(size.height, 37);
    
    toastLabel.frame = CGRectMake(0, 0, width, size.height);
    toastLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) + 10 + CGRectGetHeight(toastLabel.frame) / 2);
    
    [UIView animateWithDuration:.3 animations:^{
        toastLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) - 10 - CGRectGetHeight(toastLabel.frame) / 2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 delay:1.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toastLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) + 10 + CGRectGetHeight(toastLabel.frame) / 2);
        } completion:^(BOOL finished) {
            [toastLabel removeFromSuperview];
            objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleToastKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
    }];
}

- (void)setMessageTextAttributes:(NSDictionary<NSString *,id> *)messageTextAttributes
{
    UILabel *label = [self messageLabel];
    if ( messageTextAttributes[NSFontAttributeName] ) {
        label.font = messageTextAttributes[NSFontAttributeName];
    }
    
    if ( messageTextAttributes[NSForegroundColorAttributeName] ) {
        label.textColor = messageTextAttributes[NSForegroundColorAttributeName];
    }
}

- (NSDictionary<NSString *, id> *)messageTextAttributes
{
    UILabel *label = [self messageLabel];
    return @{ NSFontAttributeName: label.font ?: [UIFont systemFontOfSize:14],
              NSForegroundColorAttributeName: label.textColor ?: [UIColor blackColor] }
    ;
}

- (UILabel *)messageLabel
{
    UILabel* messageLabel = objc_getAssociatedObject(self, &kLoadEmptyOrErrorHandleMessageKey);
    if ( !messageLabel ) {
        messageLabel = [[UILabel alloc] init];
        objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleMessageKey, messageLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = [UIFont systemFontOfSize:14];
        messageLabel.numberOfLines = 0;
    }
    return messageLabel;
}

- (UIColor *)inverseColor:(UIColor *)originColor
{
    CGColorRef oldCGColor = originColor.CGColor;
    NSInteger numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    if ( numberOfComponents <= 1 ) {
        // 只有alpha
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat* oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    int i = -1;
    // 4
    while (++i < numberOfComponents - 1) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    newComponentColors[i] = oldComponentColors[i]; // alpha
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor* newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    return newColor;
}

- (UITapGestureRecognizer *)tapGesture
{
    UITapGestureRecognizer* gesture = objc_getAssociatedObject(self, &kLoadEmptyOrErrorHandleGestureKey);
    if ( !gesture ) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEmptyOrErrorTap)];
        objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleGestureKey, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gesture;
}

- (void)handleEmptyOrErrorTap
{
    if ( [self.reloadDelegate respondsToSelector:@selector(reloadDataForErrorOrEmpty)] ) {
        [self removeErrorOrEmptyTips];
        [self.reloadDelegate reloadDataForErrorOrEmpty];
    }
}

- (UIImageView *)tipImageView
{
    UIImageView* imageView = objc_getAssociatedObject(self, &kLoadEmptyOrErrorHandleImageKey);
    if ( !imageView ) {
        imageView = [[UIImageView alloc] init];
        objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleImageKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageView;
}

/**
 * 显示纯文本提示
 * @param message 提示文字
 */
- (void)showErrorOrEmptyMessage:(NSString *)message reloadDelegate:(id <ReloadDelegate>)delegate
{
    [self removeErrorOrEmptyTips];
    
    [self removeCustomView];
    
    self.reloadDelegate = delegate;
    
//    self.hidden = YES;
    
    UILabel* label = [self messageLabel];
    if ( !label.superview ) {
        [self.superview addSubview:label];
    }
    
    CGFloat width = CGRectGetWidth(self.superview.bounds) * 0.618;
//    CGSize size = [message sizeWithFont:label.font
//                      constrainedToSize:CGSizeMake(width, CGRectGetHeight(self.superview.bounds))
//                          lineBreakMode:label.lineBreakMode];
    CGSize size = [message boundingRectWithSize:CGSizeMake(width, CGRectGetHeight(self.superview.bounds))
                                        options:0
                                     attributes:@{ NSFontAttributeName: label.font }
                                        context:NULL].size;
    label.frame = CGRectMake(0, 0, width, size.height);
    label.center = CGPointMake(CGRectGetWidth(self.superview.bounds) / 2, CGRectGetHeight(self.superview.bounds) / 2);
    
    label.text = message;
    label.textColor = [UIColor colorWithRed:201/255.0
                                      green:201/255.0
                                       blue:201/255.0
                                      alpha:1.0];//[self inverseColor:self.superview.backgroundColor];
    
    // 添加点击操作
    if ( delegate ) {
        [self.superview addGestureRecognizer:[self tapGesture]];
    }
}

- (void)showCustomView:(UIView *)aView
{
    [self removeCustomView];
    
    [self removeErrorOrEmptyTips];
    
    if ( !aView.superview ) {
        aView.tag = 103231;
        [self.superview addSubview:aView];
    }
    
    [self.superview bringSubviewToFront:aView];
    
    aView.center = CGPointMake(CGRectGetWidth(self.superview.bounds) / 2,
                               CGRectGetHeight(self.superview.bounds) / 2);
}

- (void)removeCustomView
{
    // 简单用tag来记录
    UIView *view = [self.superview viewWithTag:103231];
    [view removeFromSuperview];
}

/**
 * 显示图片提示
 * 提示图片
 */
- (void)showErrorOrEmptyImage:(UIImage *)image reloadDelegate:(id<ReloadDelegate>)delegate
{
    [self removeErrorOrEmptyTips];
    
    self.reloadDelegate = delegate;
    
    self.hidden = YES;
    
    UIImageView* imageView = [self tipImageView];
    if ( !imageView.superview ) {
        [self.superview addSubview:imageView];
    }
    
    imageView.image = image;
    [imageView sizeToFit];
    
    imageView.center = CGPointMake(CGRectGetWidth(self.superview.frame) / 2, CGRectGetHeight(self.superview.frame) / 2);
    
    // 添加点击操作
    [self.superview addGestureRecognizer:[self tapGesture]];
}

- (void)removeErrorOrEmptyTips
{
    self.hidden = NO;
    
    // 移除点击手势
    [self.superview removeGestureRecognizer:[self tapGesture]];
    objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleGestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 移除文本提示
    [[self messageLabel] removeFromSuperview];
    objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleMessageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 移除图片提示
    [[self tipImageView] removeFromSuperview];
    objc_setAssociatedObject(self, &kLoadEmptyOrErrorHandleImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

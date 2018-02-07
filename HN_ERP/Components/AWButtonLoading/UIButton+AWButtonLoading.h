//
//  UIButton+AWButtonLoading.h
//  deyi
//
//  Created by tomwey on 9/5/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (AWButtonLoading)

/**
 * 返回的spinner默认是白色的
 */
- (UIActivityIndicatorView *)startLoading;

- (void)finishLoading;

@end

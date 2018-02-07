//
//  UIImageView+CircleProgressIndicator.h
//  Wallpapers10000+
//
//  Created by tangwei1 on 15/7/24.
//  Copyright (c) 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ProgressIndicator)

@property (nonatomic, readonly) UIView* progressIndicatorView;

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url;

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url indicatorCenter:(CGPoint)center;

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url
                           placeholderImage:(UIImage *)placeholderImage
                        imageDidAppearBlock:(void (^)(UIImageView *))imageDidAppearBlock;

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url
                           placeholderImage:(UIImage *)placeholderImage
                        imageDidAppearBlock:(void (^)(UIImageView *))imageDidAppearBlock
                            indicatorCenter:(CGPoint)center;

@end

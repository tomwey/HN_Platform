//
//  UIImageView+CircleProgressIndicator.m
//  Wallpapers10000+
//
//  Created by tangwei1 on 15/7/24.
//  Copyright (c) 2015年 tangwei1. All rights reserved.
//

#import "UIImageView+ProgressIndicator.h"
#import "UIImageView+AWProgress.h"
#import "MACircleProgressIndicator.h"
#import <objc/runtime.h>

static char kAWImageProgressIndicatorKey;

@interface UIImageView (_ProgressIndicator)

@property (nonatomic, retain) MACircleProgressIndicator* aw_progressIndicatorView;

@end

@implementation UIImageView (_ProgressIndicator)

@dynamic aw_progressIndicatorView;

@end

@implementation UIImageView (ProgressIndicator)

- (UIView *)progressIndicatorView
{
    return [self aw_progressIndicatorView];
}

- (void)aw_setProgressIndicatorView:(MACircleProgressIndicator *)aw_progressIndicatorView
{
    objc_setAssociatedObject(self, &kAWImageProgressIndicatorKey, aw_progressIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MACircleProgressIndicator *)aw_progressIndicatorView
{
    MACircleProgressIndicator* progress = (MACircleProgressIndicator *)objc_getAssociatedObject(self, &kAWImageProgressIndicatorKey);
    if ( !progress ) {
//        CGFloat width = CGRectGetWidth(self.bounds) * 0.382;
        progress = [[MACircleProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        progress.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        progress.strokeWidth = 3.0;
        progress.color = [UIColor whiteColor];
        [self aw_setProgressIndicatorView:progress];
    }
    
    return progress;
}

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url
{
    [self setImageWithProgressIndicatorForURL:url placeholderImage:nil];
}

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url indicatorCenter:(CGPoint)center
{
    [self setImageWithProgressIndicatorForURL:url placeholderImage:nil imageDidAppearBlock:nil indicatorCenter:center];
}

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    [self setImageWithProgressIndicatorForURL:url placeholderImage:placeholderImage imageDidAppearBlock:nil];
}

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url
                           placeholderImage:(UIImage *)placeholderImage
                        imageDidAppearBlock:(void (^)(UIImageView *))imageDidAppearBlock
{
    [self setImageWithProgressIndicatorForURL:url
                             placeholderImage:placeholderImage
                          imageDidAppearBlock:imageDidAppearBlock
                              indicatorCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2)];
}

- (void)setImageWithProgressIndicatorForURL:(NSURL *)url
                           placeholderImage:(UIImage *)placeholderImage
                        imageDidAppearBlock:(void (^)(UIImageView *))imageDidAppearBlock
                            indicatorCenter:(CGPoint)center
{
    [self setImage:nil];
    
    [self.aw_progressIndicatorView setValue:0.0];
    
    if ( ![self.aw_progressIndicatorView superview] ) {
        [self addSubview:self.aw_progressIndicatorView];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    __block UIImageView* weakSelf = self;
    
    [self setImageWithURLRequest:request
                placeholderImage:placeholderImage
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             [weakSelf.aw_progressIndicatorView removeFromSuperview];
                             weakSelf.image = image;
                             if (imageDidAppearBlock){
                                 imageDidAppearBlock(weakSelf);
                             }
                         }
                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             [weakSelf.aw_progressIndicatorView setValue:0.0f];
                         }
           downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
               float newValue = ((float)totalBytesRead / totalBytesExpectedToRead);
               [weakSelf.aw_progressIndicatorView setValue:newValue];
    }];
}

@end

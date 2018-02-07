//
//  UIImageView+Progress.h
//  deyi
//
//  Created by tangwei1 on 16/9/8.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (AWProgress)

/**
 * Support progress loading
 */
- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(nullable UIImage *)placeholderImage
                       success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
         downloadProgressBlock:(nullable void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock;

@end

NS_ASSUME_NONNULL_END

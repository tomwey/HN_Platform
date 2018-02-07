//
//  UIImageView+Progress.m
//  deyi
//
//  Created by tangwei1 on 16/9/8.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "UIImageView+AWProgress.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import <objc/runtime.h>

@interface UIImageView (_Progress)

@property (readwrite, nonatomic, strong, setter=aw_setImageRequestOperation:) AFHTTPRequestOperation *aw_imageRequestOperation;

@end

@implementation UIImageView (_Progress)

+ (NSOperationQueue *)aw_sharedImageOperationQueue
{
    static NSOperationQueue *sharedImageOperationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageOperationQueue = [[NSOperationQueue alloc] init];
        sharedImageOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    return sharedImageOperationQueue;
}

- (void)aw_setImageRequestOperation:(AFHTTPRequestOperation *)aw_imageRequestOperation
{
    objc_setAssociatedObject(self, @selector(aw_imageRequestOperation), aw_imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AFHTTPRequestOperation *)aw_imageRequestOperation
{
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(aw_imageRequestOperation));
}

@end

@implementation UIImageView (AWProgress)

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(nullable UIImage *)placeholderImage
                       success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
         downloadProgressBlock:(nullable void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock
{
    [self cancelAWImageRequestOperation];
    
    UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
        
        self.aw_imageRequestOperation = nil;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }
        
        __weak __typeof(self)weakSelf = self;
        self.aw_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.aw_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
        [self.aw_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.aw_imageRequestOperation.request URL]]) {
                if (success) {
                    success(urlRequest, operation.response, responseObject);
                } else if (responseObject) {
                    strongSelf.image = responseObject;
                }
                
                if (operation == strongSelf.aw_imageRequestOperation){
                    strongSelf.aw_imageRequestOperation = nil;
                }
            }
            
            [[[strongSelf class] sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.aw_imageRequestOperation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }
                
                if (operation == strongSelf.aw_imageRequestOperation){
                    strongSelf.aw_imageRequestOperation = nil;
                }
            }
        }];
        
        if ( downloadProgressBlock ) {
            [self.aw_imageRequestOperation setDownloadProgressBlock:downloadProgressBlock];
        }
        
        [[[self class] aw_sharedImageOperationQueue] addOperation:self.aw_imageRequestOperation];
    }
}

- (void)cancelAWImageRequestOperation
{
    [self.aw_imageRequestOperation cancel];
    self.aw_imageRequestOperation = nil;
}

@end

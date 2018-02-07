//
//  AttachmentDownloadService.h
//  HN_ERP
//
//  Created by tomwey on 2/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentDownloadService : NSObject

@property (nonatomic, copy) void (^completionBlock)(NSURL *cachedURL, NSError *error);
@property (nonatomic, copy) void (^progressBlock)(float progress);

//- (instancetype)initWithURL:(NSString *)fileURL;
- (instancetype)initWithURL:(NSString *)fileURL;

- (void)startDownloadingToDirectory:(NSString *)dir;

- (void)stopDownloading;

+ (NSUInteger)cachedFileSize;
+ (void)removeAllCachedFiles;

@end


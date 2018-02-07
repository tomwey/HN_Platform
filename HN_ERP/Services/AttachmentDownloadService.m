//
//  AttachmentDownloadService.m
//  HN_ERP
//
//  Created by tomwey on 2/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AttachmentDownloadService.h"
#import "Defines.h"
#import "NSDataAdditions.h"

@interface AttachmentDownloadService ()

@property (nonatomic, strong) NSURL *attachmentURL;
@property (nonatomic, strong) AFHTTPRequestOperation *downloadOperation;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation AttachmentDownloadService

- (instancetype)initWithURL:(NSString *)fileURL
{
    if ( self = [super init] ) {
        self.attachmentURL = [NSURL URLWithString:fileURL];
        self.downloadQueue = [[NSOperationQueue alloc] init];
        self.downloadQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

+ (NSString *)documentsDirectory:(NSString *)dir
{
//    static NSString *documentsDir;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        
//        documentsDir = [dirs lastObject];//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    });
//    
//    if ( dir.length == 0 ) {
//        return documentsDir;
//    }
    
    NSString *newDirPath = [[self cachedFileDir] stringByAppendingPathComponent:dir];
    NSFileManager *fgr = [NSFileManager defaultManager];
    if (![fgr fileExistsAtPath:newDirPath]) {
        NSError *error = nil;
        [fgr createDirectoryAtPath:newDirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if ( error ) {
            NSLog(@"error: %@", error);
        }
    }
    return newDirPath;
}

+ (NSString *)cachedFileDir
{
    NSString *cachedDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cachedDir = [cachedDir stringByAppendingPathComponent:@"hn-files"];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:cachedDir] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachedDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachedDir;
}

+ (NSUInteger)cachedFileSize
{
    NSUInteger totalFileSize = 0;
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:[self cachedFileDir]];
    NSEnumerator *fileEnumerator = [files objectEnumerator];
    NSString *filePath;
    while ( filePath = [fileEnumerator nextObject] ) {
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self cachedFileDir] stringByAppendingPathComponent:filePath] error:nil];
        totalFileSize += [fileAttr fileSize];
    }
    
    return totalFileSize;
//    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[self cachedFileDir] error:nil];
//    return [attrs fileSize];
}

+ (void)removeAllCachedFiles
{
    [[NSFileManager defaultManager] removeItemAtPath:[self cachedFileDir] error:nil];
}

- (void)startDownloadingToDirectory:(NSString *)dir
{
//    if (!self.attachmentURL) return;
    
//    http://erp20-app.heneng.cn:16681/file/erp20-annex.heneng.cn/H_WF_INST_M/2017-03-23/409/409.xlsx
    NSString *filePath = [[[[self.attachmentURL absoluteString] componentsSeparatedByString:@"office"] lastObject] stringByDeletingLastPathComponent];
    NSLog(@"downloading file: %@", filePath);
    
//    NSString *fileDir = [NSString stringWithFormat:@"%@%@", dir ?: @"hn-files",
//                         [filePath stringByDeletingLastPathComponent]];
    
    NSString *cachedFilePath = [[[self class] documentsDirectory:[filePath stringByDeletingLastPathComponent]] stringByAppendingPathComponent:[filePath lastPathComponent]];
    
    NSLog(@"cached file: %@", cachedFilePath);
    
    BOOL existsCachedFile = [[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath];
    if ( existsCachedFile ) {
        if ( self.completionBlock ) {
            self.completionBlock([NSURL fileURLWithPath:cachedFilePath], nil);
        }
    } else {
        NSLog(@"正在下载附件: %@", cachedFilePath);
        [self startDownloading:cachedFilePath];
    }
}

- (void)startDownloading:(NSString *)cachedFile
{
    [self stopDownloading];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.attachmentURL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    __weak AttachmentDownloadService *weakSelf = self;
    self.downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //
        if ( [operation.request isEqual:request] ) {
            __strong AttachmentDownloadService *strongSelf = weakSelf;
            strongSelf.downloadOperation = nil;
            
            NSData *data = [[NSData alloc] initWithData:responseObject];
            [data writeToFile:cachedFile atomically:YES];
            
            if ( strongSelf.completionBlock ) {
                strongSelf.completionBlock([NSURL fileURLWithPath:cachedFile], nil);
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        //
        if ( [operation.request isEqual:request] ) {
            __strong AttachmentDownloadService *strongSelf = weakSelf;
            if ( strongSelf.completionBlock ) {
                strongSelf.completionBlock(nil, error);
            }
        }
    }];
    
    [self.downloadQueue addOperation:self.downloadOperation];
}

- (void)dealloc
{
    [self stopDownloading];
}

- (void)stopDownloading
{
    [self.downloadOperation cancel];
    
    self.downloadOperation = nil;
    
    [self.downloadQueue cancelAllOperations];
}

@end


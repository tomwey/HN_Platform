//
//  OfficeDocProtocol.m
//  HN_ERP
//
//  Created by tomwey on 4/1/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OfficeDocProtocol.h"
#import "Defines.h"

@interface OfficeDocProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData   *responseData;

@property (atomic, strong, readwrite) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSURLSession *session;

@property (atomic, strong, readwrite) NSThread *clientThread;
@property (atomic, copy, readwrite) NSArray *modes;

@end

static NSString * const FilteredCssKey = @"filteredCssKey";

@implementation OfficeDocProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ( [[request.URL absoluteString] hasPrefix:@"http://erp20-mobiledoc.heneng.cn/"] ) {
        if ( [NSURLProtocol propertyForKey:FilteredCssKey inRequest:request] ) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
//    NSLog(@"拦截请求：%@", request);
    NSMutableURLRequest *newRequest = [request mutableCopy];
    
    NSString *urlString = [newRequest.URL absoluteString];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"http://erp20-mobiledoc.heneng.cn/" withString:@"http://erp20-mobiledoc.heneng.cn:16665/"];
    NSURL *newUrl = [NSURL URLWithString:urlString];
//    NSLog(@"new url: %@", newUrl);
    newRequest.URL = newUrl;
    return newRequest;
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    
    [NSURLProtocol setProperty:@YES forKey:FilteredCssKey inRequest:newRequest];
    
//    self.connection =
//        [NSURLConnection connectionWithRequest:newRequest   delegate:self];
    
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    self.session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
    self.task  = [self.session dataTaskWithRequest:newRequest];
    [self.task resume];
}

- (void)stopLoading
{
    [self.session invalidateAndCancel];
    self.session = nil;
    
//    if ( self.connection != nil ) {
//        [self.connection cancel];
//        self.connection = nil;
//    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil) {
        [self.client URLProtocol:self didFailWithError:error];
    }else
    {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler
{
    completionHandler(proposedResponse);
}

#pragma mark- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

@end

#import <WebKit/WebKit.h>

/**
 * The functions below use some undocumented APIs, which may lead to rejection by Apple.
 */

FOUNDATION_STATIC_INLINE Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    }
    return cls;
}

FOUNDATION_STATIC_INLINE SEL RegisterSchemeSelector() {
    return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
}

FOUNDATION_STATIC_INLINE SEL UnregisterSchemeSelector() {
    return NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
}

@implementation NSURLProtocol (WebKitSupport)

+ (void)wk_registerScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = RegisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

+ (void)wk_unregisterScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = UnregisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

@end


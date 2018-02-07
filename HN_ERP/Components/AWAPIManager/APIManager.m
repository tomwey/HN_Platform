//
//  APIManager.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "APIManager.h"
#import "AFNetworking.h"

@interface APIManager ()

@property (nonatomic, retain, readwrite) id rawData;

@property (nonatomic, retain, readwrite) APIError* apiError;
@property (nonatomic, retain, readwrite) APIRequest* apiRequest;

@property (nonatomic, assign, readwrite) BOOL loading;

/** 请求管理器对象 */
@property (nonatomic, retain) AFHTTPRequestOperationManager* requestManager;

@end

@implementation APIManager

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Lifecycle Methods
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDelegate:(id <APIManagerDelegate>)aDelegate
{
    if ( self = [super init] ) {
        self.delegate = aDelegate;
        self.loading  = NO;
    }
    return self;
}

+ (instancetype)apiManagerWithDelegate:(id <APIManagerDelegate>)aDelegate
{
    return [[[self class] alloc] initWithDelegate:aDelegate];
}

- (void)dealloc
{
    self.rawData = nil;
    self.apiError = nil;
    self.apiConfig = nil;
    self.apiRequest = nil;
    
    [self.requestManager.operationQueue cancelAllOperations];
    self.requestManager = nil;
    
//    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
//////////////////////////////////////////////////////////////////////////////////////////
- (void)startRequest
{
    [self log:@"请求开始..."];
    
    self.loading = YES;
    
    if ( [self.delegate respondsToSelector:@selector(apiManagerDidStart:)] ) {
        [self.delegate apiManagerDidStart:self];
    }
}

- (void)finishRequesting
{
    [self log:@"请求结束..."];
    
    self.loading = NO;
    
    if ( [self.delegate respondsToSelector:@selector(apiManagerDidFinish:)] ) {
        [self.delegate apiManagerDidFinish:self];
    }
}

- (void)sendRequest:(APIRequest *)aRequest
{
    if ( !self.requestManager ) {
        self.requestManager = [AFHTTPRequestOperationManager manager];
        
        // 设置超时时间
        [self.requestManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.requestManager.requestSerializer.timeoutInterval = 15.f;
        [self.requestManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    
    // 取消所有请求
    [self.requestManager.operationQueue cancelAllOperations];
    
    self.apiRequest = aRequest;
    
    // 请求开始
    [self startRequest];
    
    // 发出请求
    switch (aRequest.requestMethod) {
        case RequestMethodGet:
            [self doGet];
            break;
        case RequestMethodPost:
            [self doPost];
            break;
        case RequestMethodPut:
            [self doPut];
            break;
        case RequestMethodDelete:
            [self doDelete];
            break;
            
        default:
            [self log:@"暂时不支持该请求"];
            break;
    }
}

- (void)sendRequest:(APIRequest *)aRequest delegate:(id <APIManagerDelegate>)delegate
{
    self.delegate = delegate;
    [self sendRequest:aRequest];
}

- (void)cancelRequest
{
    [self.requestManager.operationQueue cancelAllOperations];
    self.requestManager = nil;
}

- (id)fetchDataWithReformer:(id <APIReformer>)reformer
{
    if ( !reformer ) {
        return self.rawData;
    }
    return [reformer reformDataWithManager:self];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
//////////////////////////////////////////////////////////////////////////////////////////
- (void)doGet
{
    // 解析URL
    NSString* requestUrl = [self buildUrlForRequest:self.apiRequest];
    [self log:[NSString stringWithFormat:@"URL: %@", requestUrl]];
    
    __block APIManager* me = self;
    [self.requestManager GET:requestUrl parameters:self.apiRequest.params
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [me handleSuccess:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [me handleFailure:error];
    }];
}

- (void)doPost
{
    // 解析URL
    NSString* requestUrl = [self buildUrlForRequest:self.apiRequest];
    [self log:[NSString stringWithFormat:@"URL: %@", requestUrl]];
    
    __block APIManager* me = self;
    if ( [self.apiRequest.fileParams count] == 0 ) {
        // 普通POST请求
        [self.requestManager POST:requestUrl
                       parameters:self.apiRequest.params
                          success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [me handleSuccess:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [me handleFailure:error];
        }];
    } else {
        // 带文件的POST请求
        [self.requestManager POST:requestUrl parameters:self.apiRequest.params
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
        {
            // 组装文件参数
            for (APIFileParam* fileParam in me.apiRequest.fileParams) {
                [formData appendPartWithFileData:fileParam.fileData
                                            name:fileParam.name
                                        fileName:fileParam.fileName
                                        mimeType:fileParam.mimeType];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [me handleSuccess:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [me handleFailure:error];
        }];
    }
}

- (void)doPut
{
    [self log:@"暂时未支持PUT请求"];
}

- (void)doDelete
{
    [self log:@"暂时未支持DELETE请求"];
}

- (void)handleSuccess:(id)responseObject
{
    if ( [responseObject isKindOfClass:[NSDictionary class]] &&
        [responseObject objectForKey:@"code"] ) { // 如果是带有此种json数据结构，需要处理服务器逻辑错误
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if ( code != 0 ) {
            if ( [self.delegate respondsToSelector:@selector(apiManagerDidFailure:)] ) {
                self.apiError = [APIError apiErrorWithCode:code message:[responseObject objectForKey:@"message"]];
                [self.delegate apiManagerDidFailure:self];
            }
            [self finishRequesting];
            return;
        }
    }
    
    self.rawData = responseObject;
    
    if ( [self.delegate respondsToSelector:@selector(apiManagerDidSuccess:)] ) {
        [self.delegate apiManagerDidSuccess:self];
    }
    
    [self finishRequesting];
}

- (void)handleFailure:(NSError *)error
{
    self.rawData = nil;
    self.apiError = [APIError apiErrorWithCode:error.code message:[error localizedDescription]];
    
    if ( [self.delegate respondsToSelector:@selector(apiManagerDidFailure:)] ) {
        [self.delegate apiManagerDidFailure:self];
    }
    
    [self finishRequesting];
}

- (NSString *)buildUrlForRequest:(APIRequest *)aRequest
{
    APIConfig* config = self.apiConfig;
    if ( !config ) {
        config = [APIConfig sharedInstance];
    }
    
    // 处理请求接口
    NSMutableArray* temp = [NSMutableArray array];
    NSArray* uriParitals = [aRequest.uri componentsSeparatedByString:@"/"];
    for (NSString* parital in uriParitals) {
        if ( parital.length > 0 ) {
            [temp addObject:parital];
        }
    }
    
    // 处理服务器地址最后的“/”
    NSString* server = config.currentServer;
    if ( [server hasSuffix:@"/"] ) {
        server = [server substringToIndex:server.length - 1];
    }
    
    return [NSString stringWithFormat:@"%@/%@", server, [temp componentsJoinedByString:@"/"]];
}

- (void)log:(NSString *)msg
{
#if DEBUG
    NSLog(@"%@", msg);
#endif
}

@end

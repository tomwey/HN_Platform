//
//  RTIDataService.m
//  RTA
//
//  Created by tangwei1 on 16/10/25.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "APIService.h"
#import "Defines.h"

@implementation APIServiceConfig

+ (instancetype)defaultConfig
{
    static APIServiceConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APIServiceConfig alloc] init];
    });
    return instance;
}

@end

@interface APIService ()

@property (nonatomic, strong) NSMutableDictionary *requestTasks;

@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

@property (nonatomic, strong) void (^postCallback)(id result, NSError *error);

@end

@implementation APIService

- (APIServiceConfig *)apiConfig
{
    if ( !_apiConfig ) {
        _apiConfig = [APIServiceConfig defaultConfig];
    }
    return _apiConfig;
}

- (NSUInteger)GET:(NSString *)uri
     params:(NSDictionary *)params
 completion:(void (^)(id result, NSError *error))completion
{
    return 0;
}

- (NSUInteger)POST:(NSString *)uri
            params:(NSDictionary *)params
        completion:(void (^)(id result, NSError *error))completion
{
    self.postCallback = completion;
    
    [self cancelAllRequests];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[self createPOSTRequest:uri params:params]
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error) {
//                                                    NSLog(@"result: %@, error: %@", response, error);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if ( error ) {
                                                            [self handleError:error];
                                                        } else {
                                                            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                                                            if ( resp.statusCode == 200 ||
                                                                resp.statusCode  == 201 ) {
                                                                [self parseData:data];
                                                            } else {
                                                                // 可能不会执行
                                                                [self handleError:error];
                                                            }
                                                        }
                                                        
                                                        [self.requestTasks removeObjectForKey:@([dataTask taskIdentifier])];
                                                    });
                                                }];
    
    [dataTask resume];
    
    NSUInteger taskId = [dataTask taskIdentifier];
    
    self.requestTasks[@(taskId)] = dataTask;
    
    return taskId;
}

- (NSUInteger)POST2:(NSString *)uri
             params:(NSDictionary *)params
         completion:(void (^)(id result, NSError *error))completion
{
    self.postCallback = completion;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_HOST, uri]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    //    @{ @"lng": @"104.321233", @"lat": @"30.098123" }
    request.HTTPBody = [stringByParams(params) dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error) {
                                                    //                                                    NSLog(@"result: %@, error: %@", response, error);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if ( error ) {
                                                            [self handleError:error];
                                                        } else {
                                                            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                                                            if ( resp.statusCode == 200 ) {
                                                                [self parseData:data];
                                                            } else {
                                                                if ( resp.statusCode == 202 ) {
                                                                    NSError *inError = [NSError errorWithDomain:@"参数异常" code:-202 userInfo:nil];
                                                                    [self handleError:inError];
                                                                } else {
                                                                    [self handleError:error];
                                                                }
                                                            }
                                                        }
                                                        
                                                        [self.requestTasks removeObjectForKey:@([dataTask taskIdentifier])];
                                                    });
                                                }];
    
    [dataTask resume];
    
    NSUInteger taskId = [dataTask taskIdentifier];
    
    self.requestTasks[@(taskId)] = dataTask;
    
    return taskId;
}

- (void)handleResult: (NSData *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsonResult = [jsonResult substringWithRange:NSMakeRange(1, jsonResult.length - 2)];
        jsonResult = [jsonResult stringByReplacingOccurrencesOfString:@"\\"
                                                           withString:@""];
        
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[jsonResult dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( error ) {
                [self handleError:error];
            } else {
                if ( self.postCallback ) {
                    self.postCallback(result, nil);
                }
            }
        });
    });
}

- (void)handleError:(NSError *)error
{
    NSLog(@"\n-------------------- 返回失败 --------------------\n%@\n-------------------- 返回失败 --------------------", error);
    if ( self.postCallback ) {
        self.postCallback(nil, error);
    }
}

- (void)parseData:(NSData *)data
{
    NSError *jsonError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//    NSLog(@"text: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if ( jsonError ) {
        [self handleError:jsonError];
    } else {
        NSInteger code = [result[@"code"] integerValue];
        if ( code == 0 ) {
            NSLog(@"\n-------------------- 返回成功 --------------------\n%@\n-------------------- 返回成功 --------------------", result);
            
            if ( self.postCallback ) {
                self.postCallback(result, nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:result[@"codemsg"] code:code userInfo:nil];
            [self handleError:error];
        }
    }
}

- (NSMutableURLRequest *)createPOSTRequest:(NSString *)uri params:(NSDictionary *)params
{
    NSAssert(!!self.apiConfig, @"API服务接口没有配置");
    
    uri = uri.length == 0 ? @"" : uri;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
                                       self.apiConfig.apiServer, uri]];
    
    NSLog(@"\n-------------------- 请求信息 --------------------\n请求地址：%@ \n请求方式：POST \n请求参数：\n%@\n-------------------- 请求信息 --------------------", url, params);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
//    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    //    @{ @"lng": @"104.321233", @"lat": @"30.098123" }
//    request.HTTPBody = [AESEncryptStringFromParams(params) dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if ( params ) {
        NSError *error = nil;
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        if ( !error ) {
            request.HTTPBody = data;
        }
    }
    
    return request;
}

- (void)cancelAllRequests
{
    for (id key in self.requestTasks) {
        NSURLSessionTask *task = self.requestTasks[key];
        [task cancel];
    }
    [self.requestTasks removeAllObjects];
}

- (void)cancelRequestForTaskId:(NSUInteger)taskId
{
    NSURLSessionTask *task = self.requestTasks[@(taskId)];
    [task cancel];
    [self.requestTasks removeObjectForKey:@(taskId)];
}

- (NSMutableDictionary *)requestTasks
{
    if ( !_requestTasks ) {
        _requestTasks = [[NSMutableDictionary alloc] init];
    }
    return _requestTasks;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    if ( !_sessionConfiguration ) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfiguration;
}

@end

#import <objc/runtime.h>

@implementation NSObject (APIServiceCreator)

static char kNetworkAPIServiceKey;

- (id <APIServiceProtocol>)apiServiceWithName:(NSString *)apiServiceName
{
    id obj = objc_getAssociatedObject(self, &kNetworkAPIServiceKey);
    if ( !obj ) {
        obj = [[NSClassFromString(apiServiceName) alloc] init];
        if ( [obj conformsToProtocol:@protocol(APIServiceProtocol)] == NO ) {
            NSLog(@"API Service 必须要实现APIServiceProtocol");
            return nil;
        }
        objc_setAssociatedObject(obj,
                                 &kNetworkAPIServiceKey,
                                 obj,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return (id <APIServiceProtocol>)obj;
}

@end

//
//  RTIDataService.m
//  RTA
//
//  Created by tangwei1 on 16/10/25.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "RTIDataService.h"
#import "ParamUtil.h"
#import "Defines.h"

@interface RTIDataService ()

@property (nonatomic, strong) NSMutableDictionary *requestTasks;

@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

@property (nonatomic, strong) void (^postCallback)(id result, NSError *error);

@end

@implementation RTIDataService

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
                                                            if ( resp.statusCode == 200 ) {
                                                                if ( [uri isEqualToString:@"GetGdmp"] ) {
                                                                    // 蛋疼的后台
                                                                    [self handleResult:data];
                                                                } else {
                                                                    [self parseData:data];
                                                                }
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
        NSLog(@"------------------- 返回成功 -------------------\n%@\n%@", result, result[@"resultdes"]);
        NSInteger code = [result[@"status"] integerValue];
        if ( code == 101 ) {
            if ( self.postCallback ) {
                self.postCallback(result, nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:result[@"resultdes"] code:code userInfo:nil];
            [self handleError:error];
        }
    }
}

- (NSMutableURLRequest *)createPOSTRequest:(NSString *)uri params:(NSDictionary *)params
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
                                       API_HOST, uri]];
    
    NSLog(@"\n请求地址：%@ \n请求参数：%@", url, params);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    //    @{ @"lng": @"104.321233", @"lat": @"30.098123" }
    request.HTTPBody = [AESEncryptStringFromParams(params) dataUsingEncoding:NSUTF8StringEncoding];
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

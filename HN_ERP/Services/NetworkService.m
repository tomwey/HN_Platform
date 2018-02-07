//
//  NetworkService.m
//  deyi
//
//  Created by tomwey on 9/4/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "NetworkService.h"
#import "Defines.h"

@interface NetworkService () <APIManagerDelegate>

@property (nonatomic, strong) APIManager *getAPIManager;
@property (nonatomic, strong) APIManager *postAPIManager;

@property (nonatomic, copy) void (^getResultCallback)(id result, NSError *error);
@property (nonatomic, copy) void (^postResultCallback)(id result, NSError *error);

@end
@implementation NetworkService

+ (void)load
{
    [APIConfig sharedInstance].stageServer = API_HOST;
    [APIConfig sharedInstance].productionServer = API_HOST;
    
#if DEBUG
    [[APIConfig sharedInstance] setDebugMode:YES];
#else
    [[APIConfig sharedInstance] setDebugMode:NO];
#endif
}

- (void)dealloc
{
    [self.getAPIManager cancelRequest];
    [self.postAPIManager cancelRequest];
    
    self.getResultCallback = nil;
    self.postResultCallback = nil;
    
    self.getAPIManager.delegate = nil;
    self.postAPIManager.delegate = nil;
}

- (void)GET:(NSString *)uri
     params:(NSDictionary *)params
 completion:(void (^)(id result, NSError *error))completion
{
    self.getResultCallback = completion;
    
    if ( !self.getAPIManager ) {
        self.getAPIManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    [self.getAPIManager sendRequest:APIRequestCreate(uri, RequestMethodGet, params)];
}

- (void)POST:(NSString *)uri
      params:(NSDictionary *)params
  completion:(void (^)(id result, NSError *error))completion
{
    self.postResultCallback = completion;
    
    if ( !self.postAPIManager ) {
        self.postAPIManager = [[APIManager alloc] initWithDelegate:self];
    }
    
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    NSMutableArray *fileParams = [NSMutableArray array];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [obj isKindOfClass:[NSData class]] ) {
            APIFileParam *param = [[APIFileParam alloc] initWithFileData:obj
                                                                    name:key
                                                                fileName:[NSString stringWithFormat:@"%@.jpg",key]
                                                                mimeType:@"image/jpeg"];
            [fileParams addObject:param];
        } else {
            [newParams setObject:obj forKey:key];
        }
    }];
    
    APIRequest *request = APIRequestCreate(uri, RequestMethodPost, nil);
    request.params = newParams;
    if ( [fileParams count] > 0 ) {
        request.fileParams = fileParams;
    }
    [self.postAPIManager sendRequest:request];
}

/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager
{
    id result = [manager fetchDataWithReformer:nil];
    if ( manager == self.getAPIManager ) {
        if ( self.getResultCallback ) {
            self.getResultCallback(result, nil);
        }
    } else if ( manager == self.postAPIManager ) {
        if ( self.postResultCallback ) {
            self.postResultCallback(result, nil);
        }
    }
}

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager
{
    NSError *error = [NSError errorWithDomain:manager.apiError.message
                                         code:manager.apiError.code
                                     userInfo:nil];
    
    if ( manager == self.getAPIManager ) {
        if ( self.getResultCallback ) {
            self.getResultCallback(nil, error);
        }
    } else if ( manager == self.postAPIManager ) {
        if ( self.postResultCallback ) {
            self.postResultCallback(nil, error);
        }
    }
}

@end

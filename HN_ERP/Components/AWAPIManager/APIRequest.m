//
//  APIRequest.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "APIRequest.h"

@interface APIRequest ()

@property (nonatomic, retain) NSMutableArray* realFileParams;

@end

@implementation APIRequest

@dynamic fileParams;

- (instancetype)initWithURI:(NSString *)uri method:(RequestMethod)method params:(NSDictionary *)params
{
    if ( self = [super init] ) {
        self.uri = uri;
        self.requestMethod = method;
        self.params = params;
        
        // 初始化一个空的数组来保存文件参数
        self.realFileParams = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)requestWithURI:(NSString *)uri method:(RequestMethod)method params:(NSDictionary *)params
{
    return [[APIRequest alloc] initWithURI:uri method:method params:params];
}

- (void)dealloc
{
    self.uri = nil;
    self.params = nil;
    self.realFileParams = nil;
    
//    [super dealloc];
}

- (void)addFileParam:(APIFileParam *)fileParam
{
    if ( fileParam ) {
        [self.realFileParams addObject:fileParam];
    }
}

- (void)setFileParams:(NSArray *)fileParams
{
    [self.realFileParams removeAllObjects];
    
    if ( fileParams ) {
        [self.realFileParams addObjectsFromArray:fileParams];
    }
}

- (NSArray *)fileParams
{
    return [NSArray arrayWithArray:self.realFileParams];
}

- (NSString *)HTTPMethod
{
    switch (self.requestMethod) {
        case RequestMethodGet:
            return @"GET";
        case RequestMethodPost:
            return @"POST";
        case RequestMethodPut:
            return @"PUT";
        case RequestMethodDelete:
            return @"DELETE";
            
        default:
            break;
    }
    
    return nil;
}

@end

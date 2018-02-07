//
//  APIEntityReformer.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "APIEntityReformer.h"
#import "APIManager.h"

@implementation APIEntityReformer

- (id)reformDataWithManager:(APIManager *)manager
{
    id responseObject = manager.rawData;
    
    NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"格式转化器与返回的json数据不一致");
    
    id resultData = [responseObject objectForKey:@"data"];
    
    if ( [resultData isKindOfClass:[NSDictionary class]] ) {
        return [self parseDict:resultData];
    } else if ( [resultData isKindOfClass:[NSArray class]] ) {
        return [self parseArray:resultData];
    }
    
    // 返回原始数据
    return manager.rawData;
}

- (id)parseDict:(id)result
{
    return [NSDictionary dictionaryWithDictionary:result];
}

- (id)parseArray:(id)result
{
    return [NSArray arrayWithArray:result];
}

@end

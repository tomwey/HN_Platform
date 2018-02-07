//
//  APIRequest.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFileParam.h"

/*****************************************************
 封装了请求对象
 *****************************************************/

/** 定义请求方法类型，与HTTP请求方法一一对应 */
typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethodGet,     // 对应 HTTP GET 请求
    RequestMethodPost,    // 对应 HTTP POST 请求
    RequestMethodPut,     // 对应 HTTP PUT 请求
    RequestMethodDelete,  // 对应 HTTP DELETE 请求
    // 其它请求方式待续...
};

@interface APIRequest : NSObject

/** 设置接口名字，例如：/xxx/yyy.json */
@property (nonatomic, copy) NSString* uri;

/** 设置请求方式 */
@property (nonatomic, assign) RequestMethod requestMethod;

/** 设置普通的请求参数 */
@property (nonatomic, retain) NSDictionary* params;

/** 设置文件参数，数组里面存储的是APIFileParam对象 */
@property (nonatomic, retain) NSArray* fileParams;

/** 返回与HTTP对应的请求方法 */
@property (nonatomic, copy, readonly) NSString* HTTPMethod;

- (instancetype)initWithURI:(NSString *)uri method:(RequestMethod)method params:(NSDictionary *)params;
+ (instancetype)requestWithURI:(NSString *)uri method:(RequestMethod)method params:(NSDictionary *)params;

/** 
 * 添加文件参数
 */
- (void)addFileParam:(APIFileParam *)fileParam;

@end

/** 快速创建一个自动释放的请求对象 */
static inline APIRequest* APIRequestCreate(NSString* uri, RequestMethod method, NSDictionary* params){
    return [APIRequest requestWithURI:uri method:method params:params];
};

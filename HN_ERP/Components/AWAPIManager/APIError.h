//
//  APIError.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIError : NSObject

/** 设置错误状态码 */
@property (nonatomic, assign) NSInteger code;

/** 设置错误消息 */
@property (nonatomic, copy) NSString* message;

- (instancetype)initWithCode:(NSInteger)code message:(NSString *)message;
+ (instancetype)apiErrorWithCode:(NSInteger)code message:(NSString *)message;

@end


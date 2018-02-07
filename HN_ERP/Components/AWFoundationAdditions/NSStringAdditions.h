//
//  NSStringAdditions.h
//  Cute&Funny
//
//  Created by tangwei1 on 15-4-17.
//  Copyright (c) 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (AWCategory)

/**
 * 判断是否该字符串仅仅包含空白字符和换行符
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 * 判断字符串是否为空字符或者仅仅包含空白字符
 */
- (BOOL)isEmptyOrWhitespace;

/**
 * 解析一个URL的查询字符串到一个字典
 */
- (NSDictionary *)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

/**
 * 解析URL, 添加查询参数并重新编码为一个新URL
 */
- (NSString *)stringByAddingQueryDictionary:(NSDictionary *)query;

/**
 * URL 编码
 */
- (NSString *)URLEncode;

/**
 * 去除首尾的空格以及回车符
 */
- (NSString *)trim;

/**
 * 比较两个字符串系统版本号
 * 
 * 例如
 *  "3.0" = "3.0"
 *  "3.1" > "3.0"
 *  "3.0.2" < "3.0.3"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)otherVersionString;

/**
 * 检查字符串是否匹配一个正则表达式
 */
- (BOOL)matches:(NSString *)regex;

/**
 * 计算文本的大小
 */
- (CGSize)sizeWithFont:(UIFont *)font inConstraintSize:(CGSize)size;

@end

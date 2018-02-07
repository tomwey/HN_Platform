//
//  NSStringAdditions.m
//  Cute&Funny
//
//  Created by tangwei1 on 15-4-17.
//  Copyright (c) 2015年 tangwei1. All rights reserved.
//

#import "NSStringAdditions.h"

@implementation NSString (AWCategory)

/**
 * 判断是否该字符串仅仅包含空白字符和换行符
 */
- (BOOL)isWhitespaceAndNewlines
{
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if ( ![whitespace characterIsMember:c] ) {
            return NO;
        }
    }
    return YES;
}

/**
 * 判断字符串是否为空字符或者仅仅包含空白字符
 */
- (BOOL)isEmptyOrWhitespace
{
    return !self.length ||
           ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

/**
 * 解析一个URL的查询字符串到一个字典
 */
- (NSDictionary *)queryDictionaryUsingEncoding:(NSStringEncoding)encoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while ( ![scanner isAtEnd] ) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if ( kvPair.count == 2 ) {
            NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKeyedSubscript:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

/**
 * 解析URL, 添加查询参数并重新编码为一个新URL
 */
- (NSString *)stringByAddingQueryDictionary:(NSDictionary *)query
{
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [query keyEnumerator]) {
        NSString* value = [query objectForKey:key];
        value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
        value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
        [pairs addObject:pair];
    }
    
    NSString* params = [pairs componentsJoinedByString:@"&"];
    if ( [self rangeOfString:@"?"].location == NSNotFound ) {
        return [self stringByAppendingFormat:@"?%@", params];
    } else {
        return [self stringByAppendingFormat:@"&%@", params];
    }
}

- (NSString *)URLEncode
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                              NULL,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                              kCFStringEncodingUTF8));
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 * 比较两个字符串系统版本号
 *
 * 例如
 *  "3.0" = "3.0"
 *  "3.1" > "3.0"
 *  "3.0.2" < "3.0.3"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)otherVersionString
{
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [otherVersionString componentsSeparatedByString:@"a"];
    
    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];
    
    // If main parts are different, return that result, regardless of alpha part
    NSComparisonResult mainDiff;
    if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
        return mainDiff;
    }
    
    // At this point the main parts are the same; just deal with alpha stuff
    // If one has an alpha part and the other doesn't, the one without is newer
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;
    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;
    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }
    
    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

- (BOOL)matches:(NSString *)regex
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ( [predicate evaluateWithObject:self] ) {
        return YES;
    }
    return NO;
}

- (CGSize)sizeWithFont:(UIFont *)font inConstraintSize:(CGSize)size
{
    CGSize boundingBox = [self boundingRectWithSize:size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:NULL].size;
    
    CGSize newSize = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return newSize;
}

@end

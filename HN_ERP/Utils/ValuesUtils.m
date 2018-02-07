//
//  ValuesUtils.m
//  HN_ERP
//
//  Created by tomwey on 3/3/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ValuesUtils.h"

NSString *HNStringFromObject(id obj, NSString *defaultValue)
{
    NSString *defaultVal = defaultValue ?: @"无";
    
    if ( !obj ) {
        return defaultVal;
    }
    
    NSString *val = [obj description];
    if ( [val isEqualToString:@""] ||
        [val isEqualToString:@"NULL"]) {
        return defaultVal;
    }
    
    return val;
}

NSString *HNFormatMoney(id obj, NSString *unit)
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSLocale *zhLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    nf.locale = zhLocale;
    
    float num = [obj floatValue];
    
    NSString *prefix = @"";
    if ( num < 0 ) {
        prefix = @"-";
        num = ABS(num);
    }
    
    NSString *str;
    if ([unit isEqualToString:@"万"]) {
        str = [[nf stringFromNumber:@(num / 10000.0)] stringByAppendingString:@"万"];
    } else {
        str = [[nf stringFromNumber:@(num)] stringByAppendingString:@"元"];
    }
    
    str = [str substringFromIndex:1];
    
    return [NSString stringWithFormat:@"%@%@", prefix, str];
}

NSString *HNFormatMoney2(id obj, NSString *unit)
{
    NSString *str = HNFormatMoney(obj, unit);
    str = [[str componentsSeparatedByString:@"."] firstObject];
    
    if ([str isEqualToString:@"0"]) {
        return @"0.00";
    }
    
    return str;
}

NSString *HNFormatMoney3(id obj, NSString *unit)
{
    NSString *str = HNFormatMoney(obj, unit);
    str = [str substringToIndex:str.length - 1];
    
    str = [str stringByReplacingOccurrencesOfString:@".00" withString:@""];
    
    if ([str isEqualToString:@"0"]) {
        return @"0.00";
    }
    
    return str;
//    return str;
}

NSInteger HNIntegerFromObject(id obj, NSInteger defaultValue)
{
    if ( !obj ) {
        return defaultValue ?: 0;
    }
    
    return [obj integerValue];
}

float HNFloatFromObject(id obj, float defaultValue)
{
    if ( !obj ) {
        return defaultValue;
    }
    
    if ( [[obj description] isEqualToString:@"NULL"] ) {
        return defaultValue;
    }
    
    return [obj floatValue];
}

BOOL HNBoolFromObject(id obj, BOOL defaultValue)
{
    if ( !obj ) {
        return defaultValue;
    }
    
    return [obj boolValue];
}

NSString *HNDateFromObject(id obj, NSString *splitor)
{
    if (!obj) return @"0000-00-00";
    NSString *date = [obj description];
    if ( [date isEqualToString:@"NULL"] || date.length == 0 ) {
        return @"无";//@"0000-00-00";
    }
    
    return [[[date componentsSeparatedByString:splitor] firstObject] description];
}
NSString *HNDateTimeFromObject(id obj, NSString *splitor)
{
    if (!obj) return @"0000-00-00 00:00:00";
    NSString *dateTime = [obj description];
    if ( [dateTime isEqualToString:@"NULL"] || dateTime.length == 0 ) {
        return @"0000-00-00 00:00:00";
    }
    
    dateTime = [dateTime stringByReplacingOccurrencesOfString:splitor withString:@" "];
    dateTime = [dateTime substringToIndex:19];
    return dateTime;
}

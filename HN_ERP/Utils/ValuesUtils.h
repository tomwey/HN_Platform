//
//  ValuesUtils.h
//  HN_ERP
//
//  Created by tomwey on 3/3/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *HNStringFromObject(id obj, NSString *defaultValue);

NSInteger HNIntegerFromObject(id obj, NSInteger defaultValue);

float HNFloatFromObject(id obj, float defaultValue);

BOOL HNBoolFromObject(id obj, BOOL defaultValue);

NSString *HNDateFromObject(id obj, NSString *splitor);
NSString *HNDateTimeFromObject(id obj, NSString *splitor);

NSString *HNFormatMoney(id obj, NSString *unit);

NSString *HNFormatMoney2(id obj, NSString *unit);

NSString *HNFormatMoney3(id obj, NSString *unit);

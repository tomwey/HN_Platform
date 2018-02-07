//
//  RulesSearchVC.m
//  HN_ERP
//
//  Created by tomwey on 4/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "RulesSearchVC.h"

@interface RulesSearchVC ()

@end

@implementation RulesSearchVC

- (NSArray *)formControls
{
    return @[@{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"制度类型",
                 @"field_name": @"rule_type",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"制度名称",
                 @"field_name": @"rule_name",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             ];
}

@end

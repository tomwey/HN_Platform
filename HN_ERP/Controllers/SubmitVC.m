//
//  SubmitVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SubmitVC.h"
#import "Defines.h"

@interface SubmitVC ()

@end

@implementation SubmitVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navBar.title = @"提交流程";
}

- (NSArray *)formControls
{
    NSMutableArray *array = [self.params[@"audits"] mutableCopy];
    
    if ( [self hasRequests] ) {
        for (id dict in self.params[@"requests"]) {
            [array addObject:@{
                               @"data_type": @"17",
                               @"datatype_c": @"请示批复组件",
                               @"describe": dict[@"itemname"] ?: @"",
                               @"field_name": [dict[@"did"] description] ?: @"request",
                               @"item_name": @"",
                               @"item_value": @"",
                               }];
        }
    } else {
        if ([self.params[@"node_type"] isEqualToString:@"2"] ||
            [self.params[@"node_type"] isEqualToString:@"3"]) {
            // 加一个控件
            [array insertObject:@{
                                  @"data_type": @"14",
                                  @"datatype_c": @"单选按钮",
                                  @"describe": @"是否同意",
                                  @"field_name": @"agree",
                                  @"item_name": @"同意,不同意",
                                  @"item_value": @"1,0",
                                  } atIndex:0];
        }
    }
    
    return [array copy];
}

- (BOOL)hasRequests
{
    if ([self.params[@"requests"] isKindOfClass:[NSArray class]] &&
        [self.params[@"requests"] count] > 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)supportsTextArea
{
    return ![self hasRequests];
}

- (BOOL)supportsCustomOpinion
{
    return ![self hasRequests];
}

- (BOOL)supportsAttachment
{
    return ![self hasRequests];
}

- (NSDictionary *)apiParams
{
//    NSMutableArray *temp = [NSMutableArray array];
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    
//    {
//        "data_type": "1",
//        "datatype_c": "文本",
//        "describe": "备注2",
//        "field_name": "T20",
//        "item_name": "",
//        "item_value": "",
//        "recno": 0
//    }
    
    // 审批要素
    for (id dict in self.params[@"audits"]) {
//        NSLog(@"%@ -> %@", key, self.formObjects[key]);
        NSString *key = [dict[@"field_name"] description];
        
        id value = self.formObjects[key];
        
        if (value) {
            if ( [value isKindOfClass:[NSDate class]] ) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd";
                value = [df stringFromDate:value];
            } else if ( [value isKindOfClass:[NSDictionary class]] ) {
                value = [[[value allValues] firstObject] description];
            }
            
            [temp setObject:value forKey:key];
        }
    }
    
    // 请示批复
    BOOL agree = YES;
    BOOL agreeSet = YES;
    BOOL hasDisagreeOp = YES;
    NSMutableDictionary *req = [NSMutableDictionary dictionary];
    for (id dict in self.params[@"requests"]) {
        NSString *key = [dict[@"did"] description];
        NSString *isAgree = @"";
        if ( [self.formObjects[[NSString stringWithFormat:@"%@.agree",key]] description].length > 0 ) {
            isAgree = [self.formObjects[[NSString stringWithFormat:@"%@.agree",key]] boolValue] ? @"同意" : @"不同意";
        }
        
        NSString *memo = self.formObjects[key];
        
        if ( [isAgree isEqualToString:@"不同意"] ) {
            hasDisagreeOp &= [memo length] > 0; // 是否有不同意意见
        }
        
        NSDictionary *val = @{
                              @"isagree": isAgree,
                              @"memo": memo ?: @"",
                              };
        [req setObject:val forKey:key];
        
        agree &= [self.formObjects[[NSString stringWithFormat:@"%@.agree",key]] boolValue];
        agreeSet &= isAgree.length > 0;
    }
    
    if ([self hasRequests]) {
        if (agreeSet) {
            self.formObjects[@"agree"] = agree ? @"1" : @"0";
            // 如果所有的不同意选项都有意见，那么就🙆设置一个不同意，否则留空，然后客户端提示没有输入不同意意见
            NSString *disagreeOp = hasDisagreeOp ? @"不同意。" : @"";
            self.formObjects[@"opinion"] = agree ? @"同意。" : disagreeOp;
        } else {
            self.formObjects[@"agree"] = @"";
            self.formObjects[@"opinion"] = @"";
        }
    }
    
    return @{
             @"dotype": @"flow",
             @"type": @"submit",
             @"audit": [temp copy],
             @"request": [req copy],
             @"agree": self.formObjects[@"agree"] ?: @"-1",
             @"opinion_allow_null": self.params[@"opinion_allow_null"],
             };
}

@end

//
//  TransmitVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "TransmitVC.h"
#import "Defines.h"

@interface TransmitVC ()

@end

@implementation TransmitVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSArray *)formControls
{
    return @[@{
                 @"data_type": @"6",
                 @"datatype_c": @"添加多人",
                 @"describe": @"接收人",
                 @"field_name": @"contacts",
                 @"item_name": @"",
                 @"item_value": @"",
                 }];
}

- (NSDictionary *)apiParams
{
    //    mid(流程ID值), nodeid(节点ID), manid(操作人员ID), getmanids(接收者IDs,  中间以','号间隔), getmannames(接收者名称s, 中间以','号间隔), opinion(意见)
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *ids  = [NSMutableArray array];
    for (id item in self.formObjects[@"contacts"]) {
        [temp addObject:[item name]];
        [ids addObject:[[item _id] description]];
    }
    return @{
             @"dotype": @"flow",
             @"type": @"transmit",
             @"nodeid": self.params[@"nodeid"],
             @"getmanids": [ids componentsJoinedByString:@","],
             @"getmannames": [temp componentsJoinedByString:@","],
             @"opinion_allow_null": self.params[@"opinion_allow_null"],
             };
}

@end

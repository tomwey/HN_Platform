//
//  BackVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BackVC.h"
#import "Defines.h"

@interface BackVC ()

//@property (nonatomic, strong) UISwitch   *onOff;

@end

@implementation BackVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    {
//        did = 3028;
//        domanid = 1685470;
//        domanname = "\U6c88\U677e\U6797";
//        "node_id" = 1205;
//        "node_name" = "\U96c6\U56e2\U4f1a\U5ba1";
//        operrecno = 0;
//        recno = 120;
//    }
    
    NSLog(@"back nodes: %@", self.params[@"backnodes"]);
}

- (NSArray *)formControls
{
    NSArray *backNodes = self.params[@"backnodes"];
    NSMutableArray *itemNames = [NSMutableArray arrayWithCapacity:backNodes.count];
    NSMutableArray *itemValues = [NSMutableArray arrayWithCapacity:backNodes.count];
    
    for (id node in backNodes) {
        NSString *itemName = [NSString stringWithFormat:@"%@ (%@)", node[@"node_name"], node[@"domanname"]];
        [itemNames addObject:itemName];
        [itemValues addObject:[node[@"did"] description] ?: @""];
    }
    
    return @[@{
                 @"data_type": @"9",
                 @"datatype_c": @"下拉选",
                 @"describe": @"退回到节点",
                 @"field_name": @"backdid",
                 @"item_name": [itemNames componentsJoinedByString:@","],
                 @"item_value": [itemValues componentsJoinedByString:@","],
                 },
               @{
                 @"data_type": @"12",
                 @"datatype_c": @"开关选择2",
                 @"describe": @"需要重新流转",
                 @"field_name": @"backtype",
                 @"item_name": @"",
                 @"item_value": @"",
                 }];
}

- (NSDictionary *)apiParams
{
    return @{
             @"dotype": @"flow",
             @"type": @"back",
             @"backdid": [self.formObjects[@"backdid"][@"value"] ?: @"0" description],
             @"backtype": self.formObjects[@"backtype"] ?: @"0",
             @"opinion_allow_null": self.params[@"opinion_allow_null"],
             };
}

@end

//
//  LandSearchVC.m
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandSearchVC.h"
#import "Defines.h"

@interface LandSearchVC ()

@property (nonatomic, strong) NSMutableArray *inFormControls;

@end

@implementation LandSearchVC

- (void)viewDidLoad
{
    self.inFormControls = [@[@{
                                 @"data_type": @"9",
                                 @"datatype_c": @"下拉选",
                                 @"describe": @"土地获取方式",
                                 @"field_name": @"get_type",
                                 @"item_name": @"全部,招拍挂,协议",
                                 @"item_value": @",招拍挂,协议",
                                 },
                             @{
                                 @"data_type": @"9",
                                 @"datatype_c": @"下拉选",
                                 @"describe": @"所在城市",
                                 @"field_name": @"city",
                                 @"item_name": @"全部,成都,西安,宁波,长沙",
                                 @"item_value": @",成都,西安,宁波,长沙",
                                 },
                             @{
                                 @"data_type":  @"13",
                                 @"datatype_c": @"日期范围组合控件",
                                 @"describe":   @"公告时间",
                                 @"field_name": @"announce_date",
                                 @"item_name":  @"",
                                 @"item_value": @"",
                                 @"sub_describe": @"开始日期,结束日期",
                                 @"split_desc": @"至",
                                 @"split_symbol": @" ",
                                 },
                             @{
                                 @"data_type":  @"13",
                                 @"datatype_c": @"日期范围组合控件",
                                 @"describe":   @"出让时间",
                                 @"field_name": @"sell_date",
                                 @"item_name":  @"",
                                 @"item_value": @"",
                                 @"sub_describe": @"开始日期,截止日期",
                                 @"split_desc": @"至",
                                 @"split_symbol": @" ",
                                 },
                             @{
                                 @"data_type":  @"13",
                                 @"datatype_c": @"日期范围组合控件",
                                 @"describe":   @"报名截止时间",
                                 @"field_name": @"signup_date",
                                 @"item_name":  @"",
                                 @"item_value": @"",
                                 @"sub_describe": @"开始日期,截止日期",
                                 @"split_desc": @"至",
                                 @"split_symbol": @" ",
                                 },
                             ] mutableCopy];
    
    [super viewDidLoad];
    
    [self loadCities];
}

- (void)loadCities
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak LandSearchVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"土地信息城市查询APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult:result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count > 0 ) {
            NSArray *data = result[@"data"];
            NSMutableArray *temp1 = [NSMutableArray array];
            
            [temp1 addObject:@"全部"];
            
            NSMutableArray *temp2 = [NSMutableArray array];
            [temp2 addObject:@""];
            
            for (id dict in data) {
                [temp1 addObject:dict[@"city"] ?: @""];
                [temp2 addObject:[dict[@"city"] description] ?: @""];
            }
            
            NSString *itemName = [temp1 componentsJoinedByString:@","];
            NSString *itemValue = [temp2 componentsJoinedByString:@","];
            
            id dict = [self.inFormControls objectAtIndex:1];
            NSMutableDictionary *newDict = [dict mutableCopy];
            newDict[@"item_name"] = itemName;
            newDict[@"item_value"] = itemValue;
            
            [self.inFormControls replaceObjectAtIndex:1 withObject:newDict];
            
            [self formControlsDidChange];
        }
    }
}

- (NSArray *)formControls
{
    return self.inFormControls;
}

@end

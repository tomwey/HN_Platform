//
//  DocSearchVC.m
//  HN_ERP
//
//  Created by tomwey on 3/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DocSearchVC.h"
#import "Defines.h"

@interface DocSearchVC ()

@property (nonatomic, strong) NSMutableArray *inFormControls;

@end

@implementation DocSearchVC

- (void)viewDidLoad {
    
    self.inFormControls = [@[@{
                                 @"data_type": @"1",
                                 @"datatype_c": @"文本框",
                                 @"describe": @"关键字",
                                 @"field_name": @"keyword",
                                 @"item_name": @"",
                                 @"item_value": @"",
                                 },
                             @{
                                 @"data_type": @"9",
                                 @"datatype_c": @"下拉选",
                                 @"describe": @"公文类型",
                                 @"field_name": @"doc_type",
                                 @"item_name": @"全部,红文,通知/公告,计划",
                                 @"item_value": @"-1,0,1,2",
                                 },
                             @{
                                 @"data_type": @"9",
                                 @"datatype_c": @"下拉选",
                                 @"describe": @"区域",
                                 @"field_name": @"area",
                                 @"item_name": @"",
                                 @"item_value": @"",
                                 },
                             @{
                                 @"data_type":  @"13",
                                 @"datatype_c": @"日期范围组合控件",
                                 @"describe":   @"发布日期",
                                 @"field_name": @"publish_date",
                                 @"item_name":  @"",
                                 @"item_value": @"",
                                 @"sub_describe": @"起始日期,截止日期",
                                 @"split_desc": @"至",
                                 @"split_symbol": @" ",
                                 }] mutableCopy];
    
    [super viewDidLoad];
    
    [self loadArea];
}

- (void)loadArea
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak DocSearchVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"区域查询APP"
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
            [temp2 addObject:@"0"];
            
            for (id dict in data) {
                [temp1 addObject:dict[@"area_name"] ?: @""];
                [temp2 addObject:[dict[@"area_id"] description] ?: @"-1"];
            }
            
            NSString *itemName = [temp1 componentsJoinedByString:@","];
            NSString *itemValue = [temp2 componentsJoinedByString:@","];
            
            id dict = [self.inFormControls objectAtIndex:2];
            NSMutableDictionary *newDict = [dict mutableCopy];
            newDict[@"item_name"] = itemName;
            newDict[@"item_value"] = itemValue;
            
            [self.inFormControls replaceObjectAtIndex:2 withObject:newDict];
            
            [self formControlsDidChange];
        }
    }
}

- (NSArray *)formControls
{
    return self.inFormControls;
}
@end

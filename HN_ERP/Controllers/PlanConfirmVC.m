//
//  PlanConfirmVC.m
//  HN_ERP
//
//  Created by tomwey on 5/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanConfirmVC.h"
#import "Defines.h"

@interface PlanConfirmVC ()

@end

@implementation PlanConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"计划完成确认";
}

- (void)send
{
    NSLog(@"%@", self.formObjects);
    
    if ([[self.formObjects[@"done_desc"] description] trim].length == 0) {
        [self.contentView showHUDWithText:@"完成说明不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if (!self.formObjects[@"real_time"]) {
        [self.contentView showHUDWithText:@"实际完成日期不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    [self hideKeyboard];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description] ?: @"";
    
    NSString *planID = [self.params[@"id"] ?: @"" description];
    NSString *realDate = [df stringFromDate:self.formObjects[@"real_time"]] ?: @"";
    NSString *doneDesc = [[self.formObjects[@"done_desc"] description] trim];
    
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *ids  = [NSMutableArray array];
    for (id item in self.formObjects[@"next_man"]) {
        [temp addObject:[item name]];
        [ids addObject:[[item _id] description]];
    }
    
    NSString *manIDs = [ids componentsJoinedByString:@","] ?: @"";
    NSString *manNames = [temp componentsJoinedByString:@","] ?: @"";
    
    NSString *flowIDs   = @"";
    NSString *flowNames = @"";
    NSString *annexIDs  = @"";
    
    if ( self.formObjects[@"related_flow"] && [self.formObjects[@"related_flow"] count] > 0 ) {
        NSMutableArray *arr1 = [NSMutableArray array];
        NSMutableArray *arr2 = [NSMutableArray array];
        for (id dict in self.formObjects[@"related_flow"]) {
            [arr1 addObject:dict[@"mid"] ?: @""];
            [arr2 addObject:dict[@"title"] ?: @""];
        }
        
        flowIDs = [arr1 componentsJoinedByString:@","];
        flowNames = [arr2 componentsJoinedByString:@","];
    }
    
    // 相关附件
    if ( self.formObjects[@"related_annex"] && [self.formObjects[@"related_annex"] count] > 0 ) {
        NSMutableArray *arr1 = [NSMutableArray array];
        for (id aid in self.formObjects[@"related_annex"]) {
            [arr1 addObject:[aid description]];
        }
        
        annexIDs = [arr1 componentsJoinedByString:@","];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"移动端计划完成确认",
              @"param1": manID,
              @"param2": planID,
              @"param3": realDate,
              @"param4": doneDesc,
              @"param5": manIDs,
              @"param6": manNames,
              @"param7": flowIDs,
              @"param8": flowNames,
              @"param9": annexIDs,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 1 ) {
            id item = [result[@"data"] firstObject];
            NSString *mid = [item[@"mid"] description];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kPlanFlowDidCommitNotification" object:@{ @"mid": mid ?: @"", @"from": @"confirm" }];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSArray *)formControls
{
    return @[/*@{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"计划事项",
                 @"field_name": @"proj_name",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"计划类型",
                 @"field_name": @"plan_type",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"计划层级",
                 @"field_name": @"plan_level",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"责任部门",
                 @"field_name": @"dept",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"第一责任人",
                 @"field_name": @"man1",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"经办人",
                 @"field_name": @"man",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"计划完成日期",
                 @"field_name": @"plan_time",
                 @"item_name": @"",
                 @"item_value": @"0",
                 },*/
             @{
                 @"data_type": @"2",
                 @"datatype_c": @"日期控件",
                 @"describe": @"实际完成日期",
                 @"field_name": @"real_time",
                 @"item_name": @"",
                 @"item_value": @"",
                 },

             @{
                 @"data_type": @"6",
                 @"datatype_c": @"添加多个人",
                 @"describe": @"下游确认人",
                 @"field_name": @"next_man",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"完成说明",
                 @"field_name": @"done_desc",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"15",
                 @"datatype_c": @"文本框",
                 @"describe": @"相关附件",
                 @"field_name": @"related_annex",
                 @"item_name": @"",
                 @"item_value": @"H_WF_INST_M,About_Annex",
                 },
             @{
                 @"data_type": @"16",
                 @"datatype_c": @"文本框",
                 @"describe": @"相关流程",
                 @"field_name": @"related_flow",
                 @"item_name": @"",
                 @"item_value": @"",
                 }];
}

@end

//
//  PlanAdjustVC.m
//  HN_ERP
//
//  Created by tomwey on 5/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanAdjustVC.h"
#import "Defines.h"

@interface PlanAdjustVC ()

@property (nonatomic, copy) NSArray *baseFormControls;
@property (nonatomic, copy) NSArray *currentFormControls;

@end

@implementation PlanAdjustVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navBar.title = @"计划调整";
}

- (void)send
{
    NSLog(@"%@ -> %@", NSStringFromClass([self class]), self.formObjects);
    
//    if (!self.formObjects[@"end_date"]) {
//        [self.contentView showHUDWithText:@"调整完成日期不能为空" offset:CGPointMake(0,20)];
//        return;
//    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description] ?: @"";
    
    NSString *planID = [self.params[@"id"] ?: @"" description];
    NSString *realDate = [df stringFromDate:self.formObjects[@"end_date"]] ?: @"";
    NSString *doneDesc = [[self.formObjects[@"adjust_desc"] description] trim];
    
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *ids  = [NSMutableArray array];
    for (id item in self.formObjects[@"next_man"]) {
        [temp addObject:[item name]];
        [ids addObject:[[item _id] description]];
    }
    
    NSString *manIDs = [ids componentsJoinedByString:@","] ?: @"";
    NSString *manNames = [temp componentsJoinedByString:@","] ?: @"";
    
    NSString *orgID     = HNStringFromObject(self.params[@"dodept"], @"");
    NSString *orgName   = HNStringFromObject(self.params[@"dodeptid"], @"");
    NSString *man1ID    = @"";
    NSString *man1Name  = @"";
    NSString *doManID   = @"";
    NSString *doManName = @"";
    NSString *man2ID    = @"";
    NSString *man2Name  = @"";
    NSString *type      = [self.formObjects[@"adjust_type"][@"value"] ?: @"" description];
    NSString *reason    = [self.formObjects[@"adjust_reason"][@"value"] ?: @"" description];
    NSString *isBossApply  = [self.formObjects[@"boss_apply"] ?: @"" description];
    
    if ( [type isEqualToString:@"1"] ||
        [type isEqualToString:@"2"]) {
        // 时间和责任人
        NSMutableArray *ids = [NSMutableArray array];
        NSMutableArray *names = [NSMutableArray array];
        for (id item in self.formObjects[@"man1"]) {
            [ids addObject:[[item _id] description]];
            [names addObject:[item name]];
        }
        man1ID = [ids componentsJoinedByString:@","];
        man1Name = [names componentsJoinedByString:@","];
        
        // 第二责任人
        ids = [NSMutableArray array];
        names = [NSMutableArray array];
        for (id item in self.formObjects[@"man2"]) {
            [ids addObject:[[item _id] description]];
            [names addObject:[item name]];
        }
        man2ID = [ids componentsJoinedByString:@","];
        man2Name = [names componentsJoinedByString:@","];
        
        // 经办人
        ids = [NSMutableArray array];
        names = [NSMutableArray array];
        for (id item in self.formObjects[@"man"]) {
            [ids addObject:[[item _id] description]];
            [names addObject:[item name]];
        }
        doManID = [ids componentsJoinedByString:@","];
        doManName = [names componentsJoinedByString:@","];
    }
//    } else if ( [type isEqualToString:@"1"] ) {
//        // 责任人
//    } else if ( [type isEqualToString:@"2"] ) {
//        // 调整时间
//    }
    
    if ( ([type isEqualToString:@"1"] || [type isEqualToString:@"3"]) &&
        !self.formObjects[@"end_date"] ) {
        [self.contentView showHUDWithText:@"调整完成日期必须" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( [type isEqualToString:@"1"] ||
         [type isEqualToString:@"2"] ) {
        if ( [self.formObjects[@"man"] count] == 0 ) {
            [self.contentView showHUDWithText:@"经办人不能为空" offset:CGPointMake(0,20)];
            return;
        }
        
        if ( [self.formObjects[@"man1"] count] == 0 ) {
            [self.contentView showHUDWithText:@"第一责任人不能为空" offset:CGPointMake(0,20)];
            return;
        }
        
    }
    
    if (!self.formObjects[@"adjust_type"]) {
        [self.contentView showHUDWithText:@"调整类型不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if ([[self.formObjects[@"adjust_desc"] description] trim].length == 0) {
        [self.contentView showHUDWithText:@"调整说明不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
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
    
    [self hideKeyboard];
    
    __weak typeof(self) weakSelf = self;
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"移动端计划调整",
              @"param1": manID,
              @"param2": planID,
              @"param3": doneDesc,
              @"param4": realDate,
              @"param5": orgID,
              @"param6": orgName,
              @"param7": man1ID,
              @"param8": man1Name,
              @"param9": doManID,
              @"param10": doManName,
              @"param11": man2ID,
              @"param12": man2Name,
              @"param13": type,
              @"param14": reason,
              @"param15": isBossApply,
              @"param16": manIDs,
              @"param17": manNames,
              @"param18": flowIDs,
              @"param19": flowNames,
              @"param20": annexIDs,
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kPlanFlowDidCommitNotification" object:@{ @"mid": mid ?: @"", @"from": @"adjust" }];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didChangeItem:(id)selectedItem
{
    NSLog(@"%@", selectedItem);
    
    NSInteger val = [selectedItem[@"value"] integerValue];
    switch (val) {
        case 1:
        {
            // 时间和责任人
            NSArray *controls = @[@{
                                      @"data_type": @"5",
                                      @"datatype_c": @"添加单个人",
                                      @"describe": @"责任人1",
                                      @"field_name": @"man1",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  @{
                                      @"data_type": @"6",
                                      @"datatype_c": @"添加多个人",
                                      @"describe": @"责任人2",
                                      @"field_name": @"man2",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  @{
                                      @"data_type": @"5",
                                      @"datatype_c": @"添加单个人",
                                      @"describe": @"经办人",
                                      @"field_name": @"man",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  @{
                                      @"data_type": @"2",
                                      @"datatype_c": @"日期控件",
                                      @"describe": @"调整完成日期",
                                      @"field_name": @"end_date",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  ];
            
            NSMutableArray *temp = [self.baseFormControls mutableCopy];
            int i = 3;
            for (id obj in controls) {
                [temp insertObject:obj atIndex:i++];
            }
            
            self.currentFormControls = temp;
        }
            break;
        case 2:
        {
            // 责任人
            int i = 3;
            NSArray *controls = @[@{
                                      @"data_type": @"5",
                                      @"datatype_c": @"添加单个人",
                                      @"describe": @"责任人1",
                                      @"field_name": @"man1",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  @{
                                      @"data_type": @"6",
                                      @"datatype_c": @"添加多个人",
                                      @"describe": @"责任人2",
                                      @"field_name": @"man2",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  @{
                                      @"data_type": @"5",
                                      @"datatype_c": @"添加单个人",
                                      @"describe": @"经办人",
                                      @"field_name": @"man",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  ];
            
            NSMutableArray *temp = [self.baseFormControls mutableCopy];
            for (id obj in controls) {
                [temp insertObject:obj atIndex:i++];
            }
            
            self.currentFormControls = temp;
        }
            break;
        case 3:
        {
            // 时间
            NSArray *controls = @[
                                  @{
                                      @"data_type": @"2",
                                      @"datatype_c": @"日期控件",
                                      @"describe": @"调整完成日期",
                                      @"field_name": @"end_date",
                                      @"item_name": @"",
                                      @"item_value": @"",
                                      },
                                  ];
            
            NSMutableArray *temp = [self.baseFormControls mutableCopy];
            for (id obj in controls) {
                [temp insertObject:obj atIndex:3];
            }
            
            self.currentFormControls = temp;
        }
            break;
        case 4:
            // 取消计划
            self.currentFormControls = self.baseFormControls;
            break;
            
        default:
            break;
    }
    
    [self formControlsDidChange];
}

- (NSArray *)formControls
{
    return self.currentFormControls ?: self.baseFormControls;
}

- (NSArray *)baseFormControls
{
    if ( !_baseFormControls ) {
        _baseFormControls = [@[@{
                                  @"data_type": @"9",
                                  @"datatype_c": @"下拉选",
                                  @"describe": @"调整类型",
                                  @"field_name": @"adjust_type",
                                  @"item_name": @"调整责任人和时间,调整责任人,调整时间,取消计划",
                                  @"item_value": @"1,2,3,4",
                                  @"change_action": @"didChangeItem:",
                                  },
//                              @{
//                                  @"data_type": @"14",
//                                  @"datatype_c": @"单选按钮",
//                                  @"describe": @"是否总裁审批",
//                                  @"field_name": @"boss_apply",
//                                  @"item_name": @"是,否",
//                                  @"item_value": @"1,0",
//                                  },
                              @{
                                  @"data_type": @"9",
                                  @"datatype_c": @"下拉选",
                                  @"describe": @"调整原因",
                                  @"field_name": @"adjust_reason",
                                  @"item_name": @"因公司经营、战略调整,受公司资金安排影响（垄断、政府类）,受突发、重大政策类影响,经运营管理部线下先行评审，对后续工作无实质影响的，并下游部门确认的",
                                  @"item_value": @"1,2,3,4",
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
                                  @"describe": @"调整说明",
                                  @"field_name": @"adjust_desc",
                                  @"item_name": @"",
                                  @"item_value": @"",
                                  },
                              @{
                                  @"data_type": @"15",
                                  @"datatype_c": @"上传组件",
                                  @"describe": @"相关附件",
                                  @"field_name": @"related_annex",
                                  @"item_name": @"",
                                  @"item_value": @"H_WF_INST_M,About_Annex",
                                  },
                              @{
                                  @"data_type": @"16",
                                  @"datatype_c": @"相关流程组件",
                                  @"describe": @"相关流程",
                                  @"field_name": @"related_flow",
                                  @"item_name": @"",
                                  @"item_value": @"",
                                  }] copy];
    }
    return _baseFormControls;
}

@end

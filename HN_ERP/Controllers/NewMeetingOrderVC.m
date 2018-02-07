//
//  NewMeetingOrderVC.m
//  HN_ERP
//
//  Created by tomwey on 4/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NewMeetingOrderVC.h"
#import "Defines.h"
#import "MeetingOrderedView.h"
#import "ValuesUtils.h"

@interface NewMeetingOrderVC ()

@property (nonatomic, weak) UIButton *leftBtn;
@property (nonatomic, weak) UIButton *rightBtn;

@property (nonatomic, assign) MeetingOrderFormType formType;

@property (nonatomic, weak) UIButton *navRightBtn;

@property (nonatomic, strong) NSMutableArray *inFormControls;

@property (nonatomic, assign) BOOL noLimit;

@property (nonatomic, assign) NSInteger loadDoneCounter;

@property (nonatomic, strong) NSArray *areas;

@end

@implementation NewMeetingOrderVC

- (void)viewDidLoad {
    
    self.loadDoneCounter = 0;
    
    self.inFormControls = [@[
      @{
          @"data_type": @"1",
          @"datatype_c": @"输入控件",
          @"describe": @"会议主题",
          @"field_name": @"title",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"2",
          @"datatype_c": @"日期控件",
          @"describe": @"预定日期",
          @"field_name": @"order_date",
          @"item_name": @"",
          @"item_value": @"0,1", // 最小日期与最大日期与最新日期的天数
          @"picker_mode": @"0",  // 日期控件模式
          },
      @{
          @"data_type": @"13",
          @"datatype_c": @"日期时间区间",
          @"describe": @"预定时间",
          @"field_name": @"order_time",
          @"item_name": @"",
          @"item_value": @"",
          @"sub_describe": @"开始时间,结束时间",
          @"split_desc": @"至",
          @"split_symbol": @" ",
          @"picker_mode": @"1",
          @"minute_interval": @"5",
          },
      @{
          @"data_type": @"6",
          @"datatype_c": @"添加多人",
          @"describe": @"参与人",
          @"field_name": @"contacts",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"5",
          @"datatype_c": @"添加单人",
          @"describe": @"主持人",
          @"field_name": @"contact",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"9",
          @"datatype_c": @"下拉选",
          @"describe": @"专业",
          @"field_name": @"spec",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"9",
          @"datatype_c": @"下拉选",
          @"describe": @"区域",
          @"field_name": @"area",
          @"item_name": @"",
          @"item_value": @"",
//          @"change_action": @"didChangeArea:",
          },
      @{
          @"data_type": @"9",
          @"datatype_c": @"下拉选",
          @"describe": @"业态",
          @"field_name": @"industry",
          @"item_name": @"",
          @"item_value": @"",
//          @"change_action": @"didChangeArea:",
          },
      @{
          @"data_type": @"9",
          @"datatype_c": @"下拉选",
          @"describe": @"会议类型",
          @"field_name": @"meeting_type",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"4",
          @"datatype_c": @"输入控件",
          @"describe": @"是否是视频会",
          @"field_name": @"is_video",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"输入控件",
          @"describe": @"申请部门",
          @"field_name": @"order_dept",
          @"item_name": @"",
          @"item_value": @"0",
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"输入控件",
          @"describe": @"手机",
          @"field_name": @"mobile",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"输入控件",
          @"describe": @"分机号",
          @"field_name": @"order_telno",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"10",
          @"datatype_c": @"多行文本",
          @"describe": @"备注",
          @"field_name": @"memo",
          @"item_name": @"",
          @"item_value": @"",
          },
      ] mutableCopy];
    
    [super viewDidLoad];
    
//    NSLog(@"user: %@", [[UserService sharedInstance] currentUser]);
    self.navBar.title = [NSString stringWithFormat:@"%@",
                         self.params[@"item"][@"mr_name"]];
    
    if ( [self.params[@"form_type"] integerValue] != 3 ) {
        __weak typeof(self) weakSelf = self;
        self.navRightBtn =
        (UIButton *)[self addRightItemWithTitle:@"查看已预定" titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                                           size:CGSizeMake(80, 40)
                                    rightMargin:8
                                       callback:^{
                                           //                           NSLog(@"%@", weakSelf.formObjects);
                                           [weakSelf viewOrdered];
                                       }];
        
//        [self addWarningTips];
        
        self.tableView.top = 0;
        self.tableView.height -= 50;
        
        [self addTwoButtons];
    } else {
        self.tableView.top = 0;
        self.tableView.height = self.contentView.height;
    }
    
    self.formType = [self.params[@"form_type"] integerValue];
    
    if ( self.formType == MeetingOrderFormTypeNew || self.formType == MeetingOrderFormTypeEdit ) {
        [self loadOrderPower];
    }
    
    [self loadBaseData];
}

- (void)loadBaseData
{
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [self loadSpecs];
    
    [self loadArea];
    
    [self loadMeetingTypes];
    
    [self loadYetai];
}

- (void)loadYetai
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak NewMeetingOrderVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"获取会议业态列表APP",
              @"param1": manID,
//              @"param2": @"0",
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult5:result error5: error];
              }];
}

- (void)loadMeetingTypes
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak NewMeetingOrderVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"获取会议类型列表APP",
              @"param1": manID,
              @"param2": @"0",
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult4:result error4: error];
              }];
}

//- (void)loadMeetingTypesForAreaData:(id)data
//{
//    NSString *type = [data[@"name"] isEqualToString:@"集团本部"] ? @"0" : @"1";
//    
//    id user = [[UserService sharedInstance] currentUser];
//    NSString *manID = [user[@"man_id"] description];
//    manID = manID ?: @"0";
//    
//    __weak NewMeetingOrderVC *weakSelf = self;
//    [[self apiServiceWithName:@"APIService"]
//     POST:nil
//     params:@{
//              @"dotype": @"GetData",
//              @"funname": @"获取会议类型列表APP",
//              @"param1": manID,
//              @"param2": type,
//              } completion:^(id result, NSError *error) {
//                  [weakSelf handleResult4:result error4: error];
//              }];
//}

- (void)loadDone
{
    self.loadDoneCounter ++;
    
    if ( self.loadDoneCounter == 4 ) {
        
//        if ( self.areas.count > 0 ) {
//            id item = [self.areas firstObject];
//            
//            if (!self.formObjects[@"area"])
//                self.formObjects[@"area"] = @{ @"name": item[@"area_name"] ?: @"",
//                                               @"value": item[@"area_id"] ?: @""
//                                               };
//            
//            [self loadMeetingTypesForAreaData:self.formObjects[@"area"]];
//            
//        } else {
            [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//        }
        
//        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//        
        [self formControlsDidChange];
    }
}

- (void)didChangeArea:(id)option
{
//    NSLog(@"%@", option);
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
//    [self.formObjects removeObjectForKey:@"meeting_type"];
    
//    [self loadMeetingTypesForAreaData:option];
}

- (void)loadSpecs
{
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak NewMeetingOrderVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"获取会议专业列表APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult3:result error3: error];
              }];
}

- (void)handleResult5:(id)result error5:(NSError *)error
{
    //    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count > 0 ) {
            NSArray *data = result[@"data"];
            NSMutableArray *temp1 = [NSMutableArray array];

            NSMutableArray *temp2 = [NSMutableArray array];
            for (id dict in data) {
                [temp1 addObject:dict[@"industry_name"] ?: @""];
                [temp2 addObject:[dict[@"industry_id"] description] ?: @"-1"];
            }
            
            NSString *itemName = [temp1 componentsJoinedByString:@","];
            NSString *itemValue = [temp2 componentsJoinedByString:@","];
            
            id dict = [self.inFormControls objectAtIndex:7];
            NSMutableDictionary *newDict = [dict mutableCopy];
            newDict[@"item_name"] = itemName;
            newDict[@"item_value"] = itemValue;
            
            [self.inFormControls replaceObjectAtIndex:7 withObject:newDict];
            
            //            [self formControlsDidChange];
        }
    }
    
    [self loadDone];
}

- (void)handleResult4:(id)result error4:(NSError *)error
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count > 0 ) {
            NSArray *data = result[@"data"];
            NSMutableArray *temp1 = [NSMutableArray array];
            
//            [temp1 addObject:@"请选择专业"];
            
            NSMutableArray *temp2 = [NSMutableArray array];
//            [temp2 addObject:@""];
            
            for (id dict in data) {
                [temp1 addObject:dict[@"dic_name"] ?: @""];
                [temp2 addObject:[dict[@"dic_value"] description] ?: @"-1"];
            }
            
            NSString *itemName = [temp1 componentsJoinedByString:@","];
            NSString *itemValue = [temp2 componentsJoinedByString:@","];
            
            id dict = [self.inFormControls objectAtIndex:8];
            NSMutableDictionary *newDict = [dict mutableCopy];
            newDict[@"item_name"] = itemName;
            newDict[@"item_value"] = itemValue;
            
            [self.inFormControls replaceObjectAtIndex:8 withObject:newDict];
            
//            [self formControlsDidChange];
        }
    }
    
    [self loadDone];
}

- (void)handleResult3:(id)result error3:(NSError *)error
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count > 0 ) {
            NSArray *data = result[@"data"];
            NSMutableArray *temp1 = [NSMutableArray array];
            
            [temp1 addObject:@"请选择专业"];
            
            NSMutableArray *temp2 = [NSMutableArray array];
            [temp2 addObject:@""];
            
            for (id dict in data) {
                [temp1 addObject:dict[@"spec_name"] ?: @""];
                [temp2 addObject:[dict[@"spec_id"] description] ?: @"-1"];
            }
            
            NSString *itemName = [temp1 componentsJoinedByString:@","];
            NSString *itemValue = [temp2 componentsJoinedByString:@","];
            
            id dict = [self.inFormControls objectAtIndex:5];
            NSMutableDictionary *newDict = [dict mutableCopy];
            newDict[@"item_name"] = itemName;
            newDict[@"item_value"] = itemValue;
            
            [self.inFormControls replaceObjectAtIndex:5 withObject:newDict];
            
//            [self formControlsDidChange];
        }
    }
    
    [self loadDone];
}


- (void)loadArea
{
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak NewMeetingOrderVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"区域查询APP"
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult2:result error2: error];
              }];
}

- (void)handleResult2:(id)result error2:(NSError *)error
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count > 0 ) {
            NSArray *data = result[@"data"];
            NSMutableArray *temp1 = [NSMutableArray array];
            
//            [temp1 addObject:@"请选择区域"];
            
            self.areas = data;
            
            NSMutableArray *temp2 = [NSMutableArray array];
//            [temp2 addObject:@""];
            
            for (id dict in data) {
                [temp1 addObject:dict[@"area_name"] ?: @""];
                [temp2 addObject:[dict[@"area_id"] description] ?: @"-1"];
            }
            
            NSString *itemName = [temp1 componentsJoinedByString:@","];
            NSString *itemValue = [temp2 componentsJoinedByString:@","];
            
            id dict = [self.inFormControls objectAtIndex:6];
            NSMutableDictionary *newDict = [dict mutableCopy];
            newDict[@"item_name"] = itemName;
            newDict[@"item_value"] = itemValue;
            
            [self.inFormControls replaceObjectAtIndex:6 withObject:newDict];
            
//            [self formControlsDidChange];
        }
    }
    
    [self loadDone];
}

- (void)loadOrderPower
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"会议室预定是否不做限制",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    NSLog(@"result: %@", result);
    if (!error) {
        if ( [result[@"rowcount"] integerValue] == 1 ) {
            id res = [result[@"data"] firstObject];
            id val = [[res allValues] firstObject];
            
            self.noLimit = [val boolValue];
        }
    } else {
        self.noLimit = NO;
    }
}

- (void)setNoLimit:(BOOL)noLimit
{
    _noLimit = noLimit;
    
    if ( _noLimit ) {
        self.tableView.top = 0;
        self.tableView.height = self.contentView.height - 50;
        
        id dict = [self.inFormControls objectAtIndex:1];
        NSMutableDictionary *newDict = [dict mutableCopy];
//        newDict[@"item_name"] = itemName;
        newDict[@"item_value"] = @"0,3650"; // 可以预定10年内的会议
        
        [self.inFormControls replaceObjectAtIndex:1 withObject:newDict];
        
        [self formControlsDidChange];
        
    } else {
        [self addWarningTips];
        
        self.tableView.top = 60;
        self.tableView.height = self.contentView.height - (60 + 50);
    }
}

- (void)viewOrdered
{
    if ( [[self.navRightBtn currentTitle] isEqualToString:@"查看已预定"] ) {
        [self.navRightBtn setTitle:@"        收起" forState:UIControlStateNormal];
        
        QueryParams *params = [[QueryParams alloc] init];
        params.currentDate = self.params[@"currentDate"] ?: [NSDate date];
        params.meetingRoomId = [self.params[@"item"][@"mr_id"] description] ?: @"0";
        
        __weak typeof(self) me = self;
        [MeetingOrderedView showInView:self.contentView
                           queryParams:params
                        selectCallback:^(id item) {
                            me.formType = MeetingOrderFormTypeShow;
                            
                            [me reproduceFormDataFromMeetingData:item];
                            [me.tableView reloadData];
                        }
                         closeCallback:^{
                             [me.navRightBtn setTitle:@"查看已预定" forState:UIControlStateNormal];
                         }];
    } else {
        [self.navRightBtn setTitle:@"查看已预定" forState:UIControlStateNormal];
        [MeetingOrderedView hideForView:self.contentView animated:YES];
    }
}

- (void)addWarningTips
{
    UIView *containerView = [[UIView alloc] initWithFrame:
                             CGRectMake(0, 0, self.contentView.width, 60)];
    [self.contentView addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *tipLabel = AWCreateLabel(CGRectMake(0, 0, self.contentView.width * 0.8,
                                                 60),
                                      @"提示：只能订今明两天的会议室，单次预定最少半小时，最多4小时!",
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(14, NO),
                                      [UIColor redColor]);
    [containerView addSubview:tipLabel];
    tipLabel.center = CGPointMake(self.contentView.width / 2,
                                  tipLabel.height / 2);
    tipLabel.numberOfLines = 2;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:containerView];
    line.position = CGPointMake(0, containerView.height - 0.5);
}

- (void)reproduceFormDataFromMeetingData:(id)data
{
    self.formObjects[@"mr_id"] = data[@"mr_id"] ?: @"";
    
    self.formObjects[@"id"] = data[@"id"] ?: @"0";
    self.formObjects[@"order_telno"] = data[@"seatno"] ?: @"";
    self.formObjects[@"memo"] = HNStringFromObject(data[@"memo"], @"");//data[@"memo"] ?: @"";
    self.formObjects[@"title"] = data[@"title"] ?: @"";
    
    // 准备参与人数据
    NSString *manIDs = HNStringFromObject(data[@"man_ids"], @"");
    NSString *manNames = HNStringFromObject(data[@"man_names"], @"");
    
    if ( manIDs.length > 0 && manNames.length > 0 ) {
        NSArray *IDs = [manIDs componentsSeparatedByString:@","];
        NSArray *names = [manNames componentsSeparatedByString:@","];
        
        NSInteger count = MIN(IDs.count, names.count);
        
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i<count; i++) {
            Employ *emp = [[Employ alloc] init];
            NSInteger _id = [IDs[i] integerValue];
            NSString *name = names[i];
            
            emp._id = @(_id);
            emp.name = name;
            
            [temp addObject:emp];
        }
        
        self.formObjects[@"contacts"] = temp;
    } else {
        [self.formObjects removeObjectForKey:@"contacts"];
    }
    
    // 准备预定日期
    NSString *orderDate = [[data[@"orderdate"] componentsSeparatedByString:@"T"] firstObject];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    if ( orderDate.length > 0 ) {
        self.formObjects[@"order_date"] = [df dateFromString:orderDate];
    } else {
        self.formObjects[@"order_date"] = [NSDate date];
    }
    
    df.dateFormat = @"HH:mm:ss";
    
    NSString *btime = [[data[@"begintime"] componentsSeparatedByString:@"T"] lastObject];
    btime = [[btime componentsSeparatedByString:@"+"] firstObject];
    
    NSString *etime = [[data[@"endtime"] componentsSeparatedByString:@"T"] lastObject];
    etime = [[etime componentsSeparatedByString:@"+"] firstObject];
    
    if ( btime.length > 0 ) {
        self.formObjects[@"order_time.1"] = [df dateFromString:btime];
    } else {
        [self.formObjects removeObjectForKey:@"order_time.1"];
    }
    
    if ( etime.length > 0 ) {
        self.formObjects[@"order_time.2"] = [df dateFromString:etime];
    } else {
        [self.formObjects removeObjectForKey:@"order_time.2"];
    }
    
    // 保存用户相关的信息
    id user = [[UserService sharedInstance] currentUser];

    self.formObjects[@"dept_id"] = data[@"create_deptid"] ?: user[@"dept_id"];
    self.formObjects[@"order_dept"] = data[@"create_deptname"] ?: user[@"dept_name"];
    self.formObjects[@"man_id"]  = data[@"create_id"] ?: user[@"man_id"];
    self.formObjects[@"order_man"] = data[@"create_name"] ?: user[@"man_name"];
    self.formObjects[@"mobile"] = data[@"mobile"] ?: user[@"telephone"] ?: @"";
    if ([self.formObjects[@"mobile"] isEqualToString:@"NULL"]) {
        self.formObjects[@"mobile"] = @"";
    }
    
    // 准备主持人数据
    NSString *manageId = HNStringFromObject(data[@"manage_id"], @"");
    NSString *manageName = HNStringFromObject(data[@"manage_name"], @"");
    
    if ( [manageId length] > 0 && [manageName length] > 0 ) {
        Employ *emp = [[Employ alloc] init];
        NSInteger _id = [manageId integerValue];
        NSString *name = manageName;
        
        emp._id = @(_id);
        emp.name = name;
        
        self.formObjects[@"contact"] = @[emp];
    } else {
        [self.formObjects removeObjectForKey:@"contact"];
    }
    
    // 准备专业数据
    NSString *specId = HNStringFromObject(data[@"spec_id"], @"");
    NSString *specName = HNStringFromObject(data[@"spec_name"], @"");
    
    if ( [specId length] > 0 && [specName length] > 0 ) {
        self.formObjects[@"spec"] = @{ @"name": specName,
                                       @"value": specId
                                       };
    } else {
        [self.formObjects removeObjectForKey:@"spec"];
    }
    
    // 准备区域数据
    NSString *areaId = HNStringFromObject(data[@"area_id"], @"");
    NSString *areaName = HNStringFromObject(data[@"area_name"], @"");
    
    if ( [areaId length] > 0 && [areaName length] > 0 ) {
        self.formObjects[@"area"] = @{ @"name": areaName,
                                       @"value": areaId
                                       };
    } else {
        [self.formObjects removeObjectForKey:@"area"];
    }
    
    // 准备会议类型数据
    NSString *mtId = HNStringFromObject(data[@"meet_typeid"], @"");
    NSString *mtName = HNStringFromObject(data[@"meet_typename"], @"");
    
    if ( [mtId length] > 0 && [mtName length] > 0 ) {
        self.formObjects[@"meeting_type"] = @{ @"name": mtName,
                                       @"value": mtId
                                       };
    } else {
        [self.formObjects removeObjectForKey:@"meeting_type"];
    }
    
    // 准备会议业态数据
    NSString *indId = HNStringFromObject(data[@"indusrty_id"], @"");
    NSString *indName = HNStringFromObject(data[@"indusrty_name"], @"");
    
    if ( [mtId length] > 0 && [mtName length] > 0 ) {
        self.formObjects[@"industry"] = @{ @"name": indName,
                                               @"value": indId
                                               };
    } else {
        [self.formObjects removeObjectForKey:@"industry"];
    }
    
    self.formObjects[@"is_video"] = HNStringFromObject(data[@"isvideo"], @"0");
//    BOOL HNStringFromObject(data[@"isvideo"], @"")
//    isvideo
}

- (void)addTwoButtons
{
    UIButton *leftBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                        50),
                                             @"重置",
                                             MAIN_THEME_COLOR,
                                             self,
                                           @selector(leftBtnClick));
    [self.contentView addSubview:leftBtn];
    leftBtn.backgroundColor = [UIColor whiteColor];
    leftBtn.position = CGPointMake(0, self.contentView.height - 50);
    
    self.leftBtn = leftBtn;
    
    UIButton *rightBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                      50),
                                           @"预定",
                                           [UIColor whiteColor],
                                           self,
                                           @selector(rightBtnClick));
    [self.contentView addSubview:rightBtn];
    
    self.rightBtn = rightBtn;
    
    rightBtn.backgroundColor = MAIN_THEME_COLOR;
    rightBtn.position = CGPointMake(leftBtn.right, self.contentView.height - 50);
    
    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:self.leftBtn.width
                                                         color:MAIN_THEME_COLOR
                                                        inView:self.leftBtn];
    hairLine.position = CGPointMake(0,0);
}

- (void)setFormType:(MeetingOrderFormType)formType
{
    MeetingOrderFormType lastType = _formType;
    
    _formType = formType;
    switch (_formType) {
        case MeetingOrderFormTypeNew:
        {
            self.disableFormInputs = NO;
            
            [self.leftBtn setTitle:@"重置" forState:UIControlStateNormal];
            [self.rightBtn setTitle:@"预定" forState:UIControlStateNormal];
            
            [self reproduceFormDataFromMeetingData:nil];
            [self.tableView reloadData];
        }
            break;
        case MeetingOrderFormTypeEdit:
        {
            self.disableFormInputs = NO;
            
            [self.leftBtn setTitle:@"重置" forState:UIControlStateNormal];
            [self.rightBtn setTitle:@"修改" forState:UIControlStateNormal];
            
            [self reproduceFormDataFromMeetingData:self.params[@"item"]];
            [self.tableView reloadData];
        }
            break;
        case MeetingOrderFormTypeShow:
        {
            self.disableFormInputs = YES;
            
            [self.leftBtn setTitle:@"联系预订人" forState:UIControlStateNormal];
            
            if ( lastType == MeetingOrderFormTypeNew ) {
                [self.rightBtn setTitle:@"新增预定" forState:UIControlStateNormal];
            } else if ( lastType == MeetingOrderFormTypeEdit ) {
                [self.rightBtn setTitle:@"返回修改" forState:UIControlStateNormal];
            }
        }
            break;
        case MeetingOrderFormTypeShow2:
        {
            self.disableFormInputs = YES;
            
            [self reproduceFormDataFromMeetingData:self.params[@"item"]];
        }
            break;
            
        default:
            break;
    }
}

- (void)leftBtnClick
{
    if ([[self.leftBtn currentTitle] isEqualToString:@"重置"]) {
        [self reproduceFormDataFromMeetingData:self.params[@"item"]];
        [self.tableView reloadData];
    } else if ( [[self.leftBtn currentTitle] isEqualToString:@"联系预订人"] ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    [NSString stringWithFormat:@"tel:%@", self.formObjects[@"mobile"]]]];
    }
}

- (void)rightBtnClick
{
    if ([[self.rightBtn currentTitle] isEqualToString:@"预定"]) {
        [self doSend];
    } else if ( [[self.rightBtn currentTitle] isEqualToString:@"新增预定"] ) {
        self.formType = MeetingOrderFormTypeNew;
    } else if ( [[self.rightBtn currentTitle] isEqualToString:@"返回修改"] ) {
        self.formType = MeetingOrderFormTypeEdit;
    } else if ( [[self.rightBtn currentTitle] isEqualToString:@"修改"] ) {
        [self doUpdate];
    }
}

- (void)doUpdate
{
    // 检查预定日期
    if ( !self.formObjects[@"order_date"] ) {
        [self.contentView showHUDWithText:@"预定日期不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 检查预定时间
    
    if ( !self.formObjects[@"order_time.1"] || !self.formObjects[@"order_time.2"] ) {
        [self.contentView showHUDWithText:@"预定时间不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 预定时间不能超过4小时
    NSDate *firstTime = self.formObjects[@"order_time.1"];
    NSDate *lastTime  = self.formObjects[@"order_time.2"];
    
    NSTimeInterval dt = [firstTime timeIntervalSinceDate:lastTime];
    if ( !self.noLimit && fabs(dt) > 4 * 3600) {
        [self.contentView showHUDWithText:@"预定时间不能超过4小时"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( !self.noLimit && fabs(dt) < 30 * 60 ) {
        [self.contentView showHUDWithText:@"预定时间至少半小时"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    NSString *title = self.formObjects[@"title"] ?: @"";
    if ( title.length == 0 ) {
        [self.contentView showHUDWithText:@"会议主题必填"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    NSArray *contacts = self.formObjects[@"contacts"];
    if ( contacts.count == 0 ) {
        [self.contentView showHUDWithText:@"至少需要一个参与人"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 主持人
    Employ *item = [self.formObjects[@"contact"] firstObject];
    NSString *manageID = [item._id description] ?: @"0";
    
    // 专业
    NSString *specID = [self.formObjects[@"spec"][@"value"] ?: @"0" description];
    if ([specID isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"专业必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 区域
    NSString *areaID = [self.formObjects[@"area"][@"value"] ?: @"0" description];
    
    if ([areaID isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"区域必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 业态
    NSString *induID = [self.formObjects[@"industry"][@"value"] ?: @"0" description];
    
    if ([induID isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"业态必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 会议类型
    NSString *meetingType = [self.formObjects[@"meeting_type"][@"value"] ?: @"0" description];
    
    if ([meetingType isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"会议类型必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }

//    // 专业
//    NSString *specID = [self.formObjects[@"spec"][@"value"] ?: @"0" description];
//    
//    // 区域
//    NSString *areaID = [self.formObjects[@"area"][@"value"] ?: @"0" description];
//    
//    // 会议类型
//    NSString *meetingType = [self.formObjects[@"meeting_type"][@"value"] ?: @"0" description];
    
    // 是否是视频会
    NSString *isVideo = [self.formObjects[@"is_video"] ?: @"0" description];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *orderDate = [df stringFromDate:self.formObjects[@"order_date"]];
    
    df.dateFormat = @"HH:mm";
    
    NSString *time1 = [df stringFromDate:self.formObjects[@"order_time.1"]];
    NSString *time2 = [df stringFromDate:self.formObjects[@"order_time.2"]];
    
    NSMutableString *manIDs = [NSMutableString stringWithString:@""];
    NSMutableString *manNames = [NSMutableString stringWithString:@""];
    for (Employ *emp in contacts) {
        [manIDs appendFormat:@"%@,", emp._id];
        [manNames appendFormat:@"%@,", emp.name];
    }
    
    [manIDs deleteCharactersInRange:NSMakeRange(manIDs.length - 1, 1)];
    [manNames deleteCharactersInRange:NSMakeRange(manNames.length - 1, 1)];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"更新会议室预定APP",
                       @"param1": [self.formObjects[@"id"] description],
                       @"param2": [self.formObjects[@"man_id"] description],
                       @"param3": [self.formObjects[@"mr_id"] description],
                       @"param4": title,
                       @"param5": manIDs,
                       @"param6": manNames,
                       @"param7": orderDate ?: @"",
                       @"param8": time1,
                       @"param9": time2,
                       @"param10": self.formObjects[@"order_telno"] ?: @"",
                       @"param11": self.formObjects[@"mobile"] ?: @"",
                       @"param12": @"1",
                       @"param13": self.formObjects[@"memo"] ?: @"",
                       @"param14": specID,
                       @"param15": areaID,
                       @"param16": manageID,
                       @"param17": meetingType,
                       @"param18": isVideo,
                       @"param19": induID,
                       } completion:^(id result, NSError *error) {
                           [weakSelf handleResult2:result error:error];
                       }];
}

- (void)doSend
{
    
    // 检查预定日期
    if ( !self.formObjects[@"order_date"] ) {
        [self.contentView showHUDWithText:@"预定日期不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 检查预定时间
    
    if ( !self.formObjects[@"order_time.1"] || !self.formObjects[@"order_time.2"] ) {
        [self.contentView showHUDWithText:@"预定时间不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 预定时间不能超过4小时
    NSDate *firstTime = self.formObjects[@"order_time.1"];
    NSDate *lastTime  = self.formObjects[@"order_time.2"];
    
    NSTimeInterval dt = [firstTime timeIntervalSinceDate:lastTime];
    if ( !self.noLimit && fabs(dt) > 4 * 3600) {
        [self.contentView showHUDWithText:@"预定时间不能超过4小时"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( !self.noLimit && fabs(dt) < 30 * 60 ) {
        [self.contentView showHUDWithText:@"预定时间至少半小时"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    NSString *title = self.formObjects[@"title"] ?: @"";
    if ( title.length == 0 ) {
        [self.contentView showHUDWithText:@"会议主题必填"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    NSArray *contacts = self.formObjects[@"contacts"];
    if ( contacts.count == 0 ) {
        [self.contentView showHUDWithText:@"至少需要一个参与人"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 主持人
    Employ *item = [self.formObjects[@"contact"] firstObject];
    NSString *manageID = [item._id description] ?: @"0";
    
    // 专业
    NSString *specID = [self.formObjects[@"spec"][@"value"] ?: @"0" description];
    if ([specID isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"专业必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 区域
    NSString *areaID = [self.formObjects[@"area"][@"value"] ?: @"0" description];
    
    if ([areaID isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"区域必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 业态
    NSString *induID = [self.formObjects[@"industry"][@"value"] ?: @"0" description];
    
    if ([induID isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"业态必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 会议类型
    NSString *meetingType = [self.formObjects[@"meeting_type"][@"value"] ?: @"0" description];
    
    if ([meetingType isEqualToString:@"0"]) {
        [self.contentView showHUDWithText:@"会议类型必选"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    // 是否是视频会
    NSString *isVideo = [self.formObjects[@"is_video"] ?: @"0" description];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *orderDate = [df stringFromDate:self.formObjects[@"order_date"]];
    
    df.dateFormat = @"HH:mm";
    
    NSString *time1 = [df stringFromDate:self.formObjects[@"order_time.1"]];
    NSString *time2 = [df stringFromDate:self.formObjects[@"order_time.2"]];
    
    NSMutableString *manIDs = [NSMutableString stringWithString:@""];
    NSMutableString *manNames = [NSMutableString stringWithString:@""];
    for (Employ *emp in contacts) {
        [manIDs appendFormat:@"%@,", emp._id];
        [manNames appendFormat:@"%@,", emp.name];
    }
    
    [manIDs deleteCharactersInRange:NSMakeRange(manIDs.length - 1, 1)];
    [manNames deleteCharactersInRange:NSMakeRange(manNames.length - 1, 1)];
    
    __weak typeof(self) weakSelf = self;
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"新建会议室预定APP",
              @"param1": [self.params[@"item"][@"mr_id"] description], // 会议室id
              @"param2": title, // 会议主题
              @"param3": manIDs, // 参与人ID
              @"param4": manNames, // 参与人姓名
              @"param5": orderDate, // 预定日期
              @"param6": time1, // 预定开始时间
              @"param7": time2, // 预定结束时间
              @"param8": self.formObjects[@"memo"] ?: @"", // 申请人id
              @"param9": [self.formObjects[@"man_id"] description], // 申请人姓名
              @"param10": self.formObjects[@"order_telno"] ?:@"", // 分机号
              @"param11": self.formObjects[@"mobile"] ?:@"",
              @"param12": specID,
              @"param13": areaID,
              @"param14": manageID,
              @"param15": meetingType,
              @"param16": isVideo,
              @"param17": induID,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            if ( [self.params[@"form_type"] integerValue] == 1 ) {
                [self.navigationController.view showHUDWithText:@"预定成功" succeed:YES];
            } else if ( [self.params[@"form_type"] integerValue] == 2 ) {
                [self.navigationController.view showHUDWithText:@"更新预定成功" succeed:YES];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedReloadDataNotification" object:nil];
            
        } else {
            id dict = [result[@"data"] firstObject];
            
            [self.navigationController.view showHUDWithText:dict[@"message"] succeed:NO];
        }
        
    }
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (NSArray *)formControls
{
    return self.inFormControls;
}

- (BOOL)supportsTextArea
{
    return NO;
}

- (BOOL)supportsAttachment
{
    return NO;
}

- (BOOL)supportsCustomOpinion
{
    return NO;
}

@end

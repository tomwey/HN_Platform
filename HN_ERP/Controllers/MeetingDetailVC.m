//
//  MeetingDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 7/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingDetailVC.h"
#import "Defines.h"

@interface MeetingDetailVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation MeetingDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"会议详情";
    
    [self prepareDataSource];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStyleGrouped];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    __weak typeof(self) me = self;
    if ([HNStringFromObject(self.params[@"item"][@"jyflow_mid"], @"") length] > 0) {
        [self addRightItemWithTitle:@"纪要" titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                               size:CGSizeMake(40, 40)
                        rightMargin:10
                           callback:^{
                               [me gotoMeetingNotes];
                           }];
    }
}

- (void)gotoMeetingNotes
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingNotesDetailVC" params:self.params[@"item"] ?: @{}];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareDataSource
{
    self.dataSource = [@[] mutableCopy];
    
    NSMutableArray *sec1 = [@[] mutableCopy];
    [self.dataSource addObject:sec1];
    
    // 会议主题
    [sec1 addObject:@{
                                 @"label": @"会议主题",
                                 @"value": self.params[@"item"][@"title"] ?: @"无",
                                 }];
    
    // 会议时间
    NSString *beginTime = nil;
    NSString *endTime = nil;
    
    beginTime = HNDateTimeFromObject(self.params[@"item"][@"begintime"], @"T");
    endTime = HNDateTimeFromObject(self.params[@"item"][@"endtime"], @"T");
    
    if (beginTime.length > 5)
        beginTime = [[[beginTime componentsSeparatedByString:@" "] lastObject] substringToIndex:5];
    if (endTime.length > 5)
        endTime   = [[[endTime componentsSeparatedByString:@" "] lastObject] substringToIndex:5];
    
    NSString *orderDate = HNDateFromObject(self.params[@"item"][@"orderdate"], @"T");
    
    if ([self.params[@"is_this_week"] boolValue]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
        
        NSDate *date = [df dateFromString:orderDate];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dc = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday
                                           fromDate:date];
        
        orderDate = calendar.weekdaySymbols[dc.weekday-1];
    }
    NSString *meetingTime = [NSString stringWithFormat:@"%@ %@ - %@",
                             orderDate,
                             beginTime, endTime];
    
    [sec1 addObject:@{
                                 @"label": @"会议时间",
                                 @"value": meetingTime,
                                 }];
    // 会议地点
    [sec1 addObject:@{
                                 @"label": @"会议地点",
                                 @"value": self.params[@"item"][@"mr_name"] ?: @"无",
                                 }];
    
    // 参会人员
    NSString *manName = HNStringFromObject(self.params[@"item"][@"man_names"], @"");
    if (manName.length == 0) {
        manName = HNStringFromObject(self.params[@"item"][@"create_name"], @"无");
    }
    [sec1 addObject:@{
                                 @"label": @"参会人员",
                                 @"value": manName,
                                 }];
    
    // dddddd
    NSMutableArray *sec2_1 = [@[] mutableCopy];
    [self.dataSource addObject:sec2_1];
    [sec2_1 addObject:@{
                      @"label": @"专业",
                      @"value": HNStringFromObject(self.params[@"item"][@"spec_name"], @"无"),
                      }];
    [sec2_1 addObject:@{
                        @"label": @"区域",
                        @"value": HNStringFromObject(self.params[@"item"][@"area_name"], @"无"),
                        }];
    [sec2_1 addObject:@{
                        @"label": @"业态",
                        @"value": HNStringFromObject(self.params[@"item"][@"indusrty_name"], @"无"),
                        }];
    [sec2_1 addObject:@{
                        @"label": @"主持人",
                        @"value": HNStringFromObject(self.params[@"item"][@"manage_name"], @"无"),
                        }];
    [sec2_1 addObject:@{
                        @"label": @"会议类型",
                        @"value": HNStringFromObject(self.params[@"item"][@"meet_typename"], @"无"),
                        }];
    
    BOOL isVideo = [HNStringFromObject(self.params[@"item"][@"isvideo"], @"") boolValue];
    
    [sec2_1 addObject:@{
                        @"label": @"是否是视频会",
                        @"value": isVideo ? @"是" : @"否",
                        }];
    
    // 第二部分
    NSMutableArray *sec2 = [@[] mutableCopy];
    [self.dataSource addObject:sec2];
    
    [sec2 addObject:@{
                      @"label": @"申请人",
                      @"value": HNStringFromObject(self.params[@"item"][@"create_name"], @"无"),
                      }];
    [sec2 addObject:@{
                      @"label": @"申请部门",
                      @"value": HNStringFromObject(self.params[@"item"][@"create_deptname"], @"无"),
                      }];
    [sec2 addObject:@{
                      @"label": @"手机",
                      @"value": HNStringFromObject(self.params[@"item"][@"mobile"], @"无"),
                      }];
    [sec2 addObject:@{
                      @"label": @"分机号",
                      @"value": HNStringFromObject(self.params[@"item"][@"seatno"], @"无"),
                      }];
    
    // 第三部分备注
    NSMutableArray *sec3 = [@[] mutableCopy];
    [self.dataSource addObject:sec3];
    
    [sec3 addObject:@{
                      @"label": @"备注",
                      @"value": HNStringFromObject(self.params[@"item"][@"memo"], @"无"),
                      }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *id_ = [NSString stringWithFormat:@"cell.id%d", indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id_];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id_];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id item = self.dataSource[indexPath.section][indexPath.row];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    if ( !label ) {
        label = AWCreateLabel(CGRectMake(15, 5, 80, 34),
                              nil,
                              NSTextAlignmentLeft,
                              AWSystemFontWithSize(16, NO),
                              AWColorFromRGB(58, 58, 58));
        label.tag = 1001;
        [cell.contentView addSubview:label];
    }
    
    label.text = item[@"label"];
    
    UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    if ( !detailLabel ) {
        detailLabel = AWCreateLabel(CGRectMake(label.right, 5, self.contentView.width - 30 - label.width, 34),
                              nil,
                              NSTextAlignmentLeft,
                              AWSystemFontWithSize(16, NO),
                              AWColorFromRGB(58, 58, 58));
        detailLabel.tag = 1002;
        [cell.contentView addSubview:detailLabel];
        
        detailLabel.numberOfLines = 0;
        
        detailLabel.textColor = AWColorFromRGB(22, 17, 178);
    }
    
    detailLabel.text = item[@"value"];
    
    CGSize size = [detailLabel.text sizeWithFont:detailLabel.font
                                inConstraintSize:CGSizeMake(detailLabel.width,
                                                            CGFLOAT_MAX)];
    
    detailLabel.width = size.width;
    detailLabel.height = size.height;
    
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat top = ( height - detailLabel.height ) / 2.0;
    
    detailLabel.top = top;
    
    label.height = [label.text sizeWithFont:label.font
                           inConstraintSize:CGSizeMake(80, CGFLOAT_MAX)].height;
    label.top = top;
    
    label.numberOfLines = 0;
//    label.adjustsFontSizeToFitWidth = YES;
    
    if (detailLabel.height <= 44) {
        label.top = 44 / 2 - label.height / 2 + 3;
    }
    
    if ([label.text isEqualToString:@"手机"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.section][indexPath.row];
    
    if ( [item[@"label"] isEqualToString:@"手机"] ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    [NSString stringWithFormat:@"tel:%@",
                                                     item[@"value"]]]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.section][indexPath.row];
    
    NSString *value = item[@"value"];
    
    return [value sizeWithFont:AWSystemFontWithSize(16, NO)
              inConstraintSize:CGSizeMake(self.contentView.width - 110, CGFLOAT_MAX)].height + 30;
}

@end

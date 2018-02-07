//
//  MeetingOrderListVC.m
//  HN_ERP
//
//  Created by tomwey on 4/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingOrderListVC.h"
#import "Defines.h"
#import "MeetingDateRange.h"
#import "MeetingListView.h"

@interface MeetingOrderListVC ()

@property (nonatomic, strong) MeetingDateRange *dateRange;

@property (nonatomic, weak) MeetingListView *meetingListView;

@property (nonatomic, strong) NSMutableDictionary *meetingParams;

//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation MeetingOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"我的预定";
    
    // 添加日期选择控件
    UIView *blankView = [[UIView alloc] init];
    blankView.frame = CGRectMake(0, 0,
                                 self.contentView.width,
                                 60);
    [self.contentView addSubview:blankView];
    blankView.backgroundColor = [UIColor whiteColor];
    
    //            NSDate *now = [NSDate date];
    
    // 准备参数
    
    self.meetingParams = [@{} mutableCopy];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description] ?: @"0";
    self.meetingParams[@"man_id"] = manID;
    self.meetingParams[@"type"]   = @"1";
    
    // 初始化日期控件
    self.dateRange = [[MeetingDateRange alloc] init];
    self.dateRange.frame = blankView.bounds;
    [blankView addSubview:self.dateRange];
    
    __weak typeof(self) weakSelf = self;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:blankView];
    line.position = CGPointMake(0, blankView.height - 1);

    MeetingListView *listView = [[MeetingListView alloc] init];
    listView.frame = self.contentView.bounds;
    listView.top = blankView.bottom;
    listView.height = self.contentView.height - blankView.height;
    
    [self.contentView addSubview:listView];
    
    self.meetingListView = listView;
    
    //            __weak typeof(self) weakSelf = self;
    listView.didSelectMeetingItemBlock = ^(id item) {
        [weakSelf gotoMeeting:item];
    };
    
    self.dateRange.changeBlock = ^(MeetingDateRange *sender, NSInteger week, NSString *firstDate, NSString *lastDate)
    {
        weakSelf.meetingParams[@"firstDate"] = firstDate;
        weakSelf.meetingParams[@"lastDate"] = lastDate;
        [weakSelf loadMeetingData];
    };
    
    self.dateRange.currentDate = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editOrder:)
                                                 name:@"kUpdateMeetingOrderNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelOrder:)
                                                 name:@"kCancelMeetingOrderNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMeetingData)
                                                 name:@"kNeedReloadDataNotification"
                                               object:nil];
    
//    [self loadData];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(editOrder:)
//                                                 name:@"kEditMeetingOrderNotification"
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(cancelOrder:)
//                                                 name:@"kCancelMeetingOrderNotification"
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadData)
//                                                 name:@"kNeedReloadDataNotification"
//                                               object:nil];
    
}

- (void)loadMeetingData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        MeetingListView *listView =
        //        (MeetingListView *)[self.swipeView currentItemView];
        
        [self.meetingListView startLoadingWithParams:self.meetingParams
                                          completion:^(MeetingListView *sender)
         {
             [HNProgressHUDHelper hideHUDForView:weakSelf.contentView
                                        animated:YES];
         }];
    });
}


- (void)gotoMeeting:(id)item
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingDetailVC" params:@{ @"item": item ?: @{}, @"is_this_week": @(self.dateRange.isThisWeek) }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editOrder:(NSNotification *)noti
{
    id data = noti.object;
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewMeetingOrderVC" params:@{ @"item": data, @"form_type": @"2" }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelOrder:(NSNotification *)noti
{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action)
     {
         [self doCancel:noti.object];
     }];
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"您确定要取消吗？"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doCancel:(id)data
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    NSString *orderDate = [[data[@"orderdate"] componentsSeparatedByString:@"T"] firstObject];
    NSString *btime = [[[data[@"begintime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
    NSString *etime = [[[data[@"endtime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"更新会议室预定APP",
                       @"param1": [data[@"id"] description] ?: @"0",
                       @"param2": [data[@"create_id"] description] ?: @"0",
                       @"param3": [data[@"mr_id"] description] ?: @"0",
                       @"param4": [data[@"title"] description] ?: @"",
                       @"param5": [data[@"man_ids"] description] ?: @"",
                       @"param6": [data[@"man_names"] description] ?: @"",
                       @"param7": orderDate ?: @"",
                       @"param8": btime ?: @"",
                       @"param9": etime ?: @"",
                       @"param10": [data[@"seatno"] description] ?: @"",
                       @"param11": [data[@"mobile"] description] ?: @"",
                       @"param12": @"0",
                       @"param13": [data[@"memo"] description] ?: @"",
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
            //            [self loadData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedReloadDataNotification" object:nil];
        } else {
            [self.contentView showHUDWithText:@"取消预定失败" succeed:YES];
        }
    }
}

//- (void)loadData
//{
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
//    
//    id user = [[UserService sharedInstance] currentUser];
//    NSString *manID = [user[@"man_id"] ?: @"0" description];
//    __weak MeetingOrderListVC *weakSelf = self;
//    [[self apiServiceWithName:@"APIService"]
//     POST:nil params:@{
//                       @"dotype": @"GetData",
//                       @"funname": @"查询我的今日预定会议室APP",
//                       @"param1": manID,
//                       }
//     completion:^(id result, NSError *error)
//     {
//         [weakSelf handleResult:result error:error];
//     }];
//}

//- (void)handleResult:(id)result error:(NSError *)error
//{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//    
//    if ( error ) {
////        [self.contentView showHUDWithText:error.domain succeed:NO];
//        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
//    } else {
//        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            self.dataSource.dataSource = nil;
////            [self.contentView showHUDWithText:@"<没有预定显示>" offset:CGPointMake(0,20)];
//            [self.tableView showErrorOrEmptyMessage:@"<没有数据显示>" reloadDelegate:nil];
//        } else {
//            self.dataSource.dataSource = result[@"data"];
//        }
//        
//        [self.tableView reloadData];
//    }
//}

//- (void)editOrder:(NSNotification *)noti
//{
//    id data = noti.object;
//    
//    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewMeetingOrderVC" params:@{ @"item": data, @"form_type": @"2" }];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)cancelOrder:(NSNotification *)noti
//{
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
//                                                           style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction * _Nonnull action) {
//                                                             
//                                                         }];
//    UIAlertAction *okAction =
//        [UIAlertAction actionWithTitle:@"确定"
//                                 style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * _Nonnull action)
//    {
//        [self doCancel:noti.object];
//    }];
//    UIAlertController *alert =
//        [UIAlertController alertControllerWithTitle:@"您确定要取消吗？"
//                                            message:nil
//                                     preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:okAction];
//    [alert addAction:cancelAction];
//    
//    [self presentViewController:alert animated:YES completion:nil];
//}
//
//- (void)doCancel:(id)data
//{
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
//    
//    __weak typeof(self) weakSelf = self;
//
//    NSString *orderDate = [[data[@"orderdate"] componentsSeparatedByString:@"T"] firstObject];
//    NSString *btime = [[[data[@"begintime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
//        NSString *etime = [[[data[@"endtime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
//    
//    [[self apiServiceWithName:@"APIService"]
//     POST:nil params:@{
//                       @"dotype": @"GetData",
//                       @"funname": @"更新会议室预定APP",
//                       @"param1": [data[@"id"] description] ?: @"0",
//                       @"param2": [data[@"create_id"] description] ?: @"0",
//                       @"param3": [data[@"mr_id"] description] ?: @"0",
//                       @"param4": orderDate ?: @"",
//                       @"param5": btime ?: @"",
//                       @"param6": etime ?: @"",
//                       @"param7": [data[@"seatno"] description] ?: @"",
//                       @"param8": @"0",
//                       @"param9": [data[@"memo"] description] ?: @"",
//                       } completion:^(id result, NSError *error) {
//                           [weakSelf handleResult2:result error:error];
//                       }];
//}
//
//- (void)handleResult2:(id)result error:(NSError *)error
//{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//    
//    if ( error ) {
//        [self.contentView showHUDWithText:error.domain succeed:NO];
//    } else {
//        if ( [result[@"rowcount"] integerValue] == 0 ) {
////            [self loadData];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedReloadDataNotification" object:nil];
//        } else {
//            [self.contentView showHUDWithText:@"取消预定失败" succeed:YES];
//        }
//    }
//}

//- (UITableView *)tableView
//{
//    if ( !_tableView ) {
//        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
//                                                  style:UITableViewStylePlain];
//        [self.contentView addSubview:_tableView];
//        
//        _tableView.dataSource = self.dataSource;
//        _tableView.rowHeight = 80;
//        
//        [_tableView removeBlankCells];
//    }
//    return _tableView;
//}

//- (AWTableViewDataSource *)dataSource
//{
//    if ( !_dataSource ) {
//        _dataSource = AWTableViewDataSourceCreate(nil, @"MeetingOrderCell", @"meeting.cell");
//    }
//    return _dataSource;
//}

@end

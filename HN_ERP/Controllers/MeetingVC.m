//
//  MeetingVC.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingVC.h"
#import "Defines.h"
#import "MeetingListView.h"
#import "MeetingDateRange.h"
#import "MeetingNotesListView.h"

@interface MeetingVC () <AWPagerTabStripDataSource, AWPagerTabStripDelegate, SwipeViewDataSource, SwipeViewDelegate>//<UITableViewDataSource>

//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSArray     *dataSource;
//
//@property (nonatomic, assign) CGFloat gridWidth;
//@property (nonatomic, assign) CGFloat gridHeight;

@property (nonatomic, strong) MeetingDateRange *dateRange;

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) SwipeView *swipeView;

@property (nonatomic, strong) NSMutableDictionary *meetingParams;

@property (nonatomic, strong) NSMutableDictionary *swipeSubviews;

@property (nonatomic, weak) MeetingListView *meetingListView;

@end

#define GRID_SPACING 15

@implementation MeetingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"会议系统";
    
    __weak typeof(self) weakSelf = self;
    [self addRightItemWithTitle:@"新增预定"
                titleAttributes:@{
                                  NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(64, 40)
                    rightMargin:10 callback:^{
                        [weakSelf gotoNewOrder];
                    }];
    
    // 创建滚动标签
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    self.tabStrip.dataSource = self;
    self.tabStrip.delegate   = self;
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.tabStrip.titleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: AWColorFromRGB(137,137,137) };
    self.tabStrip.selectedTitleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: MAIN_THEME_COLOR };
    
    // 添加滚动试图
    self.swipeView = [[SwipeView alloc] initWithFrame:
                      CGRectMake(0, self.tabStrip.bottom,
                                 self.contentView.width, self.contentView.height - self.tabStrip.bottom)];
    [self.contentView addSubview:self.swipeView];
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate   = self;
    
    // 加载数据
    self.tabTitles = @[@"我的会议",@"会议纪要"];
    
    self.tabStrip.tabWidth = (self.contentView.width / self.tabTitles.count);
    
    [self.tabStrip reloadData];
    
    [self.swipeView reloadData];
    
//    self.meetingParams[@"date"]   = self.dateSelectControl.currentDate;
    
//    [self loadMeetingData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMeetingData)
                                                 name:@"kNeedReloadDataNotification"
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(editOrder:)
//                                                 name:@"kUpdateMeetingOrderNotification"
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(cancelOrder:)
//                                                 name:@"kCancelMeetingOrderNotification"
//                                               object:nil];
    
//    self.dateRange.currentDate = now;
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"会议"
                                    keyMemo:nil];
}

- (void)gotoNewOrder
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingRoomVC" params:nil];
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

- (NSMutableDictionary *)meetingParams
{
    if ( !_meetingParams ) {
        _meetingParams = [@{} mutableCopy];
    }
    return _meetingParams;
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

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.tabTitles.count;
}

- (UIView *)swipeSubviewForIndex:(NSInteger)index
{
    static const int viewCount = 2;
    static NSString * viewNames[viewCount] = {
        @"MeetingListView",
        @"MeetingNotesListView",
    };
    
    if  ( index >= viewCount ) {
        return nil;
    }
    
    UIView *view = self.swipeSubviews[@(index)];
    if ( !view ) {
        view = [[NSClassFromString(viewNames[index]) alloc] init];
        view.frame = self.swipeView.bounds;
        self.swipeSubviews[@(index)] = view;
    }
    return view;
}

- (NSMutableDictionary *)swipeSubviews
{
    if ( !_swipeSubviews ) {
        _swipeSubviews = [@{} mutableCopy];
    }
    return _swipeSubviews;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    if ( index == 0 ) {
        UIView *meetingContainerView = self.swipeSubviews[@(index)];
        if ( !meetingContainerView ) {
            
            meetingContainerView = [[UIView alloc] init];
            meetingContainerView.frame = swipeView.bounds;
            
            self.swipeSubviews[@(index)] = meetingContainerView;
            
            // 添加日期选择控件
            UIView *blankView = [[UIView alloc] init];
            blankView.frame = CGRectMake(0, 0,
                                         self.contentView.width,
                                         60);
            [meetingContainerView addSubview:blankView];
            blankView.backgroundColor = [UIColor whiteColor];
            
//            NSDate *now = [NSDate date];
            
            // 准备参数
            id user = [[UserService sharedInstance] currentUser];
            NSString *manID = [user[@"man_id"] description] ?: @"0";
            self.meetingParams[@"man_id"] = manID;
            self.meetingParams[@"type"]   = @"0";
            
            // 初始化日期控件
            self.dateRange = [[MeetingDateRange alloc] init];
            self.dateRange.frame = blankView.bounds;
            [blankView addSubview:self.dateRange];
            
            __weak typeof(self) weakSelf = self;
            
            AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:blankView];
            line.position = CGPointMake(0, blankView.height - 1);
            
            MeetingListView *listView = [[MeetingListView alloc] init];
            listView.frame = swipeView.bounds;
            listView.top = blankView.bottom;
            listView.height = swipeView.height - blankView.height;
            
            [meetingContainerView addSubview:listView];
            
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
            
        }
        
        return meetingContainerView;
        
    } else if ( index == 1 ) {
        MeetingNotesListView *listView = self.swipeSubviews[@(index)];
        if ( !listView ) {
            listView = [[MeetingNotesListView alloc] init];
            listView.frame = swipeView.bounds;
            
            self.swipeSubviews[@(index)] = listView;
            
            __weak typeof(self) weakSelf = self;
            listView.itemDidSelectBlock = ^(UIView <AWTableDataConfig> *sender, id data) {
                [weakSelf gotoMeetingNotesDetail:data];
            };
        }
        return listView;
    } else {
        return nil;
    }
}

- (void)gotoMeetingNotesDetail:(id)data
{
    NSLog(@"data: %@", data);
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingNotesDetailVC" params:data ?: @{}];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoMeeting:(id)item
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingDetailVC" params:@{ @"item": item ?: @{}, @"is_this_week": @(self.dateRange.isThisWeek) }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
//    self.meetingParams[@"type"] = [@(swipeView.currentPage) description];
    
//    __weak typeof(self) weakSelf = self;
//    
//    if (swipeView.currentPage == 0) {
//        [self addRightItemWithTitle:@"新增预定"
//                    titleAttributes:@{
//                                      NSFontAttributeName: AWSystemFontWithSize(15, NO) }
//                               size:CGSizeMake(64, 40)
//                        rightMargin:10 callback:^{
//                            [weakSelf gotoNewOrder];
//                        }];
//        
//        [self loadMeetingData];
//        
//    } else if (swipeView.currentPage == 1) {
//        // 添加搜索按钮
//        [self addRightItemWithImage:@"btn_search.png" rightMargin:2 callback:^{
//            [weakSelf doSearch];
//        }];
//    }
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[self swipeSubviewForIndex:swipeView.currentPage] performSelector:@selector(startLoading) withObject:nil];
//    });
//    
//    if ( self.swipeView.currentPage == 0 ) {
//        [self addRightItemWithView:self.segControl rightMargin:10];
//    } else {
//        [self addRightItemWithView:nil];
//        _segControl = nil;
//    }
}

- (void)doSearch
{
    
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return [self.tabTitles count];
}

- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index];
}

- (void)pagerTabStrip:(AWPagerTabStrip *)tabStrip didSelectTabAtIndex:(NSInteger)index
{
    self.swipeView.currentPage = index;
    //    [self.swipeView scrollToPage:index duration:.3];
}

/*
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navBar.title = @"会议";
 
    __weak typeof(self) weakSelf = self;
    [self addRightItemWithTitle:@"新增预定"
                titleAttributes:@{
                                  NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(64, 40)
                    rightMargin:10 callback:^{
                        [weakSelf gotoMyOrders];
                    }];
    
    // 添加日期选择控件
    self.dateSelectControl = [[DateSelectControl alloc] init];
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1
                        toDate:now
                       options:0];
    
    self.dateSelectControl.minimumDate = now;
    self.dateSelectControl.maximumDate = tomorrow;
    
    self.dateSelectControl.frame = CGRectMake(15, 0, self.contentView.width - 30,
                                              60);

    self.dateSelectControl.currentDateDidChangeBlock = ^(DateSelectControl *sender) {
        NSLog(@"date: %@", sender.currentDate);
        [weakSelf loadData];
    };
    
    self.dateSelectControl.currentDate = now;
    self.dateSelectControl.top = 10;
    
    [self.contentView addSubview:self.dateSelectControl];
    
//    __weak MeetingVC *weakSelf = self;
    self.dateSelectControl.openDatePickerBlock = ^(DateSelectControl *sender) {
        DatePicker *dp = [[DatePicker alloc] init];
        dp.frame = weakSelf.contentView.bounds;
        
        dp.minimumDate = now;
        dp.maximumDate = tomorrow;
        
        [dp showPickerInView:weakSelf.contentView];
        dp.currentSelectedDate = sender.currentDate;
        dp.didSelectDateBlock = ^(DatePicker *_sender, NSDate *selectedDate) {
            sender.currentDate = selectedDate;
        };
    };
    
    // 添加会议室
    self.gridWidth = ceilf( (self.contentView.width - GRID_SPACING * ( [self numberOfCols] + 1 ) ) / [self numberOfCols] );
    self.gridHeight = self.gridWidth / 1;
    
    self.tableView.top = self.dateSelectControl.bottom + 10;
    self.tableView.height -= self.dateSelectControl.bottom + 10;
    
    self.tableView.rowHeight = GRID_SPACING + self.gridHeight;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GRID_SPACING, 0);
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kNeedReloadDataNotification"
                                               object:nil];
}

- (void)gotoMyOrders
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingRoomVC" params:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    __weak MeetingVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"boardroom",
                       //@"funname": @"会议室查询APP",
                       @"date": self.dateSelectControl.currentDateString,
                       }
     completion:^(id result, NSError *error)
    {
        [weakSelf handleResult:result error:error];
    }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            self.dataSource = nil;
            [self.contentView showHUDWithText:@"<没有数据显示>" offset:CGPointZero];
        } else {
            self.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfCols
{
    return 2;
//    if ( self.contentView.width > 320 ) {
//        return 3;
//    }
//    return 2;
}

- (NSInteger)rowsForData
{
    return (self.dataSource.count + [self numberOfCols] - 1 ) / [self numberOfCols];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self rowsForData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self addRoomsForCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)addRoomsForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger gridNum = [self numberOfCols];
    if ( indexPath.row == [self rowsForData] - 1 ) {
        gridNum = self.dataSource.count - [self numberOfCols] * indexPath.row;
    }
    
    if ( indexPath.row == [self rowsForData] - 1 ) {
        for (int i = gridNum; i<[self numberOfCols]; i++) {
            [[cell.contentView viewWithTag:100 + i] removeFromSuperview];
        }
    }
    
    for (int i=0; i<gridNum; i++) {
        MeetingRoom *view = (MeetingRoom *)[cell.contentView viewWithTag:100 + i];
        if ( !view ) {
            view = [[MeetingRoom alloc] initWithFrame:CGRectMake(GRID_SPACING + ( self.gridWidth + GRID_SPACING ) * i, GRID_SPACING, self.gridWidth, self.gridHeight)];
            [cell.contentView addSubview:view];
            view.tag = 100 + i;
            
            view.openBlock = ^(MeetingRoom *sender) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewMeetingOrderVC" params:@{ @"item": sender.meetingData ?: @{}, @"currentDate": self.dateSelectControl.currentDate ?: [NSDate date], @"form_type": @"1" }];
                [self.navigationController pushViewController:vc animated:YES];
            };
        }
        
        NSInteger index = [self numberOfCols] * indexPath.row + i;
        if ( index < self.dataSource.count ) {
            view.meetingData = self.dataSource[index];
        }
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        
        [_tableView removeBlankCells];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
*/

@end

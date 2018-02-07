//
//  MeetingVC.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingRoomVC.h"
#import "Defines.h"

@interface MeetingRoomVC () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataSource;

@property (nonatomic, assign) CGFloat gridWidth;
@property (nonatomic, assign) CGFloat gridHeight;

@property (nonatomic, strong) DateSelectControl *dateSelectControl;

@end

#define GRID_SPACING 15

@implementation MeetingRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"选择会议室";
    
    __weak typeof(self) weakSelf = self;
    [self addRightItemWithTitle:@"我的预定"
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
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingOrderListVC" params:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    __weak MeetingRoomVC *weakSelf = self;
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

@end

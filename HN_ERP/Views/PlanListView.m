//
//  PlanListView.m
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanListView.h"
#import "Defines.h"
#import "YearMonthPickerView.h"

@interface PlanListView () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) NSArray *testAllPlans;
@property (nonatomic, strong) NSArray *testNoCompletedPlans;

@property (nonatomic, strong) DateSelectControl *dateSelectControl;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) YearMonthPickerView *pickerView;

@end

@implementation PlanListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadPlans)
                                                     name:@"kPlanFlowDidCommitNotification"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dateSelectControl.frame = CGRectMake(15, 0, self.width - 30, 60);
    
    self.tableView.frame = self.bounds;
    self.tableView.top = self.dateSelectControl.bottom;
    self.tableView.height = self.height - self.dateSelectControl.height;
}

- (void)startLoading
{
    [self loadPlans];
}

- (NSDateComponents *)dateComponetsFromDate:(NSDate *)date
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calender components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    return comp;
}

- (void)loadPlans
{
    if ( self.loading ) return;
    
    self.loading = YES;
    
    [self.tableView removeErrorOrEmptyTips];
    
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    NSInteger year = [self dateComponetsFromDate:self.currentDate].year;
    NSInteger month = [self dateComponetsFromDate:self.currentDate].month;
    
    NSString *yearStr = [@(year) description];
    NSString *monthStr = [@(month) description];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [self.tableView removeErrorOrEmptyTips];
    
    __weak PlanListView *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"工作计划查询APP",
                       @"param1": manID,
                       @"param2": yearStr,
                       @"param3": monthStr,
                       @"param4": [@(self.dataType) description],
                       } completion:^(id result, NSError *error) {
                           __strong PlanListView *strongSelf = weakSelf;
                           if ( strongSelf ) {
                               [strongSelf handleResult:result error:error];
                           }
                       }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.loading = NO;
    
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    
    [self.tableView.pullToRefreshView stopAnimating];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {            
            
            self.dataSource.dataSource = result[@"data"];
        }
        [self.tableView reloadData];
    }
}

// 项目，层级，计划名称，完成时间，是否完成
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self, self.dataSource.dataSource[indexPath.row]);
    }
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[AWTableViewDataSource alloc] initWithArray:nil cellClass:@"PlanCell" identifier:@"cell.plan.id"];
    }
    return _dataSource;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = [UIColor clearColor];
        
        _tableView.rowHeight = 120;
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        [_tableView removeCompatibility];
        
        [_tableView removeBlankCells];
        
        // 添加下拉刷新
        __weak PlanListView *weakSelf = self;
        [_tableView addPullToRefreshWithActionHandler:^{
            __strong PlanListView *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf loadPlans];
            }
        }];
        
        // 配置下拉刷新功能
        HNRefreshView *stopView = [[HNRefreshView alloc] init];
        stopView.text = @"下拉刷新";
        
        HNRefreshView *loadingView = [[HNRefreshView alloc] init];
        loadingView.text = @"加载中...";
        loadingView.animated = YES;
        
        HNRefreshView *triggerView = [[HNRefreshView alloc] init];
        triggerView.text = @"松开刷新";
        triggerView.animated = YES;
        
        [_tableView.pullToRefreshView setCustomView:triggerView forState:SVPullToRefreshStateTriggered];
        [_tableView.pullToRefreshView setCustomView:loadingView forState:SVPullToRefreshStateLoading];
        [_tableView.pullToRefreshView setCustomView:stopView forState:SVPullToRefreshStateStopped];
    }
    
    return _tableView;
}

- (NSDate *)currentDate
{
    if ( !_currentDate ) {
        _currentDate = [NSDate date];
    }
    return _currentDate;
}

- (DateSelectControl *)dateSelectControl
{
    if ( !_dateSelectControl ) {
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 60)];
        blankView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:blankView];
        blankView.backgroundColor = [UIColor whiteColor];
        
        // 添加日期选择控件
        _dateSelectControl = [[DateSelectControl alloc] init];
        
        NSDate *now = [NSDate date];
        
//        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
//        NSDate *tomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1
//                                               toDate:now
//                                              options:0];
        
//        _dateSelectControl.minimumDate = now;
        _dateSelectControl.maximumDate = now;
        
        __weak typeof(self) weakSelf = self;
        _dateSelectControl.currentDateDidChangeBlock = ^(DateSelectControl *sender) {
            NSLog(@"date: %@", sender.currentDate);
            weakSelf.currentDate = sender.currentDate;
            
            [weakSelf loadPlans];
        };
        _dateSelectControl.openDatePickerBlock = ^(DateSelectControl *sender) {
            [weakSelf openDatePicker];
        };
        _dateSelectControl.backgroundColor = [UIColor whiteColor];
        
        _dateSelectControl.controlMode = DateControlModeYearMonth;
        
        _dateSelectControl.currentDate = now;
        [self addSubview:_dateSelectControl];
        
    }
    return _dateSelectControl;
}

- (void)openDatePicker
{
    YearMonthPickerView *pickerView = [[YearMonthPickerView alloc] init];
    pickerView.currentDate = self.currentDate;
    pickerView.doneCallback = ^(YearMonthPickerView *sender) {
        self.currentDate = sender.currentDate;
        self.dateSelectControl.currentDate = sender.currentDate;
        
        [self loadPlans];
    };
    [pickerView showInView:self.superview.superview.superview];
}

@end

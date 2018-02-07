//
//  CityMapBIVC.m
//  HN_ERP
//
//  Created by tomwey on 20/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CityMapBIVC.h"
#import "Defines.h"
#import "BIVIewProtocol.h"
#import "HNCityAreaSelect.h"
#import "SelectButton.h"
#import "YearMonthPickerView.h"

@interface CityMapBIVC () <SwipeViewDelegate, SwipeViewDataSource, AWPagerTabStripDataSource, AWPagerTabStripDelegate>

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) SwipeView       *swipeView;

@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) NSMutableDictionary *swipePages;

@property (nonatomic, strong) NSArray *areaData;
@property (nonatomic, strong) id userDefaultArea;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) HNCityAreaSelect *areaSelect;


@property (nonatomic, strong) SelectButton *beginDateButton;
@property (nonatomic, strong) SelectButton *endDateButton;

@property (nonatomic, strong) YearMonthPickerView *monthYearPicker;

@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *maxEndDate;

@property (nonatomic, strong) UILabel *spliterLabel;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, assign) BOOL hasLoadedMaxDate;

@end

@implementation CityMapBIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"城市指标分析";
    
    self.contentView.backgroundColor = AWColorFromRGB(254, 254, 254);
    
    self.tabTitles = @[@{
                           @"name": @"供销价走势",
                           @"type": @"0",
                           @"page": @"SupplySellView",
                           },
                       @{
                           @"name": @"成交分段占比",
                           @"type": @"1",
                           @"page": @"SellPhaseView",
                           },
                       ];
    
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = MAIN_THEME_COLOR;
    
    self.tabStrip.tabWidth = self.contentView.width / self.tabTitles.count;
    
    self.tabStrip.titleAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: AWSystemFontWithSize(14, NO) };;
    self.tabStrip.selectedTitleAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                               NSFontAttributeName: AWSystemFontWithSize(14, NO) };
    
    //    self.tabStrip.delegate   = self;
    self.tabStrip.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    self.tabStrip.didSelectBlock = ^(AWPagerTabStrip* stripper, NSUInteger index) {
        //        weakSelf.swipeView.currentPage = index;
        __strong CityMapBIVC *strongSelf = weakSelf;
        if ( strongSelf ) {
            // 如果duration设置为大于0.0的值，动画滚动，tab stripper动画会有bug
            [strongSelf.swipeView scrollToPage:index duration:0.0f]; // 0.35f
            [strongSelf swipeViewDidEndDecelerating:strongSelf.swipeView];
        }
    };
    
    // 区域和时间
    UILabel *label = AWCreateLabel(CGRectMake(0, 0, 70, 34),
                                   @"城市板块:",
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(58, 58, 58));
    [self.contentView addSubview:label];
    label.position = CGPointMake(15, self.tabStrip.bottom + 10);
    
    self.areaSelect = [[HNCityAreaSelect alloc] init];
    
    [self.contentView addSubview:self.areaSelect];
    
    CGFloat areaWidth = self.contentView.width - 15 * 2 - label.width - 5;
    
    self.areaSelect.frame = CGRectMake(label.right + 5, label.top, areaWidth,
                                       label.height);
    
    [self.areaSelect prepareData];
    
    __weak typeof(self) me = self;
    self.areaSelect.selectBlock = ^(HNCityAreaSelect *sender) {
        [me loadMaxDateForCityID:sender.cityID platID:sender.platID];
    };
    
    // 时间
    CGFloat timeLabelWidth = ( areaWidth - self.spliterLabel.width ) / 2.0;
    
    label = AWCreateLabel(CGRectMake(0, 0, 70, 34),
                                   @"时间区间:",
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(58, 58, 58));
    [self.contentView addSubview:label];
    label.position = CGPointMake(15, self.areaSelect.bottom + 5);
    
    self.beginDateButton.frame = CGRectMake(0, 0, timeLabelWidth, 34);
    self.endDateButton.frame   = self.beginDateButton.frame;
    
    self.beginDateButton.left = self.areaSelect.left;
    self.beginDateButton.top  = label.top;
    
    
    self.spliterLabel.position = CGPointMake(self.beginDateButton.right,
                                             label.midY - self.spliterLabel.height / 2);
    self.endDateButton.position = CGPointMake(self.spliterLabel.right,
                                              label.top);
    
    // 翻页视图
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0,
                                          label.bottom + 5,
                                          self.tabStrip.width,
                                          self.contentView.height - label.bottom - 5);
        
        self.swipeView.delegate = self;
        self.swipeView.dataSource = self;
        
        self.swipeView.backgroundColor = self.contentView.backgroundColor;
    }
    
    [self pageStartLoadingData];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"城市指标分析"
                                    keyMemo:nil];
}

- (void)loadMaxDateForCityID:(NSString *)cityID platID:(NSString *)platID
{
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"城市地图BI获取最大年月APP",
              @"param1": cityID ?: @"0",
              @"param2": platID ?: @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    if ( !error ) {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            id data = result[@"data"][0];
            
            [self updateTimeDuration:data];
        }
    }
    
    [self dateChanged];
}

- (void)updateTimeDuration:(id)data
{
    self.hasLoadedMaxDate = YES;
    
    NSInteger year = [data[@"fyear"] integerValue];
    NSInteger month = [data[@"fmonth"] integerValue];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    
    dc.year = year;
    dc.month = month;
    
    self.endDate = [calendar dateFromComponents:dc];
    self.maxEndDate = self.endDate;
    
    dc.month = 1;
    
    self.beginDate = [calendar dateFromComponents:dc];
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return [self.tabTitles count];
}

- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index][@"name"];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.tabTitles count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    return [self swipePageForIndex:index];
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    //    NSLog(@"index: %d", swipeView.currentPage);
    
    // 更新标签状态
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    //    [self pageStartLoadingData];
}

- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
    self.currentPage = self.swipeView.currentPage;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    NSLog(@"end decelerate");
    if ( self.currentPage != self.swipeView.currentPage ) {
        self.currentPage = self.swipeView.currentPage;
        
        [self startLoadingData];
    }
}

- (void)swipeViewDidEndScrollingAnimation:(SwipeView *)swipeView
{
    NSLog(@"end scrolling");
}

- (void)pageStartLoadingData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startLoadingData];
    });
}

- (NSString *)datePartialForDate:(NSDate *)date type:(NSInteger)type
{
    if (!date) return nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dc = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    
    if ( type == 0 ) {
        return [@(dc.year) description];
    }
    
    if ( type == 1 ) {
        return [@(dc.month) description];
    }
    
    return nil;
}

- (NSString *)beginYear
{
    return [self datePartialForDate:self.beginDate type:0];
}

- (NSString *)beginMonth
{
    return [self datePartialForDate:self.beginDate type:1];
}

- (NSString *)endYear
{
    return [self datePartialForDate:self.endDate type:0];
}

- (NSString *)endMonth
{
    return [self datePartialForDate:self.endDate type:1];
}

- (void)startLoadingData
{
    UIView <BIViewProtocol> *view = [self swipePageForIndex:self.swipeView.currentPage];
    //        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    view.userData = @{ @"cityID": self.areaSelect.cityID ?: @"0",
                       @"platID": self.areaSelect.platID ?: @"0",
                       @"bYear": [self beginYear] ?: @"",
                       @"bMonth": [self beginMonth] ?: @"",
                       @"eYear": [self endYear] ?: @"",
                       @"eMonth": [self endMonth] ?: @"",
                       };
    [view startLoadingData:^(BOOL succeed, NSError *error) {
        //            [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    }];
}

- (NSString *)swipePageNameForIndex:(NSInteger)index
{
    if ( index < self.tabTitles.count ) {
        return self.tabTitles[index][@"page"];
    }
    return nil;
}

- (UIView <BIViewProtocol> *)swipePageForIndex:(NSInteger)index
{
    NSString *pageName = [self swipePageNameForIndex:index];
    if ( !pageName ) {
        return nil;
    }
    
    UIView <BIViewProtocol> *view = self.swipePages[pageName];
    if ( !view ) {
        view = [[NSClassFromString(pageName) alloc] init];
        view.frame = CGRectMake(0, 0, self.swipeView.width, self.swipeView.height);
        if (view) {
            self.swipePages[pageName] = view;
        }
    }
    
    view.userDefaultArea = self.userDefaultArea;
    view.areaData = self.areaData;
    view.navController = self.navigationController;
    
    return view;
}

- (NSMutableDictionary *)swipePages
{
    if ( !_swipePages ) {
        _swipePages = [[NSMutableDictionary alloc] init];
    }
    return _swipePages;
}

- (void)openDatePickerForType:(NSInteger)type
{
    if ( !self.hasLoadedMaxDate ) return;
    
    YearMonthPickerView *pickerView = [[YearMonthPickerView alloc] init];
    pickerView.currentDate = type == 0 ? self.beginDate : self.endDate;
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    dc.year = 2013;
    dc.month = 1;
    dc.day = 1;
    
    pickerView.minimumDate = [currentCalendar dateFromComponents:dc];
    pickerView.maximumDate = self.maxEndDate ?: [NSDate date];
    
    pickerView.doneCallback = ^(YearMonthPickerView *sender) {
        if ( type == 0 ) {
            if (![self isTheSameYearMonthBetween:self.beginDate and:sender.currentDate]) {
                self.beginDate = sender.currentDate;
                
                [self startLoadingData];
            }
            
            //            [self updateButtonTitle:self.beginDateButton];
        } else {
            if (![self isTheSameYearMonthBetween:self.endDate and:sender.currentDate]) {
                self.endDate = sender.currentDate;
                
                [self startLoadingData];
            }
//            self.endDate   = sender.currentDate;
            //            [self updateButtonTitle:self.endDateButton];
        }
        //        self.currentDate = sender.currentDate;
        //        self.dateSelectControl.currentDate = sender.currentDate;
        
//        [self startLoadData];
    };
    [pickerView showInView:self.contentView];
}

- (BOOL)isTheSameYearMonthBetween:(NSDate *)date1 and:(NSDate *)date2
{
    if ([date1 isEqualToDate:date2]) return YES;
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dc1 = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                               fromDate:date1];
    NSDateComponents *dc2 = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                               fromDate:date2];
    return (dc1.year == dc2.year && dc1.month == dc2.month);
}

- (NSString *)titleFromDate:(NSDate *)date
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    
    return [NSString stringWithFormat:@"%d年%d月", dc.year, dc.month];
}

- (void)setBeginDate:(NSDate *)beginDate
{
//    if (_beginDate != beginDate) {
        _beginDate = beginDate;
        
        self.beginDateButton.title = [self titleFromDate:beginDate];
        
//        [self startLoadingData];
        
//        [self dateChanged];
//    }
}

- (void)setEndDate:(NSDate *)endDate
{
//    if ( _endDate != endDate ) {
        _endDate = endDate;
        
        self.endDateButton.title = [self titleFromDate:endDate];
        
//        [self startLoadingData];
//        [self dateChanged];
//    }
}

- (void)dateChanged
{
    if ( self.beginDate && self.endDate ) {
        [self startLoadingData];
    }
}

- (SelectButton *)beginDateButton
{
    if ( !_beginDateButton ) {
        _beginDateButton = [[SelectButton alloc] init];
        [self.contentView addSubview:_beginDateButton];
        
        __weak typeof(self) me = self;
        _beginDateButton.clickBlock = ^(SelectButton *sender) {
            //            [me select];
            [me openDatePickerForType:0];
        };
    }
    return _beginDateButton;
}

- (SelectButton *)endDateButton
{
    if ( !_endDateButton ) {
        _endDateButton = [[SelectButton alloc] init];
        [self.contentView addSubview:_endDateButton];
        
        __weak typeof(self) me = self;
        _endDateButton.clickBlock = ^(SelectButton *sender) {
            //            [me select];
            [me openDatePickerForType:1];
        };
    }
    return _endDateButton;
}

- (UILabel *)spliterLabel
{
    if ( !_spliterLabel ) {
        _spliterLabel = AWCreateLabel(CGRectMake(0, 0, 34, 34),
                                      @"至",
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(14, NO),
                                      AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_spliterLabel];
    }
    return _spliterLabel;
}

@end

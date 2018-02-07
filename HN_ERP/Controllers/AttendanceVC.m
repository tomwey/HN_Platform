//
//  AttendanceVC.m
//  HN_ERP
//
//  Created by tomwey on 5/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AttendanceVC.h"
#import "Defines.h"
#import "FSCalendar.h"

@interface AttendanceVC () <FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDataSource>

@property (nonatomic, strong) FSCalendar *calendar;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSDateFormatter *dateFormater;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tableDataSource;

@property (nonatomic, strong) UILabel *viewTipLabel;

@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) NSMutableArray *errorAttendances;

@end

@implementation AttendanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"考勤";
    
    self.dateFormater = [[NSDateFormatter alloc] init];
    self.dateFormater.dateFormat = @"yyyy-MM-dd";
    
    self.errorAttendances = [@[] mutableCopy];
    
//    self.calendar.hidden = NO;
    
    self.calendar.appearance.eventDefaultColor = AWColorFromRGB(138, 138, 138);
    self.calendar.appearance.selectionColor = MAIN_THEME_COLOR;
//    self.calendar.appearance.eventSelectionColor = MAIN_THEME_COLOR;
    self.calendar.appearance.todayColor = MAIN_THEME_COLOR;
    self.calendar.today = nil;
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
//    self.calendar.appearance.titleDefaultColor = [UIColor blackColor];
    self.calendar.appearance.headerTitleColor =
//    self.calendar.appearance.titleFont = [UIFont systemFontOfSize:16];
    self.calendar.appearance.weekdayTextColor = self.calendar.appearance.titleDefaultColor;
    
    self.calendar.hidden = YES;
    
    // 左箭头
    FAKIonIcons *preIcon = [FAKIonIcons iosArrowLeftIconWithSize:30];
    UIImage *preImage = [preIcon imageWithSize:CGSizeMake(30, 30)];
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.prevButton setImage:preImage forState:UIControlStateNormal];
    [self.contentView addSubview:self.prevButton];
    self.prevButton.frame = CGRectMake(0, 0, 60, 34);
    
    self.prevButton.backgroundColor = [UIColor whiteColor];
    
    [self.prevButton addTarget:self
                        action:@selector(prev)
              forControlEvents:UIControlEventTouchUpInside];
    
    // 右箭头
    FAKIonIcons *nextIcon = [FAKIonIcons iosArrowRightIconWithSize:30];
    UIImage *nextImage = [nextIcon imageWithSize:CGSizeMake(30, 30)];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setImage:nextImage forState:UIControlStateNormal];
    [self.contentView addSubview:self.nextButton];
    self.nextButton.frame = CGRectMake(self.contentView.width - 60, 0, 60, 34);
    
    self.nextButton.backgroundColor = [UIColor whiteColor];
    
    [self.nextButton addTarget:self
                        action:@selector(next)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton.hidden = YES;
    self.prevButton.hidden = YES;
    
    self.viewTipLabel.hidden = YES;
    
    [self loadData];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"考勤"
                                    keyMemo:nil];
}

- (void)prev
{
    self.prevButton.hidden = YES;
    self.nextButton.hidden = NO;
    
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

- (void)next
{
    self.prevButton.hidden = NO;
    self.nextButton.hidden = YES;
    
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    
    NSString *manID = [user[@"man_id"] description] ?: @"0";
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"考勤异常查询APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    self.nextButton.hidden = self.prevButton.hidden = YES;
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription
                                   offset:CGPointMake(0, 20)];
    } else {
        NSCalendar *currCalendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dc = [currCalendar components:
                                NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:[NSDate date]];
        NSInteger year  = dc.year;
        NSInteger month = dc.month;
        
        NSString *curr = [NSString stringWithFormat:@"%d-%02d", year, month];
        
        NSInteger lastMonth = month - 1;
        NSInteger lastYear  = year;
        if ( lastMonth == 0 ) {
            lastMonth = 12;
            lastYear -= 1;
        }
        NSString *prev = [NSString stringWithFormat:@"%d-%02d", lastYear, lastMonth];
        
        NSLog(@"curr: %@, prev: %@", curr, prev);
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            self.dataSource = result[@"data"];
            
            self.calendar.hidden = NO;
            self.viewTipLabel.hidden = NO;
//            self.prevButton.hidden = NO;
            
            [self.errorAttendances removeAllObjects];
            NSInteger count1 = 0;
            NSInteger count2 = 0;
            for (id dict in self.dataSource) {
                NSString *remark = HNStringFromObject(dict[@"remark"], @"");
                if ( remark.length > 0 ) {
                    if ([remark isEqualToString:@"缺上下班卡"]) {
                        // 如果缺上下班卡，那么要分开处理异常，所以实际上是两条异常
                        [self.errorAttendances addObject:dict];
                        [self.errorAttendances addObject:dict];
                    } else {
                        [self.errorAttendances addObject:dict];
                    }
                }
                
                NSString *d9999 = HNDateFromObject(dict[@"d9999"], @"T");
                if ( [d9999 hasPrefix:curr] ) {
                    count1 ++;
                }
                
                if ( [d9999 hasPrefix:prev] ) {
                    count2 ++;
                }
            }
            
            if ( count1 > 0 && count2 > 0 ) {
                self.prevButton.hidden = NO;
            }
            
            [self showErrorAttendancesButtonIfNeeded];
            
            [self.calendar reloadData];
        } else {
            [self.contentView showHUDWithText:@"没有考勤数据" offset:CGPointZero];
        }
    }
}

- (void)showErrorAttendancesButtonIfNeeded
{
    if ( self.errorAttendances.count > 0 ) {
        NSString *title = [NSString stringWithFormat:@"异常处理(%d)", self.errorAttendances.count];
        
        __weak typeof(self) me = self;
        [self addRightItemWithTitle:title titleAttributes:@{
                                                            NSFontAttributeName: AWSystemFontWithSize(15, NO)
                                                            }
                               size:CGSizeMake(90, 40)
                        rightMargin:10
                           callback:^{
                               [me doHandle];
                           }];
    } else {
        [self addRightItemWithView:nil];
    }
}

- (void)doHandle
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttendanceFlowVC" params:@{ @"errors" : self.errorAttendances }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger year  = dc.year;
    NSInteger month = dc.month;
    
    if (month == 1) {
        month = 12;
        year -= 1;
    } else {
        month -= 1;
    }
    
    NSDateComponents *lastDC = [[NSDateComponents alloc] init];
    lastDC.year = year;
    lastDC.month = month;
    lastDC.day = 1;
    
    return [currentCalendar dateFromComponents:lastDC];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];

    return [currentCalendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:[NSDate date] options:0];
}

// 获取当月的天数
- (NSInteger)getNumberOfDaysInMonth
{
    NSCalendar * calendar = [NSCalendar currentCalendar]; // 指定日历的算法
    NSDate * currentDate = [NSDate date]; // 这个日期可以你自己给定
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit: NSCalendarUnitMonth
                                  forDate:currentDate];
    return range.length;
}

- (BOOL)checkInterivableForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if ( monthPosition != FSCalendarMonthPositionCurrent ) return NO;
    
    for (id dict in self.dataSource) {
        NSString *dateString = [[dict[@"d9999"] componentsSeparatedByString:@"T"] firstObject];
        if ([dateString isEqualToString:[self.dateFormater stringFromDate:date]]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return [self checkInterivableForDate:date atMonthPosition:monthPosition];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return [self checkInterivableForDate:date atMonthPosition:monthPosition];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did select date %@",[self.dateFormater stringFromDate:date]);
//    [self configureVisibleCells];
    for (id dict in self.dataSource) {
        NSString *dateString = [[dict[@"d9999"] componentsSeparatedByString:@"T"] firstObject];
        if ([dateString isEqualToString:[self.dateFormater stringFromDate:date]]) {
            self.viewTipLabel.hidden = YES;
            
            [self showDetail:dict];
            break;
        }
    }
}

- (void)showDetail:(id)item
{
    self.tableView.hidden = NO;
    
    NSMutableArray *temp = [NSMutableArray array];
    
    [temp addObject:@{ @"label": @"班次",
                       @"value": HNStringFromObject(item[@"k3100"], @"无")}];
    
    [temp addObject:@{ @"label": @"应上班时间",
                       @"value": [[HNDateTimeFromObject(item[@"k3103"], @"T") componentsSeparatedByString:@" "] lastObject]
                       }];
    [temp addObject:@{ @"label": @"实际上班时间",
                       @"value": [[HNDateTimeFromObject(item[@"k3104"], @"T") componentsSeparatedByString:@" "] lastObject]
                       }];
    [temp addObject:@{ @"label": @"应下班时间",
                       @"value": [[HNDateTimeFromObject(item[@"k3105"], @"T") componentsSeparatedByString:@" "] lastObject]
                       }];
    [temp addObject:@{ @"label": @"实际下班时间",
                       @"value": [[HNDateTimeFromObject(item[@"k3106"], @"T") componentsSeparatedByString:@" "] lastObject]
                       }];
    [temp addObject:@{ @"label": @"备注",
                       @"value": HNStringFromObject(item[@"remark"], @"无")}];
    self.tableDataSource = temp;
    
//    self.tableView.hidden = NO;
    [self.tableView reloadData];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    self.prevButton.hidden =
    self.nextButton.hidden = YES;
    
    if (self.dataSource.count > 0) {
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSInteger month1 = [currentCalendar component:NSCalendarUnitMonth fromDate:[NSDate date]];
        NSInteger month2 = [currentCalendar component:NSCalendarUnitMonth fromDate:calendar.currentPage];
        if ( month1 == month2 ) {
            self.prevButton.hidden = NO;
        } else {
            self.nextButton.hidden = NO;
        }
    }
    
//    NSLog(@"%@", [self.dateFormater stringFromDate:self.calendar.currentPage]);
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    
    for (id dict in self.dataSource) {
        NSString *dateString = [[dict[@"d9999"] componentsSeparatedByString:@"T"] firstObject];
        if ([dateString isEqualToString:[self.dateFormater stringFromDate:date]]) {
            return 1;
        }
    }
    
    return 0;
}

- (nullable NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    for (id dict in self.dataSource) {
        NSString *dateString = [[dict[@"d9999"] componentsSeparatedByString:@"T"] firstObject];
        if ([dateString isEqualToString:[self.dateFormater stringFromDate:date]]) {
            NSString *remark = HNStringFromObject(dict[@"remark"], @"");
            if ( remark.length > 0 ) {
                return @[MAIN_THEME_COLOR];
            }
        }
    }
    return @[self.calendar.appearance.eventDefaultColor];
}

- (nullable NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(NSDate *)date
{
    return [self calendar:calendar appearance:appearance eventDefaultColorsForDate:date];
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (FSCalendar *)calendar
{
    if ( !_calendar ) {
        _calendar = [[FSCalendar alloc] init];
        [self.contentView addSubview:_calendar];
        
        _calendar.dataSource = self;
        _calendar.delegate   = self;
        
        _calendar.backgroundColor = [UIColor whiteColor];
        
        _calendar.frame = CGRectMake(0, 0, self.contentView.width,
                                     self.contentView.width * 0.8);
        
        _calendar.center = CGPointMake(self.contentView.width / 2,
                                           self.calendar.height / 2);
    }
    return _calendar;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        _tableView.frame = self.viewTipLabel.frame;
        
        _tableView.dataSource = self;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id item = self.tableDataSource[indexPath.row];
    
    cell.textLabel.text = item[@"label"];
    cell.detailTextLabel.text = item[@"value"];
    
    return cell;
}

- (UILabel *)viewTipLabel
{
    if ( !_viewTipLabel ) {
        CGRect frame = CGRectMake(0, self.calendar.bottom + 1,
                                  self.calendar.width,
                                  self.contentView.height - 1 - self.calendar.bottom);
        _viewTipLabel = AWCreateLabel(frame,
                                      @"点击日期查看考勤详情",
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(16, NO),
                                      AWColorFromRGB(138, 138, 138));
        [self.contentView addSubview:_viewTipLabel];
        _viewTipLabel.backgroundColor = [UIColor whiteColor];
    }
    
    return _viewTipLabel;
}

@end

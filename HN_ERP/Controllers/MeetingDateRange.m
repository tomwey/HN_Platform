//
//  MeetingDateRange.m
//  HN_ERP
//
//  Created by tomwey on 7/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingDateRange.h"
#import "Defines.h"
#import "NSDate+WeekdayRange.h"

@interface MeetingDateRange ()

@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UILabel  *titleLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormater;

@end

@implementation MeetingDateRange

- (UIButton *)preBtn
{
    if ( !_preBtn) {
        FAKIonIcons *preIcon = [FAKIonIcons iosArrowLeftIconWithSize:30];
        UIImage *preImage = [preIcon imageWithSize:CGSizeMake(60, 60)];
        _preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preBtn setImage:preImage forState:UIControlStateNormal];
        [self addSubview:_preBtn];
        [_preBtn sizeToFit];
        
        [_preBtn addTarget:self
                    action:@selector(prev) forControlEvents:UIControlEventTouchUpInside];
    }
    return _preBtn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.preBtn.position = CGPointMake(15, self.height / 2 - self.preBtn.height / 2);
    
    self.nextBtn.position = CGPointMake(self.width - 15 - self.nextBtn.width,
                                        self.preBtn.top);
    
    self.titleLabel.frame = CGRectMake(self.preBtn.right,
                                       0,
                                       self.nextBtn.left - self.preBtn.right,
                                       self.height);
}

- (UIButton *)nextBtn
{
    if ( !_nextBtn) {
        FAKIonIcons *preIcon = [FAKIonIcons iosArrowRightIconWithSize:30];
        UIImage *preImage = [preIcon imageWithSize:CGSizeMake(60, 60)];
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:preImage forState:UIControlStateNormal];
        [self addSubview:_nextBtn];
        [_nextBtn sizeToFit];
        
        [_nextBtn addTarget:self
                     action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (void)prev
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comp = [NSDateComponents new];
    comp.weekOfYear = -1;
    
    self.currentDate = [calendar dateByAddingComponents:comp
                                                 toDate:self.currentDate
                                                options:0];
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (BOOL)isTheSameDay:(NSDate *)date1 forDate:(NSDate *)date2
{
    if ( !date1 || !date2 ) {
        return NO;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *d1 = [df stringFromDate:date1];
    NSString *d2 = [df stringFromDate:date2];
    
    return [d1 isEqualToString:d2];
}

- (void)next
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comp = [NSDateComponents new];
    comp.weekOfYear = 1;
    
    self.currentDate = [calendar dateByAddingComponents:comp
                                                 toDate:self.currentDate
                                                options:0];
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if ( [currentDate isEqualToDate:_currentDate] ) {
        return;
    }
    
    _currentDate = currentDate;
    
    NSLog(@"date: %@", _currentDate);
    
    [self updateDateRange];
}

- (void)updateDateRange
{
    if ( self.changeBlock ) {
        NSDate *firstDate = [self.currentDate firstDayOfWeek];
        NSDate *lastDate  = [self.currentDate lastDayOfWeek];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger week = [calendar component:NSCalendarUnitWeekOfYear fromDate:self.currentDate];

        self.changeBlock(self,week, [self.dateFormater stringFromDate:firstDate],
                         [self.dateFormater stringFromDate:lastDate]);
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger week = [calendar component:NSCalendarUnitWeekOfYear fromDate:self.currentDate];
    
    if ( self.isThisWeek ) {
        self.titleLabel.text = [NSString stringWithFormat:@"本周（第%d周）", week];
    } else if ( self.isLastWeek ) {
        // 上一周
        self.titleLabel.text = [NSString stringWithFormat:@"上周（第%d周）", week];
    } else if ( self.isNextWeek ) {
        // 下一周
        self.titleLabel.text = [NSString stringWithFormat:@"下周（第%d周）", week];
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"第%d周", week];
    }
}

- (BOOL)isThisWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger week = [calendar component:NSCalendarUnitWeekOfYear fromDate:self.currentDate];
    
    NSInteger currentWeek = [calendar component:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    
    return week == currentWeek;
}

- (BOOL)isLastWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger week = [calendar component:NSCalendarUnitWeekOfYear fromDate:self.currentDate];
    
    NSInteger currentWeek = [calendar component:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    
    return currentWeek - week == 1;
}

- (BOOL)isNextWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger week = [calendar component:NSCalendarUnitWeekOfYear fromDate:self.currentDate];
    
    NSInteger currentWeek = [calendar component:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    
    return currentWeek - week == -1;
}

- (NSDateFormatter *)dateFormater
{
    if ( !_dateFormater ) {
        _dateFormater = [[NSDateFormatter alloc] init];
        _dateFormater.dateFormat = @"yyyy-MM-dd";
    }
    return _dateFormater;
}

@end


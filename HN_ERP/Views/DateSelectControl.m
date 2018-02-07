//
//  DateSelectControl.m
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DateSelectControl.h"
#import "Defines.h"

@interface DateSelectControl ()

@property (nonatomic, strong) UIButton *currentBtn;
@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) NSDateFormatter *dateFormater;

@end

@implementation DateSelectControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        _controlMode = DateControlModeDate;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing = 10;
    CGFloat currentBtnWidth = self.width - self.preBtn.width -
        self.nextBtn.width - 2 * spacing;
    
    self.currentBtn.frame = CGRectMake(0, 0, currentBtnWidth, self.preBtn.height);
    self.currentBtn.center = CGPointMake(self.width / 2, self.height / 2);
    
    self.preBtn.center = CGPointMake(self.preBtn.width / 2,
                                     self.currentBtn.midY);
    self.nextBtn.center = CGPointMake(self.width - self.nextBtn.width / 2,
                                      self.currentBtn.midY);
}

- (UIButton *)currentBtn
{
    if ( !_currentBtn ) {
        _currentBtn = AWCreateTextButton(CGRectZero,
                                         nil,
                                         [UIColor blackColor],
                                         self,
                                         @selector(openDatePicker));
        [self addSubview:_currentBtn];
    }
    return _currentBtn;
}

- (UIButton *)preBtn
{
    if ( !_preBtn) {
        FAKIonIcons *preIcon = [FAKIonIcons iosArrowLeftIconWithSize:30];
        UIImage *preImage = [preIcon imageWithSize:CGSizeMake(40, 40)];
        _preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preBtn setImage:preImage forState:UIControlStateNormal];
        [self addSubview:_preBtn];
        [_preBtn sizeToFit];
        
        [_preBtn addTarget:self
                    action:@selector(prev) forControlEvents:UIControlEventTouchUpInside];
    }
    return _preBtn;
}

- (NSString *)currentDateString
{
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
    });
    return [df stringFromDate:self.currentDate];
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
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    if ( self.minimumDate && self.currentDate ) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
        
        NSString *d1 = [df stringFromDate:self.minimumDate];
        NSString *d2 = [df stringFromDate:self.currentDate];
        
        if ( [d1 isEqualToString:d2] ) {
            return;
        }
    }
    
    NSCalendarUnit unit = NSCalendarUnitDay;
    switch (self.controlMode) {
        case DateControlModeDate:
            unit = NSCalendarUnitDay;
            break;
        case DateControlModeYearMonth:
            unit = NSCalendarUnitMonth;
            break;
            
        default:
            break;
    }
    
    self.currentDate = [calendar dateByAddingUnit:unit value:-1
                                           toDate:self.currentDate
                                          options:0];
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
    if ( self.maximumDate && self.currentDate ) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
        
        NSString *d1 = [df stringFromDate:self.maximumDate];
        NSString *d2 = [df stringFromDate:self.currentDate];
        
        if ( [d1 isEqualToString:d2] ) {
            return;
        }
    }
    
    NSCalendarUnit unit = NSCalendarUnitDay;
    switch (self.controlMode) {
        case DateControlModeDate:
            unit = NSCalendarUnitDay;
            break;
        case DateControlModeYearMonth:
            unit = NSCalendarUnitMonth;
            break;
            
        default:
            break;
    }
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    self.currentDate = [calendar dateByAddingUnit:unit value:1
                                           toDate:self.currentDate
                                          options:0];
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if ( [currentDate isEqualToDate:_currentDate] ) {
        return;
    }
    
    _currentDate = currentDate;
    
    switch (self.controlMode) {
        case DateControlModeDate:
            self.dateFormater.dateFormat = @"yyyy-MM-dd";
            break;
        case DateControlModeYearMonth:
            self.dateFormater.dateFormat = @"yyyy-MM";
            break;
            
        default:
            break;
    }
    
    [self.currentBtn setTitle:[self.dateFormater stringFromDate:_currentDate] forState:UIControlStateNormal];
    
    self.preBtn.enabled = ![self isTheSameDay:_currentDate forDate:self.minimumDate];
    self.nextBtn.enabled = ![self isTheSameDay:_currentDate forDate:self.maximumDate];
    
    if ( self.currentDateDidChangeBlock ) {
        self.currentDateDidChangeBlock(self);
    }
}

- (void)openDatePicker
{
    if ( self.openDatePickerBlock ) {
        self.openDatePickerBlock(self);
    }
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

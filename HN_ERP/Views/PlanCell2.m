//
//  PlanCell2.m
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanCell2.h"
#import "Defines.h"

@interface PlanCell2 ()

@property (nonatomic, strong) UIImageView *calendarView;
@property (nonatomic, strong) UILabel     *doneLabel;
@property (nonatomic, strong) UILabel     *dayLabel;
@property (nonatomic, strong) UILabel     *yearAndMonthLabel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;

@end

@implementation PlanCell2

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ( [self respondsToSelector:@selector(setLayoutMargins:)] ) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.calendarView.center = CGPointMake(15 + self.calendarView.width / 2,
                                           self.height / 2);
    
    self.titleLabel.frame = CGRectMake(self.calendarView.right + 15,
                                       self.calendarView.top - 2,
                                       self.width - self.calendarView.right - 15 - 30 - 10,
                                       30);
    self.summaryLabel.frame = self.titleLabel.frame;
    self.summaryLabel.top = self.titleLabel.bottom + 2;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.titleLabel.text = data[@"plan_name"];
    
//    // 是否完成
    BOOL completed = [data[@"iscomplete"] boolValue];
    if ( completed ) {
//        self.calendarView.image = [UIImage imageNamed:@"icon_calendar_done.png"];
        self.doneLabel.text = @"已完成";
    } else {
//        self.calendarView.image = [UIImage imageNamed:@"icon_calendar_no_done.png"];
        self.doneLabel.text = @"完成日期";
    }

    self.calendarView.image = nil;
    // ●
    
//    NSString *time = data[@"enddate"];
//    time = [[[time componentsSeparatedByString:@"T"] firstObject] description];
    self.summaryLabel.text = [NSString stringWithFormat:@"%@ %@",
                              data[@"project_name"], data[@"level_name"]];
    
    self.doneLabel.hidden =
    self.dayLabel.hidden  =
    self.yearAndMonthLabel.hidden = NO;
}

- (UIImageView *)calendarView
{
    if ( !_calendarView ) {
        _calendarView = AWCreateImageView(@"icon_calendar_no_done.png");
        [self.contentView addSubview:_calendarView];
    }
    return _calendarView;
}

- (UILabel *)doneLabel
{
    if ( !_doneLabel ) {
        _doneLabel = AWCreateLabel(CGRectZero, @"完成日期",
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(8, NO),
                                   [UIColor whiteColor]);
        [self.calendarView addSubview:_doneLabel];
        _doneLabel.frame = CGRectMake(0, 0, self.calendarView.width,
                                      16);
    }
    return _doneLabel;
}

- (UILabel *)dayLabel
{
    if ( !_dayLabel ) {
        _dayLabel = AWCreateLabel(CGRectZero, nil,
                                   NSTextAlignmentCenter,
                                   self.doneLabel.font,
                                   AWColorFromRGB(58, 58, 58));
        [self.calendarView addSubview:_dayLabel];
        _dayLabel.frame = CGRectMake(3, 17, _calendarView.width, 24);
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"21日"];
        [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(20, NO) }
                        range:NSMakeRange(0, string.length - 1)];
        _dayLabel.attributedText = string;
    }
    return _dayLabel;
}

- (UILabel *)yearAndMonthLabel
{
    if ( !_yearAndMonthLabel ) {
        _yearAndMonthLabel = AWCreateLabel(CGRectZero, @"2017年3月",
                                  NSTextAlignmentCenter,
                                  self.doneLabel.font,
                                  self.dayLabel.textColor);
        [self.calendarView addSubview:_yearAndMonthLabel];
        
        _yearAndMonthLabel.frame = CGRectMake(0,
                                              self.calendarView.height - 20,
                                              self.calendarView.width, 16);
    }
    return _yearAndMonthLabel;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero, nil,
                                           NSTextAlignmentLeft,
                                           AWSystemFontWithSize(15, NO),
                                           self.dayLabel.textColor);
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)summaryLabel
{
    if ( !_summaryLabel ) {
        _summaryLabel = AWCreateLabel(CGRectZero, nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(13, NO),
                                    AWColorFromRGB(168, 168, 168));
        [self.contentView addSubview:_summaryLabel];
    }
    return _summaryLabel;
}

@end

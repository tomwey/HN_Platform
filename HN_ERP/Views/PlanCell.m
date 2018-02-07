//
//  PlanCell.m
//  HN_ERP
//
//  Created by tomwey on 2/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanCell.h"
#import "Defines.h"

@interface PlanCell ()

@property (nonatomic, strong) UIView  *contentContainer;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, assign) NSInteger state;

@end

@implementation PlanCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        if ( [self respondsToSelector:@selector(setLayoutMargins:)] ) {
//            self.layoutMargins = UIEdgeInsetsZero;
//        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentContainer.frame = self.bounds;
    self.contentContainer.top     = 10;
    self.contentContainer.height -= 10;
    
    CGFloat titleHeight = 60.0f, summaryHeight = 30.0f;
    
    CGFloat padding = self.contentContainer.height / 2.0 -
                        ( titleHeight + summaryHeight ) / 2.0;
    
    self.dateLabel.center = CGPointMake(10 + self.dateLabel.width / 2, self.contentContainer.height / 2);
    
    self.titleLabel.frame = CGRectMake(self.dateLabel.right + 10,
                                       padding,
                                       self.contentContainer.width - self.dateLabel.width - 10 - 60 - 30,
                                       titleHeight);
    
    self.summaryLabel.frame = self.titleLabel.frame;
    self.summaryLabel.height = summaryHeight;
    self.summaryLabel.top = self.contentContainer.height - summaryHeight - padding - 3;
    
    self.leftTimeLabel.center = CGPointMake(self.contentContainer.width - self.leftTimeLabel.width / 2 - 10, self.contentContainer.height / 2 - 5);
    
    self.stateLabel.center = CGPointMake(self.leftTimeLabel.midX,
                                         self.summaryLabel.midY);
    
}

- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock
{
    
    //            "area_id" = 1;
    //            begindate = "2017-04-01T00:00:00+08:00";
    //            enddate = "2017-04-30T00:00:00+08:00";
    //            iscomplete = 1;
    //            "level_id" = 3;
    //            "level_name" = "\U4e09\U7ea7";
    //            "man_id1" = 1691792;
    //            "man_id2" = NULL;
    //            "man_name1" = "\U695a\U6653\U4e1c";
    //            "man_name2" = NULL;
    //            mid = 30239;
    //            "operator_id" = 1692269;
    //            "operator_name" = "\U9648\U6625\U5229";
    //            "org_id" = 1685007;
    //            "org_name" = "\U8fd0\U8425\U7ba1\U7406\U90e8";
    //            "plan_name" = "\U4e09\U7ea7\U5236\U5ea6\U6587\U4ef6\U62a5\U6279\U901a\U8fc7";
    //            planmonth = 4;
    //            planyear = 2017;
    //            "project_id" = 2;
    //            "project_name" = "\U96c6\U56e2\U7ba1\U7406\U7c7b";
    //            realenddate = "2017-03-10T00:00:00+08:00";
    //            target = "4-30";
    
    //    self.state = [data[@"state"] integerValue];
    BOOL isCompleted = [data[@"isover"] boolValue];
    
    if ( isCompleted ) {
        self.state = 0;
    } else {
        // 临时方案
        self.state = 4;
    }
    
    // 设置计划完成日期
    NSString *endDateStr = [[data[@"planoverdate"] componentsSeparatedByString:@"T"] firstObject];
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    df1.dateFormat = @"yyyy-MM-dd";
    NSDate *eDate = [df1 dateFromString:endDateStr];
    
    NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
    df2.dateFormat = @"d日\nyyyy年M月";
    NSString *planEndDateStr = [df2 stringFromDate:eDate];
    
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:planEndDateStr];
    NSRange range = [dateString.string rangeOfString:@"日"];
    [dateString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(20, NO) } range:NSMakeRange(0, range.location)];
    self.dateLabel.attributedText = dateString;
    
    // 设置计划名称
    self.titleLabel.text = data[@"itemname"];
    
    // ● 设置摘要
    self.summaryLabel.text = [NSString stringWithFormat:@"%@ %@",
                              data[@"project_name"], data[@"plangrade"]];
    
    // 设置倒计时
    BOOL hasCQ = NO; // 是否超期完成
    NSInteger days = 0; // 计算天数
    NSString *suffixDesc = nil;
    if ( isCompleted ) {
        // 已完成
        
        // 获取实际完成的日期
        NSString *realDateStr = [[data[@"actualoverdate"] componentsSeparatedByString:@"T"] firstObject];
        if ( [realDateStr compare:endDateStr options:NSNumericSearch] == NSOrderedDescending ) {
            hasCQ = YES; // 已经超期完成了
            // 如果超期了需要显示超期的天数
            
            
            suffixDesc = @"超期";
        } else {
            // 没超期
            hasCQ = NO;
            suffixDesc = @"提前";
        }
        
        NSDate *realDate = [df1 dateFromString:realDateStr];
        
        days = [self calcDaysBetween:eDate and:realDate];
    } else {
        // 未完成
        NSDate *now = [NSDate date];
        NSString *nowStr = [df1 stringFromDate:now];
        now = [df1 dateFromString:nowStr];
        
        days = [self calcDaysBetween:now and:eDate];
        suffixDesc = [nowStr compare:endDateStr options:NSNumericSearch] == NSOrderedDescending ? @"超期" : @"还剩";
    }
    
    NSInteger adjustDays = days;
    
    if ( days == 0 && !isCompleted ) {
        suffixDesc = @"不到";
        adjustDays = 1;
    }
    
//    NSString *suffixDesc = self.state == 3 ? @"超期" : @"还剩";
    NSMutableAttributedString *leftTimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d天\n%@",adjustDays, suffixDesc]];
    range = [leftTimeString.string rangeOfString:@"天"];
    [leftTimeString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(20, NO) } range:NSMakeRange(0, range.location)];
    [leftTimeString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(8, NO) } range:NSMakeRange(range.location, 1)];
    self.leftTimeLabel.attributedText = leftTimeString;
    
    if ( !isCompleted && [suffixDesc isEqualToString:@"超期"] ) {
        self.state = 3;
    }
    
    [self setStateLabelContent];
    
    if ( days == 0 && isCompleted ) {
//            self.stateLabel.hidden = YES;
        self.leftTimeLabel.text = @"按期\n完成";
        self.leftTimeLabel.textColor = AWColorFromRGB(58, 58, 58);//AWColorFromHex(@"#54ae3b");
    } else {
        self.stateLabel.hidden = NO;
        self.leftTimeLabel.textColor = AWColorFromRGB(58, 58, 58);
    }
    
//    if ( self.state == 0 && hasCQ == NO ) {
////        self.leftTimeLabel.hidden = YES;
//        self.stateLabel.hidden = YES;
//        self.leftTimeLabel.text = @"已完成";
//        self.leftTimeLabel.textColor = AWColorFromHex(@"#54ae3b");
//    } else {
//        self.leftTimeLabel.textColor = AWColorFromRGB(58, 58, 58);
//        self.stateLabel.hidden = NO;
////        self.leftTimeLabel.hidden = NO;
//    }
    
    NSString *color = [[[self class] StateInfos] objectAtIndex:self.state][@"color"];
    self.leftTimeLabel.layer.borderColor = AWColorFromHex(color).CGColor;
}

- (NSInteger)calcDaysBetween:(NSDate *)date1 and:(NSDate *)date2
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dc = [cal components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0];
    return abs(dc.day);
}

- (void)setStateLabelContent
{
    NSArray *stateInfos = [[self class] StateInfos];
    if ( self.state < stateInfos.count ) {
        id stateInfo = stateInfos[self.state];
        
        self.stateLabel.text = stateInfo[@"label"];
        self.stateLabel.backgroundColor = AWColorFromHex(stateInfo[@"color"]);
        
        [self.stateLabel sizeToFit];
        
        self.stateLabel.width += 10;
        self.stateLabel.height += 6;
    }
}

+ (NSArray *)StateInfos
{
    static NSArray *stateInfos;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stateInfos = [@[@{
                           @"label": @"已完成",
                           @"color": @"#54ae3b",
                           },@{
                           @"label": @"确认中",
                           @"color": @"#E8A02A",
                           },@{
                           @"label": @"调整中",
                           @"color": @"#53B2DA",
                           },@{
                           @"label": @"已超期",
                           @"color": @"#C93E3B",
                           },@{
                            @"label": @"进行中",
                            @"color": @"#E8A02A",
                           }] copy];
    });
    return stateInfos;
}

- (UIView *)contentContainer
{
    if ( !_contentContainer ) {
        _contentContainer = [[UIView alloc] init];
        [self.contentView addSubview:_contentContainer];
        _contentContainer.backgroundColor = [UIColor whiteColor];
    }
    return _contentContainer;
}

- (UILabel *)dateLabel
{
    if ( !_dateLabel ) {
        _dateLabel = AWCreateLabel(CGRectMake(0, 0, 60, 60),
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(10, NO),
                                   AWColorFromRGB(58, 58, 58));
        [self.contentContainer addSubview:_dateLabel];
        _dateLabel.numberOfLines = 2;
    }
    return _dateLabel;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    [UIFont systemFontOfSize:15],
                                    self.dateLabel.textColor);
        [self.contentContainer addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)summaryLabel
{
    if ( !_summaryLabel ) {
        _summaryLabel = AWCreateLabel(CGRectZero,
                                      nil,
                                      NSTextAlignmentLeft,
                                      [UIFont systemFontOfSize:13],
                                      AWColorFromRGB(137, 137, 137));
        [self.contentContainer addSubview:_summaryLabel];
    }
    return _summaryLabel;
}

- (UILabel *)leftTimeLabel
{
    if ( !_leftTimeLabel ) {
        _leftTimeLabel = AWCreateLabel(CGRectMake(0, 0, 60, 60),
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(10, NO),
                                       self.dateLabel.textColor);
        [self.contentContainer addSubview:_leftTimeLabel];
        _leftTimeLabel.numberOfLines = 2;
        _leftTimeLabel.cornerRadius = _leftTimeLabel.height / 2;
        _leftTimeLabel.layer.borderColor = AWColorFromRGB(239, 239, 239).CGColor;
        _leftTimeLabel.layer.borderWidth = 0.5;
    }
    return _leftTimeLabel;
}

- (UILabel *)stateLabel
{
    if ( !_stateLabel ) {
        _stateLabel = AWCreateLabel(CGRectMake(0, 0, 42, 18),
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(8, NO),
                                    [UIColor whiteColor]);
        [self.contentContainer addSubview:_stateLabel];
        _stateLabel.cornerRadius = 2;
    }
    return _stateLabel;
}

@end

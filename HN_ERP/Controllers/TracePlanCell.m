//
//  TracePlanCell.m
//  HN_ERP
//
//  Created by tomwey on 8/2/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "TracePlanCell.h"
#import "Defines.h"

@interface TracePlanCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *leftTimeLabel;

@end

@implementation TracePlanCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    NSString *endDateStr = HNDateFromObject(data[@"plan_finish_date"], @"T");
    NSRange range;
    if ([endDateStr isEqualToString:@"无"]) {
        self.dateLabel.text = @"--";
    } else {
    
    //[[data[@"plan_finish_date"] componentsSeparatedByString:@"T"] firstObject];
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        df1.dateFormat = @"yyyy-MM-dd";
        NSDate *eDate = [df1 dateFromString:endDateStr];
        
        NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
        df2.dateFormat = @"d日\nyyyy年M月";
        NSString *planEndDateStr = [df2 stringFromDate:eDate];
        
        NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:planEndDateStr];
        range = [dateString.string rangeOfString:@"日"];
        [dateString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(20, NO) } range:NSMakeRange(0, range.location)];
        self.dateLabel.attributedText = dateString;
    }
    
    // 设置计划名称
    self.titleLabel.text = data[@"process_name"];
    
    // ● 设置摘要
    self.summaryLabel.text = [NSString stringWithFormat:@"责任人：%@",
                              HNStringFromObject(data[@"manage_name"], @"--")];
    
    // 设置类型
    self.typeLabel.text = HNStringFromObject(data[@"process_type"], @"");
    if (self.typeLabel.text.length == 0) {
        self.typeLabel.hidden = YES;
    } else {
        self.typeLabel.hidden = NO;
    }
    
    // 计算还剩的天数
    if ( [data[@"is_finish"] boolValue] ) {
        self.leftTimeLabel.text = @"已完成";
        self.leftTimeLabel.layer.borderColor = AWColorFromHex(@"#54ae3b").CGColor;
        NSString *finishDateStr = HNDateFromObject(data[@"finish_date"], @"T");
        NSString *planDateStr = HNDateFromObject(data[@"plan_finish_date"], @"T");
        if ([finishDateStr compare:planDateStr options:NSNumericSearch] == NSOrderedDescending) {
            self.leftTimeLabel.text = @"超期完成";
        }
    } else {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
        
        NSString *planDateStr = HNDateFromObject(data[@"plan_finish_date"], @"T");
        NSDate *planDate = [df dateFromString:planDateStr];
        
        
        NSDate *now = [NSDate date];
        
        NSString *nowStr = [df stringFromDate:now];
        now = [df dateFromString:nowStr];
        
        NSString *finishDateStr = HNDateFromObject(data[@"finish_date"], @"T");
        NSDate *finishDate = [df dateFromString:finishDateStr];
        
        NSInteger days = 0;
        NSString *suffixDesc = nil;
        
        if ( finishDate ) {
            // 超期
            days = [self calcDaysBetween:now and:finishDate];
            suffixDesc = @"超期";
        } else {
            // 未完成
            days = [self calcDaysBetween:now and:planDate];
            suffixDesc = @"还剩";
        }
        
//        NSString *suffixDesc = [nowStr compare:planDateStr options:NSNumericSearch] == NSOrderedDescending ? @"超期" : @"还剩";
        
        if ( days == 0 && [suffixDesc isEqualToString:@"还剩"] ) {
            days = 1;
            suffixDesc = @"不到";
        }
        
        NSMutableAttributedString *leftTimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d天\n%@",days, suffixDesc]];
        range = [leftTimeString.string rangeOfString:@"天"];
        [leftTimeString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(20, NO) } range:NSMakeRange(0, range.location)];
        [leftTimeString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(8, NO) } range:NSMakeRange(range.location, 1)];
        self.leftTimeLabel.attributedText = leftTimeString;
        
        if ([suffixDesc isEqualToString:@"超期"]) {
            self.leftTimeLabel.layer.borderColor = AWColorFromHex(@"#C93E3B").CGColor;
        } else {
            self.leftTimeLabel.layer.borderColor = AWColorFromHex(@"#E8A02A").CGColor;
        }
    }
}

- (NSInteger)calcDaysBetween:(NSDate *)date1 and:(NSDate *)date2
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dc = [cal components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0];
    return abs(dc.day);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dateLabel.center = CGPointMake(10 + self.dateLabel.width / 2, self.height / 2);
    
    self.typeLabel.width = 66;
    self.typeLabel.position = CGPointMake(0, 15);
    
    self.titleLabel.frame = CGRectMake(self.dateLabel.right + 10,
                                       self.typeLabel.top - 10,
                                       self.width - self.dateLabel.width - 15 - 60 - 30,
                                       60);
    
    self.summaryLabel.frame  = self.titleLabel.frame;
    self.summaryLabel.height = 30;
    self.summaryLabel.width  = self.titleLabel.width;
    self.summaryLabel.top = self.titleLabel.bottom + 3;
    
//    self.typeLabel.center = CGPointMake(self.titleLabel.right - self.typeLabel.width / 2 - 5,
//                                        self.summaryLabel.midY);
    
    self.dateLabel.top = self.height - 10 - self.dateLabel.height;
    
    self.leftTimeLabel.center = CGPointMake(self.width - 13 - self.leftTimeLabel.width / 2,
                                            self.height / 2.0);
}

- (UILabel *)dateLabel
{
    if ( !_dateLabel ) {
        _dateLabel = AWCreateLabel(CGRectMake(0, 0, 60, 60),
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(10, NO),
                                   AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_dateLabel];
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
        [self.contentView addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
        
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UILabel *)typeLabel
{
    if ( !_typeLabel ) {
        _typeLabel = AWCreateLabel(CGRectMake(0, 0, 50, 30),
                                      nil,
                                      NSTextAlignmentCenter,
                                      [UIFont systemFontOfSize:14],
                                      AWColorFromRGB(158, 158, 158));
        [self.contentView addSubview:_typeLabel];
        
        _typeLabel.backgroundColor = AWColorFromRGB(247, 247, 247);
    }
    return _typeLabel;
}

- (UILabel *)summaryLabel
{
    if ( !_summaryLabel ) {
        _summaryLabel = AWCreateLabel(CGRectZero,
                                      nil,
                                      NSTextAlignmentLeft,
                                      [UIFont systemFontOfSize:13],
                                      AWColorFromRGB(137, 137, 137));
        [self.contentView addSubview:_summaryLabel];
        
        _summaryLabel.adjustsFontSizeToFitWidth = YES;
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
        [self.contentView addSubview:_leftTimeLabel];
        _leftTimeLabel.numberOfLines = 2;
        _leftTimeLabel.cornerRadius = _leftTimeLabel.height / 2;
        _leftTimeLabel.layer.borderColor = AWColorFromRGB(239, 239, 239).CGColor;
        _leftTimeLabel.layer.borderWidth = 0.5;
    }
    return _leftTimeLabel;
}


@end

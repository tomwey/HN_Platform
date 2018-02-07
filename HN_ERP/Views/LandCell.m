//
//  LandCell.m
//  HN_ERP
//
//  Created by tomwey on 4/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandCell.h"
#import "Defines.h"

@interface LandCell ()

// 地块名字
@property (nonatomic, strong) UILabel *nameLabel;

// 地块位置
@property (nonatomic, strong) UILabel *locationLabel;

// 地块用途
@property (nonatomic, strong) UILabel *useLabel;

// 地块出让方式
@property (nonatomic, strong) UILabel *sellTypeLabel;

// 地块出让日期
@property (nonatomic, strong) UILabel *sellDateLabel;

// 地块出让单价
@property (nonatomic, strong) UILabel *sellPriceLabel;

// 地块总价
@property (nonatomic, strong) UILabel *totalPriceLabel;

// 地块总面积
@property (nonatomic, strong) UILabel *totalAreaSizeLabel;

// 计算天数
@property (nonatomic, strong) UILabel *leftDaysLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, copy) NSString *state;

@end

@implementation LandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data
       selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.nameLabel.text = [NSString stringWithFormat:@"[%@-%@] %@",
                           data[@"city"], data[@"subarea"], data[@"address"]];//[data[@"address"] description];
    
//    self.locationLabel.text = [NSString stringWithFormat:@"%@-%@",
//                               data[@"city"], data[@"subarea"]];
    self.useLabel.text = [data[@"usenature"] description];
    NSInteger len = 10;
    if ( self.useLabel.text.length > len ) {
        NSString *str = [self.useLabel.text substringToIndex:len];
        self.useLabel.text = [NSString stringWithFormat:@"%@...", str];
    }
    self.sellTypeLabel.text = [data[@"gettype"] description];
    
    NSString *dealPrice = [data[@"deal_roomfaceprice"] description];
    float price;
    NSString *leftTip;
    
    if ([self.sellTypeLabel.text isEqualToString:@"协议"]) {
        price = [data[@"proprice_roomfaceprice"] floatValue];
    } else {
        if ( dealPrice.length == 0 || [dealPrice isEqualToString:@"NULL"] ) {
            // 未成交，显示起拍价
            price = [data[@"startprice_roomface"] floatValue];
            leftTip = @"还剩";
        } else {
            // 已成交，显示成交价
            price = [data[@"deal_roomfaceprice"] floatValue];
            leftTip = @"已成交";
        }
    }
    
    NSString *priceString = [NSString stringWithFormat:@"%.2f元/平", price];
    self.sellPriceLabel.textColor = AWColorFromRGB(137, 137, 137);
    self.sellPriceLabel.text = priceString;
    
    // 面积
    self.totalAreaSizeLabel.text = [NSString stringWithFormat:@"%.2f亩", [data[@"usearea_mu"] floatValue]];
    // 总价
    NSString *suffix = nil;
    id totalPrice = nil;
    
    NSString *getType = [data[@"gettype"] description];
    if ( [getType isEqualToString:@"协议"] ) {
        suffix = @"出让";
        totalPrice = data[@"proprice_totallandprice"];
    } else {
        if ( dealPrice.length == 0 || [dealPrice isEqualToString:@"NULL"] ) {
            suffix = @"起拍";
            totalPrice = data[@"startprice_totalland"];
        } else {
            suffix = @"成交";
            totalPrice = data[@"deal_totallandprice"];
        }
    }
    NSString *totalPriceString = nil;
    
    NSString *sellTime = HNDateFromObject(data[@"selltime"], @"T");
    if ([sellTime isEqualToString:@"无"]) {
        totalPriceString = [NSString stringWithFormat:@"%.2f万 %@", [totalPrice floatValue], suffix];
    } else {
        totalPriceString = [NSString stringWithFormat:@"%.2f万 %@ %@", [totalPrice floatValue], HNDateFromObject(data[@"selltime"], @"T"), suffix];
    }
    
    NSMutableAttributedString *totalAttrString = [[NSMutableAttributedString alloc] initWithString:totalPriceString];
    
    NSRange range = [totalPriceString rangeOfString:@"万"];
    
    if ( range.location != NSNotFound ) {
        [totalAttrString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(18, NO), NSForegroundColorAttributeName : MAIN_THEME_COLOR }
                                 range:NSMakeRange(0, range.location + 1)];
    }
    
    self.totalPriceLabel.attributedText = totalAttrString;
    // 出让时间
    
//    self.sellDateLabel.text = [NSString stringWithFormat:@"%@ %@",
//                               data[@"selltime"], suffix];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSDate *startDate = [NSDate date];
    NSString *now = [df stringFromDate:startDate];
    
    startDate = [df dateFromString:now];
    NSDate *endDate = [df dateFromString:HNDateFromObject(data[@"selltime"], @"T")];
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dc = [calendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    
//    NSLog(@"days: %d", dc.day);
    if ( !endDate ) {
        self.leftDaysLabel.text = @"协议\n用地";
    } else {
        if ( [leftTip isEqualToString:@"还剩"] && dc.day == 0 ) {
            self.leftDaysLabel.text = @"即将\n开始";
        } else {
            if ( [leftTip isEqualToString:@"还剩"] && dc.day < 0 ) {
                leftTip = @"已过期";
            }
            
            NSString *leftDays = [NSString stringWithFormat:@"%d天\n%@",
                                  abs([dc day]), leftTip];
            NSRange range = [leftDays rangeOfString:@"天"];
            NSMutableAttributedString *daysString = [[NSMutableAttributedString alloc] initWithString:leftDays];
            [daysString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(18, NO),
                                         //NSForegroundColorAttributeName: MAIN_THEME_COLOR
                                         } range:NSMakeRange(0, range.location)];
            [daysString addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(10, NO) } range:NSMakeRange(range.location, 1)];
            
            self.leftDaysLabel.attributedText = daysString;
        }
    }
    
    if ([data[@"need_show_state"] boolValue]) {
        self.stateLabel.hidden = NO;
        
        NSString *state = HNStringFromObject(data[@"sprojectapproval"], @"");
        
        self.state = state;
        
        if ( state.length > 0 ) {
            [self updateStateContent:state];
        } else {
            self.stateLabel.hidden = YES;
        }
        
    } else {
        self.stateLabel.hidden = YES;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self updateStateContent:self.state];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self updateStateContent:self.state];
}

- (void)updateStateContent:(NSString *)state
{
    if (!state) return;
    
//    self.stateLabel.text = state;
    self.stateLabel.hidden = NO;
    
    if ( [state isEqualToString:@"待立项"] ) {
        self.stateLabel.text = @"待立项";
        self.stateLabel.backgroundColor = AWColorFromRGB(100, 100, 100);
    } else if ( [state isEqualToString:@"立项"] ) {
        self.stateLabel.text = @"立项";
        self.stateLabel.backgroundColor = AWColorFromHex(@"#E8A02A");
    } else if ( [state isEqualToString:@"立项后放弃"] ) {
        self.stateLabel.text = @"放弃";
        self.stateLabel.backgroundColor = AWColorFromRGB(171, 22, 34);
    } else if ( [state isEqualToString:@"拿地"] ) {
        self.stateLabel.text = @"已成交";
        self.stateLabel.backgroundColor = AWColorFromHex(@"#54ae3b");
    } else  {
        self.stateLabel.hidden = YES;
    }
    
    if ( self.stateLabel.hidden == NO ) {
        [self.stateLabel sizeToFit];
        
        self.stateLabel.width += 6;
        self.stateLabel.height += 4;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat dateAreaWidth = 80;//self.width * 0.382;
    CGFloat padding       = 15;
    self.nameLabel.frame = CGRectMake(padding, 6, self.width - dateAreaWidth - padding * 2, 50);
    
//    self.locationLabel.frame = self.nameLabel.frame;
//    self.locationLabel.top = self.nameLabel.bottom - 5;
    
    // 设置地块用途显示大小
    [self.useLabel sizeToFit];
    
    self.useLabel.width += 10;
    self.useLabel.height += 6;
    
    self.useLabel.position = CGPointMake(self.nameLabel.left, self.nameLabel.bottom + 5);
    
    // 设置地块出让方式显示大小
    [self.sellTypeLabel sizeToFit];
    
    self.sellTypeLabel.width += 10;
    self.sellTypeLabel.height += 6;
    
    self.sellTypeLabel.position = CGPointMake(self.useLabel.right + 5,
                                              self.useLabel.top);
    
    [self.totalPriceLabel sizeToFit];
    
    [self.sellPriceLabel sizeToFit];
    self.sellPriceLabel.center = CGPointMake(self.nameLabel.left + self.sellPriceLabel.width / 2, self.useLabel.bottom + 15);
    
    self.totalPriceLabel.position = CGPointMake(self.nameLabel.left,
                                                self.sellPriceLabel.bottom + 8);
    
    [self.totalAreaSizeLabel sizeToFit];
    
    self.totalAreaSizeLabel.center = CGPointMake(self.sellPriceLabel.right + 5 + self.totalAreaSizeLabel.width / 2, self.sellPriceLabel.midY);
    
    self.sellDateLabel.frame = CGRectMake(0, 0, dateAreaWidth, 20);
    self.sellDateLabel.center = CGPointMake(self.width - 15 - self.sellDateLabel.width / 2, self.totalPriceLabel.midY);
    
    self.leftDaysLabel.frame = CGRectMake(0, 0, dateAreaWidth, dateAreaWidth);
    [self.leftDaysLabel sizeToFit];
//    self.leftDaysLabel.center = CGPointMake(self.sellDateLabel.midX,
//                                            self.nameLabel.top + self.leftDaysLabel.height / 2);
    self.leftDaysLabel.center = CGPointMake(self.width - 8 - dateAreaWidth / 2,
                                            self.height / 2);
    
    self.stateLabel.center = CGPointMake(self.leftDaysLabel.midX,
                                         self.totalPriceLabel.bottom - self.stateLabel.height / 2 - 3);
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero, nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(15, NO),
                                   [UIColor blackColor]);
        [self.contentView addSubview:_nameLabel];
        _nameLabel.numberOfLines = 2;
    }
    return _nameLabel;
}

- (UILabel *)stateLabel
{
    if ( !_stateLabel ) {
        _stateLabel = AWCreateLabel(CGRectMake(0, 0, 42, 18),
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(9, NO),
                                    [UIColor whiteColor]);
        [self.contentView addSubview:_stateLabel];
        _stateLabel.cornerRadius = 2;
    }
    return _stateLabel;
}

- (UILabel *)locationLabel
{
    if ( !_locationLabel ) {
        _locationLabel = AWCreateLabel(CGRectZero, nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(13, NO),
                                   AWColorFromRGB(201, 201, 201));
        [self.contentView addSubview:_locationLabel];
    }
    return _locationLabel;
}

- (UILabel *)useLabel
{
    if ( !_useLabel ) {
        _useLabel = AWCreateLabel(CGRectZero, nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromHex(@"#E8A02A"));
        [self.contentView addSubview:_useLabel];
        
        _useLabel.layer.cornerRadius = 3;
        _useLabel.layer.borderWidth = 0.5;
        _useLabel.layer.borderColor = _useLabel.textColor.CGColor;
        
        _useLabel.clipsToBounds = YES;
    }
    return _useLabel;
}

- (UILabel *)sellTypeLabel
{
    if ( !_sellTypeLabel ) {
        _sellTypeLabel = AWCreateLabel(CGRectZero, nil,
                                  NSTextAlignmentCenter,
                                  AWSystemFontWithSize(12, NO),
                                  AWColorFromHex(@"#53B2DA"));
        [self.contentView addSubview:_sellTypeLabel];
        
        _sellTypeLabel.layer.cornerRadius = self.useLabel.layer.cornerRadius;
        _sellTypeLabel.layer.borderWidth  = self.useLabel.layer.borderWidth;
        _sellTypeLabel.layer.borderColor  = _sellTypeLabel.textColor.CGColor;
        
        _sellTypeLabel.clipsToBounds = YES;
    }
    return _sellTypeLabel;
}

- (UILabel *)sellPriceLabel
{
    if ( !_sellPriceLabel ) {
        _sellPriceLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(12, NO),
                                        self.totalPriceLabel.textColor);
        [self.contentView addSubview:_sellPriceLabel];
        
//        _sellPriceLabel.numberOfLines = 2;
    }
    
    return _sellPriceLabel;
}

- (UILabel *)totalPriceLabel
{
    if ( !_totalPriceLabel ) {
        _totalPriceLabel = AWCreateLabel(CGRectZero, nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromRGB(137, 137, 137));
        [self.contentView addSubview:_totalPriceLabel];
        _totalPriceLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _totalPriceLabel;
}

- (UILabel *)totalAreaSizeLabel
{
    if ( !_totalAreaSizeLabel ) {
        _totalAreaSizeLabel = AWCreateLabel(CGRectZero, nil,
                                         NSTextAlignmentLeft,
                                         self.sellPriceLabel.font,
                                        self.totalPriceLabel.textColor);
        [self.contentView addSubview:_totalAreaSizeLabel];
        _totalAreaSizeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _totalAreaSizeLabel;
}

- (UILabel *)sellDateLabel
{
    if ( !_sellDateLabel ) {
        _sellDateLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromRGB(137, 137, 137));
        [self.contentView addSubview:_sellDateLabel];
    }
    return _sellDateLabel;
}

- (UILabel *)leftDaysLabel
{
    if ( !_leftDaysLabel ) {
        _leftDaysLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       self.nameLabel.textColor);
        [self.contentView addSubview:_leftDaysLabel];
        _leftDaysLabel.numberOfLines = 2;
    }
    return _leftDaysLabel;
}

@end

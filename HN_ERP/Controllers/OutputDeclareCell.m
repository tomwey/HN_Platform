//
//  OutputDeclareCell.m
//  HN_ERP
//
//  Created by tomwey on 25/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "OutputDeclareCell.h"
#import "Defines.h"

@interface OutputDeclareCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *moneyTypeLabel;

@property (nonatomic, strong) UILabel *outMoneyLabel;
@property (nonatomic, strong) UILabel *payMoneyLabel;

@end

@implementation OutputDeclareCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data
{
    self.nameLabel.text = data[@"nodename"];
    
    AWLabelFormatShow(self.moneyTypeLabel, @"款项类型",
                      data[@"moneytypename"],
                      @"",
                      AWCustomFont(@"PingFang SC", 16),
                      MAIN_THEME_COLOR,
                      NO);
    
    AWLabelFormatShow(self.outMoneyLabel, @"产值金额",
                      [HNFormatMoney(data[@"outamount"], @"万") stringByReplacingOccurrencesOfString:@"万" withString:@""],
                      @"万",
                      AWCustomFont(@"PingFang SC", 18),
                      AWColorFromRGB(74, 144, 226),
                      NO);
    
    AWLabelFormatShow(self.payMoneyLabel, @"应付金额",
                      [HNFormatMoney(data[@"nodeamount"], @"万") stringByReplacingOccurrencesOfString:@"万" withString:@""],
                      @"万",
                      AWCustomFont(@"PingFang SC", 18),
                      AWColorFromRGB(110, 110, 110),
                      NO);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(15, 5, self.width - 30, 40);
    
    CGFloat width = (self.nameLabel.width - 10) / 3.0;
    
    self.moneyTypeLabel.frame = CGRectMake(self.nameLabel.left,
                                           self.nameLabel.bottom,
                                           width,
                                           40);
    
    self.outMoneyLabel.frame = CGRectMake(self.moneyTypeLabel.right + 5,
                                          self.moneyTypeLabel.top,
                                          width, 40);
    
    self.payMoneyLabel.frame = CGRectMake(self.outMoneyLabel.right + 5,
                                          self.moneyTypeLabel.top,
                                          width, 40);
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(74, 74, 74));
        [self.contentView addSubview:_nameLabel];
        _nameLabel.numberOfLines = 2;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _nameLabel;
}

- (UILabel *)moneyTypeLabel
{
    if ( !_moneyTypeLabel ) {
        _moneyTypeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_moneyTypeLabel];
        _moneyTypeLabel.numberOfLines = 2;
        _moneyTypeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _moneyTypeLabel;
}

- (UILabel *)outMoneyLabel
{
    if ( !_outMoneyLabel ) {
        _outMoneyLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(12, NO),
                                        AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_outMoneyLabel];
        _outMoneyLabel.numberOfLines = 2;
        _outMoneyLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _outMoneyLabel;
}

- (UILabel *)payMoneyLabel
{
    if ( !_payMoneyLabel ) {
        _payMoneyLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentRight,
                                        AWSystemFontWithSize(12, NO),
                                        AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_payMoneyLabel];
        _payMoneyLabel.numberOfLines = 2;
        _payMoneyLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _payMoneyLabel;
}

@end

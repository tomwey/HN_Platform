//
//  LandPayCell.m
//  HN_ERP
//
//  Created by tomwey on 6/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandPayCell.h"
#import "Defines.h"

@interface LandPayCell ()

// 款项名称
@property (nonatomic, strong) UILabel *titleLabel;

// 起总价分批模拟
@property (nonatomic, strong) UILabel *subTitleLabel1;
@property (nonatomic, strong) UILabel *moneyLabel1;
@property (nonatomic, strong) UILabel *rateLabel1;

// 预估总价分批模拟
@property (nonatomic, strong) UILabel *subTitleLabel2;
@property (nonatomic, strong) UILabel *moneyLabel2;
@property (nonatomic, strong) UILabel *rateLabel2;

// 付款时间
@property (nonatomic, strong) UILabel *payTimeLabel;

// 备注
@property (nonatomic, strong) UILabel *memoLabel;

@end
@implementation LandPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.titleLabel.text = data[@"payname"];
    
    self.subTitleLabel1.text = @"起总价分批模拟";
    
    self.moneyLabel1.text =
    [NSString stringWithFormat:@"金额：%@万\n比例：%@%%",
                                HNStringFromObject(data[@"paymoney1"], @"--"),
                                HNStringFromObject(data[@"payrate1"], @"--")];
    
    self.subTitleLabel2.text = @"预估总价分批模拟";
    
    self.moneyLabel2.text =
    [NSString stringWithFormat:@"金额：%@万\n比例：%@%%",
                                HNStringFromObject(data[@"paymoney2"], @"--"),
                                HNStringFromObject(data[@"payrate2"], @"--")];
    
    self.payTimeLabel.text = [NSString stringWithFormat:@"付款时间：%@",
//                              HNStringFromObject(data[@"paydate"], @"--")
                              HNDateFromObject(data[@"paydate"], @"T")];
    
    self.memoLabel.text = [NSString stringWithFormat:@"备注：%@",
                           HNStringFromObject(data[@"memodesc"], @"无")];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(15, 10, self.width - 30, 30);
    
    self.subTitleLabel1.frame = CGRectMake(self.titleLabel.left,
                                           self.titleLabel.bottom,
                                           self.titleLabel.width / 2,
                                           30);
    
    self.subTitleLabel2.frame = self.subTitleLabel1.frame;
    
    self.subTitleLabel2.left = self.subTitleLabel1.right;
    
    self.moneyLabel1.frame = self.subTitleLabel1.frame;
    self.moneyLabel1.height = 50;
    self.moneyLabel1.top = self.subTitleLabel1.bottom - 6;
    
    self.moneyLabel2.frame = self.moneyLabel1.frame;
    self.moneyLabel2.left  = self.moneyLabel1.right;
    
    self.payTimeLabel.frame = self.titleLabel.frame;
    self.payTimeLabel.top   = self.moneyLabel1.bottom;
    
    NSString *string = self.memoLabel.text;
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(self.titleLabel.width, 1000)
                                       options:NSStringDrawingUsesLineFragmentOrigin attributes:nil
                                       context:NULL].size;
    self.memoLabel.frame = CGRectMake(self.titleLabel.left,
                                      self.payTimeLabel.bottom + 5,
                                      size.width,
                                      size.height);
    
    self.memoLabel.width = self.titleLabel.width;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(18, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel1
{
    if ( !_subTitleLabel1 ) {
        _subTitleLabel1 = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_subTitleLabel1];
        
//        _subTitleLabel1.numberOfLines = 4;
    }
    return _subTitleLabel1;
}

- (UILabel *)moneyLabel1
{
    if (!_moneyLabel1) {
        _moneyLabel1 = AWCreateLabel(CGRectZero,
                                     nil,
                                     NSTextAlignmentLeft,
                                     AWSystemFontWithSize(14, NO),
                                     AWColorFromRGB(128, 128, 128));
        [self.contentView addSubview:_moneyLabel1];
        
        _moneyLabel1.numberOfLines = 2;
    }
    return _moneyLabel1;
}

- (UILabel *)moneyLabel2
{
    if (!_moneyLabel2) {
        _moneyLabel2 = AWCreateLabel(CGRectZero,
                                     nil,
                                     NSTextAlignmentLeft,
                                     self.moneyLabel1.font,
                                     self.moneyLabel1.textColor);
        [self.contentView addSubview:_moneyLabel2];
        
        _moneyLabel2.numberOfLines = 2;
    }
    return _moneyLabel2;
}

- (UILabel *)subTitleLabel2
{
    if ( !_subTitleLabel2 ) {
        _subTitleLabel2 = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(16, NO),
                                        AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_subTitleLabel2];
        
//        _subTitleLabel2.numberOfLines = 4;
    }
    return _subTitleLabel2;
}

- (UILabel *)payTimeLabel
{
    if ( !_payTimeLabel ) {
        _payTimeLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_payTimeLabel];
    }
    return _payTimeLabel;
}

- (UILabel *)memoLabel
{
    if ( !_memoLabel ) {
        _memoLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_memoLabel];
        
        _memoLabel.numberOfLines = 0;
    }
    return _memoLabel;
}

@end

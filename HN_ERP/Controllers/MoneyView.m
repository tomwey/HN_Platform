//
//  MoneyView.m
//  HN_ERP
//
//  Created by tomwey on 19/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "MoneyView.h"
#import "Defines.h"

@interface MoneyView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation MoneyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        _layoutType = LayoutTypeMoenyBottom;
        
        _alignment  = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.height = 60;
    
    self.nameLabel.frame  = CGRectMake(0, 0, self.width, 26);
    self.valueLabel.frame = CGRectMake(0, 0, self.width, 34);
    
    if ( self.layoutType == LayoutTypeMoneyTop ) {
        self.valueLabel.top = 0;
        self.nameLabel.top  = self.valueLabel.bottom;
    } else {
        self.nameLabel.top = 0;
        self.valueLabel.top  = self.nameLabel.bottom;
    }
}

- (void)setLayoutType:(LayoutType)layoutType
{
    _layoutType = layoutType;
    
    [self setNeedsLayout];
}

- (void)setMoney:(NSString *)money forLabel:(NSString *)label
{
    self.valueLabel.text = money;
    self.nameLabel.text  = label;
}

- (void)setAlignment:(NSTextAlignment)alignment
{
    _alignment = alignment;
    
    self.nameLabel.textAlignment = alignment;
    self.valueLabel.textAlignment = alignment;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   self.alignment,
                                   AWSystemFontWithSize(12, NO),
                                   [UIColor whiteColor]);
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)valueLabel
{
    if ( !_valueLabel ) {
        _valueLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   self.alignment,
                                   AWCustomFont(@"PingFang SC", 18),
                                   [UIColor whiteColor]);
        [self addSubview:_valueLabel];
        _valueLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _valueLabel;
}

@end

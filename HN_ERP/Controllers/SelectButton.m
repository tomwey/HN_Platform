//
//  SelectButton.m
//  HN_ERP
//
//  Created by tomwey on 6/2/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SelectButton.h"
#import "Defines.h"

@interface SelectButton ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation SelectButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
        
        self.frame = CGRectMake(0, 0, 66, 34);
        
        self.cornerRadius = 4;
        
        self.layer.borderColor = AWColorFromRGB(201, 201, 201).CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = 8;
    
    self.arrowView.center = CGPointMake(self.width - left - self.arrowView.width / 2,
                                        self.height / 2);
    
    CGFloat labelWidth = self.arrowView.left - 5 - left;
    
    self.titleLabel.frame = CGRectMake(left, 0, labelWidth, self.height);
}

- (void)tap
{
    if ( self.clickBlock ) {
        self.clickBlock(self);
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self addSubview:_titleLabel];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
    }
    return _titleLabel;
}

- (UIImageView *)arrowView
{
    if ( !_arrowView ) {
        _arrowView = AWCreateImageView(nil);
        [self addSubview:_arrowView];
        
        FAKIonIcons *icon = [FAKIonIcons androidArrowDropdownIconWithSize:20];
        [icon addAttributes:@{ NSForegroundColorAttributeName: self.titleLabel.textColor }];
        _arrowView.image = [icon imageWithSize:CGSizeMake(10, 10)];
        
        [_arrowView sizeToFit];
    }
    return _arrowView;
}

@end

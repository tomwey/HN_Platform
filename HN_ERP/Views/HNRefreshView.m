//
//  HNRefreshView.m
//  HN_ERP
//
//  Created by tomwey on 2/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNRefreshView.h"
#import "Defines.h"

@interface HNRefreshView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) DGActivityIndicatorView *indicatorView;

@end
@implementation HNRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, 120, 60);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.indicatorView.frame = CGRectMake(20, 0, 80, 30);
    self.indicatorView.center = CGPointMake(self.width / 2, self.height / 2 - 10);
    
    self.label.frame = CGRectMake(0, self.height - 30, self.width, 30);
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    self.label.text = text;
}

- (void)setAnimated:(BOOL)animated
{
    _animated = animated;
    
    if ( animated ) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
}

- (UILabel *)label
{
    if ( !_label ) {
        _label = AWCreateLabel(CGRectZero, nil,
                               NSTextAlignmentCenter,
                               AWSystemFontWithSize(13, NO),
                               AWColorFromRGB(135, 135, 135));
        [self addSubview:_label];
    }
    return _label;
}

- (DGActivityIndicatorView *)indicatorView
{
    if ( !_indicatorView ) {
        _indicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:MAIN_THEME_COLOR];
        [self addSubview:_indicatorView];
        
        [_indicatorView startAnimating];
        _indicatorView.layer.speed = 0.0f;
    }
    return _indicatorView;
}

@end

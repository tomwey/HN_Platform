//
//  AWLoadingResultView.m
//  BSA
//
//  Created by tangwei1 on 16/11/9.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "AWLoadingResultView.h"

@interface AWLoadingResultView ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation AWLoadingResultView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.resultLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 60);
    
    if ( self.iconView.image ) {
        self.iconView.frame = CGRectMake(0, 0, self.iconView.image.size.width, self.iconView.image.size.height);
        self.iconView.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                           CGRectGetHeight(self.frame) / 2 - 30);
        self.resultLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                              CGRectGetMaxY(self.iconView.frame) +
                                              CGRectGetHeight(self.resultLabel.frame) / 2);
    } else {
        self.iconView.frame = CGRectZero;
        self.resultLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                              CGRectGetHeight(self.frame) / 2);
    }
}

- (void)finishLoading:(AWLoadingState)loadingState
{
    if ( loadingState == AWLoadingStateFailure ) {
        self.iconView.image = self.errorImage;
        self.resultLabel.text = self.errorMessage;
    } else if ( loadingState == AWLoadingStateEmptyResult ) {
        self.iconView.image = self.emptyImage;
        self.resultLabel.text = self.emptyMessage;
    }
}

- (void)setErrorMessageAttributes:(NSDictionary<NSString *,id> *)errorMessageAttributes
{
    _errorMessageAttributes = errorMessageAttributes;
    
    if ( errorMessageAttributes[NSFontAttributeName] ) {
        self.resultLabel.font = errorMessageAttributes[NSFontAttributeName];
    }
    
    if ( errorMessageAttributes[NSForegroundColorAttributeName] ) {
        self.resultLabel.textColor = errorMessageAttributes[NSForegroundColorAttributeName];
    }
}

- (void)setEmptyMessageAttributes:(NSDictionary<NSString *,id> *)emptyMessageAttributes
{
    _emptyMessageAttributes = emptyMessageAttributes;
    
    if ( emptyMessageAttributes[NSFontAttributeName] ) {
        self.resultLabel.font = emptyMessageAttributes[NSFontAttributeName];
    }
    
    if ( emptyMessageAttributes[NSForegroundColorAttributeName] ) {
        self.resultLabel.textColor = emptyMessageAttributes[NSForegroundColorAttributeName];
    }
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)resultLabel
{
    if ( !_resultLabel ) {
        _resultLabel = [[UILabel alloc] init];
        [self addSubview:_resultLabel];
        _resultLabel.numberOfLines = 2;
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.backgroundColor = [UIColor clearColor];
    }
    return _resultLabel;
}

@end

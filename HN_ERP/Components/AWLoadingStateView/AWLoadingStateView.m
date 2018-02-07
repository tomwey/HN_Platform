//
//  AWLoadingStateView.m
//  BSA
//
//  Created by tangwei1 on 16/11/9.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "AWLoadingStateView.h"
#import "AWLoadingResultView.h"

@implementation AWLoadingStateView

/** 开始加载的视图 */
- (UIView <AWLoadingViewProtocol> *)viewForLoading
{
    AWLoadingView *loadingView = [[AWLoadingView alloc] init];
    loadingView.frame = CGRectMake(0, 0, 80, 80);
    return loadingView;
}

/** 加载完成的结果视图 */
- (UIView <AWLoadingResultViewProtocol> *)viewForLoadingDone
{
    AWLoadingResultView *resultView = [[AWLoadingResultView alloc] init];
    resultView.frame = CGRectMake(0, 0, 320, 320);
    resultView.errorMessage = @"加载出错了，点击重试";
    resultView.emptyMessage = @"很抱歉，暂未查询到相关数据";
    return resultView;
}

@end

@interface AWLoadingView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation AWLoadingView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
    
    self.spinner.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                      CGRectGetHeight(self.frame) / 2);
}

- (void)startLoading
{
    self.maskView.hidden = NO;
    [self.spinner startAnimating];
}

- (void)stopLoading
{
    self.maskView.hidden = YES;
    [self.spinner stopAnimating];
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.8;
        
        _maskView.layer.cornerRadius = 8;
        _maskView.clipsToBounds = YES;
    }
    return _maskView;
}

- (UIActivityIndicatorView *)spinner
{
    if ( !_spinner ) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_spinner];
    }
    return _spinner;
}

@end


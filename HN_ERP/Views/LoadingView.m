//
//  LoadingView.m
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "LoadingView.h"
#import "Defines.h"

@interface LoadingView ()

@property (nonatomic, strong) UIImageView *loadingImageView;

// 加载失败或者数据加载为空时显示
@property (nonatomic, strong) UIImageView *errorOrEmptyView;
@property (nonatomic, strong) UILabel *errorOrEmptyLabel;

@property (nonatomic, assign) LoadingState state;

@property (nonatomic, copy) void (^reloadCallback)(void);

@end

#define kWIFIIndicatorSize CGSizeMake(120,120)

@implementation LoadingView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.state = LoadingStateDefault;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
}

- (void)tap
{
    if ( self.state == LoadingStateFail ||
        self.state == LoadingStateEmptyResult) {
        if ( self.reloadCallback ) {
            self.reloadCallback();
            self.reloadCallback = nil;
        }
    }
}

- (void)startLoading:(void (^)(void))reloadCallback
{
    self.hidden = NO;
    
    self.reloadCallback = reloadCallback;
    
    if ( self.state == LoadingStateLoading ) {
        return;
    }
    
    self.state = LoadingStateLoading;
    
    if ( self.state == LoadingStateFail ||
        self.state == LoadingStateEmptyResult ) {
        // 表示之前已经加载失败过或者数据为空
        
        self.errorOrEmptyLabel.hidden = YES;
        self.errorOrEmptyView.hidden = YES;
    }
    
    self.loadingImageView.center = CGPointMake(self.width / 2, self.height / 2 - 20);
    self.loadingImageView.hidden = NO;
    
//    NSLog(@"loading: %@", self.loadingImageView);
    
    if ( ![self.loadingImageView isAnimating] ) {
//        NSLog(@"ccccccccccc");
        [self.loadingImageView startAnimating];
    }
}

- (void)finishLoading:(LoadingState)state
{
    if ( self.state == LoadingStateLoading ) {
        [self.loadingImageView stopAnimating];
        self.loadingImageView.hidden = YES;
    }
    
    if ( state == LoadingStateSuccessResult || state == LoadingStateDefault ) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
        
        self.errorOrEmptyView.center = CGPointMake(self.width / 2, self.height / 2 - 20);
        self.errorOrEmptyView.hidden = NO;
        
        self.errorOrEmptyView.image = state == LoadingStateFail ? AWImageNoCached(@"notransfer.png") : AWImageNoCached(@"nodata.png");
        
        self.errorOrEmptyLabel.center = CGPointMake(self.width / 2,
                                                    self.errorOrEmptyView.bottom + 10 + self.errorOrEmptyLabel.height / 2);
        self.errorOrEmptyLabel.hidden = NO;
        
        self.errorOrEmptyLabel.text = state == LoadingStateFail ? @"Oops, 查询失败了！" : @"暂未查询到相关数据";
    }
    
    self.state = state;
}

- (UIImageView *)loadingImageView
{
    if ( !_loadingImageView ) {
        _loadingImageView = AWCreateImageView(nil);
        
        [self addSubview:_loadingImageView];
        
        _loadingImageView.frame = CGRectMake(0, 0, kWIFIIndicatorSize.width, kWIFIIndicatorSize.height);
        
        _loadingImageView.animationImages = @[[UIImage imageNamed:@"loading_1.png"],
                                              [UIImage imageNamed:@"loading_2.png"],
                                              [UIImage imageNamed:@"loading_3.png"],
                                              [UIImage imageNamed:@"loading_4.png"]];
        _loadingImageView.animationDuration = 1.0;
    }
    
    return _loadingImageView;
}

- (UIImageView *)errorOrEmptyView
{
    if ( !_errorOrEmptyView ) {
        _errorOrEmptyView = AWCreateImageView(nil);
        [self addSubview:_errorOrEmptyView];
        
        _errorOrEmptyView.frame = CGRectMake(0, 0, kWIFIIndicatorSize.width, kWIFIIndicatorSize.height);
    }
    return _errorOrEmptyView;
}

- (UILabel *)errorOrEmptyLabel
{
    if ( !_errorOrEmptyLabel ) {
        _errorOrEmptyLabel = AWCreateLabel(CGRectMake(0, 0, AWFullScreenWidth(), 50),
                                           nil,
                                           NSTextAlignmentCenter,
                                           nil,
                                           AWColorFromRGB(191, 192, 191));
        [self addSubview:_errorOrEmptyLabel];
    }
    
    return _errorOrEmptyLabel;
}

@end

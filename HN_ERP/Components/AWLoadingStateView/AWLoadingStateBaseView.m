//
//  AWLoadingStateView.m
//  BSA
//
//  Created by tangwei1 on 16/11/9.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "AWLoadingStateBaseView.h"
#import <objc/runtime.h>

@interface AWLoadingStateBaseView ()

@property (nonatomic, weak, readwrite) UIView <AWLoadingStateProtocol> *child;

@property (nonatomic, strong) UIView <AWLoadingViewProtocol> *loadingView;
@property (nonatomic, strong) UIView <AWLoadingResultViewProtocol> *loadingResultView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, copy) void (^reloadCallback)(void);

@property (nonatomic, assign, readwrite) AWLoadingState loadingState;

@end

@implementation AWLoadingStateBaseView

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
    self.loadingState = AWLoadingStateDefault;
    
    if ( [self conformsToProtocol:@protocol(AWLoadingStateProtocol)] ) {
        
        self.child = (UIView <AWLoadingStateProtocol> *)self;
        
        self.loadingView = [self.child viewForLoading];
        self.loadingResultView = [self.child viewForLoadingDone];
        
        [self addSubview:self.loadingView];
        
        [self addSubview:self.loadingResultView];
        
        self.loadingView.hidden = YES;
        self.loadingResultView.hidden = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addGestureRecognizer:self.tapGesture];
    } else {
        NSException *exception = [[NSException alloc] initWithName:@"kAWException" reason:@"该类必须被继承" userInfo:nil];
        @throw exception;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width  = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    if ( CGRectIsNull(self.loadingView.bounds) ||
        CGRectIsEmpty(self.loadingView.bounds) ) {
        self.loadingView.bounds = CGRectMake(0, 0, width * 0.382, width * 0.382);
    }
    
    if ( CGRectIsNull(self.loadingResultView.bounds) ||
        CGRectIsEmpty(self.loadingResultView.bounds) ) {
        self.loadingResultView.bounds = CGRectMake(0, 0, width, height * 0.618);
    }
    
    self.loadingView.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0,
                                          CGRectGetHeight(self.frame) / 2.0);
    self.loadingResultView.center = self.loadingView.center;
}

- (void)startLoading:(void (^)(void))reloadCallback
{
    self.hidden = NO;
    
    self.reloadCallback = reloadCallback;
    
    self.loadingState = AWLoadingStateLoading;
    
    self.loadingView.hidden = NO;
    self.loadingResultView.hidden = YES;
    
    [self.loadingView startLoading];
}

- (void)finishLoading:(AWLoadingState)loadingState
{
    [self.loadingView stopLoading];
    
    self.loadingState = loadingState;
    
    self.loadingView.hidden = YES;
    self.loadingResultView.hidden = NO;
    
    [self.loadingResultView finishLoading:loadingState];
    
    if ( loadingState == AWLoadingStateSuccess ) {
        [self removeFromSuperview];
    }
}

- (UITapGestureRecognizer *)tapGesture
{
    if ( !_tapGesture ) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    }
    return _tapGesture;
}

- (void)tap
{
    if ( self.loadingState == AWLoadingStateFailure ) {
        if ( self.reloadCallback ) {
            self.reloadCallback();
        }
    }
}

@end

@implementation UIViewController (AWLoadingStateView)

- (AWLoadingStateBaseView *)aw_loadingStateView
{
    AWLoadingStateBaseView *loadingStateView = objc_getAssociatedObject(self, &@selector(aw_loadingStateView));
    return loadingStateView;
}

- (void)aw_setLoadingStateView:(AWLoadingStateBaseView *)aView
{
    objc_setAssociatedObject(self, &@selector(aw_loadingStateView), aView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 * 显示加载状态视图；适用于某个页面有第一次请求网络的场景
 *
 * @param aView 状态视图的父视图
 * @param clz 具体状态视图类，该类是AWLoadingStateBaseView的子类
 * @param callback 当请求失败时，可以点击屏幕进行重新加载，此参数为重新加载的回调
 * @return 返回该状态视图
 *
 */
- (AWLoadingStateBaseView *)startLoadingInView:(UIView *)aView
                                      forStateViewClass:(Class)clz
                                         reloadCallback:(void (^)(void))callback
{
    AWLoadingStateBaseView *stateView = [self aw_loadingStateView];
    if ( !stateView ) {
        stateView = [[clz alloc] init];
        [self aw_setLoadingStateView:stateView];
    }
    
    if ( !stateView.superview ) {
        [aView addSubview:stateView];
        
        stateView.frame = aView.bounds;
        stateView.backgroundColor = aView.backgroundColor ?: [UIColor whiteColor];
    }
    
    [aView bringSubviewToFront:stateView];
    
    [stateView startLoading:callback];
    
    return stateView;
}

/**
 * 完成加载时需要调用该方法显示状态结果
 *
 * @param loadingState 当前加载的状态
 * @return
 *
 */
- (void)finishLoading:(AWLoadingState)loadingState
{
    AWLoadingStateBaseView *stateView = [self aw_loadingStateView];
    
    [stateView finishLoading:loadingState];
}

@end



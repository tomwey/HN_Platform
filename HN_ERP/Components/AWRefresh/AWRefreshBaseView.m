//
//  AWRefreshBaseView.m
//  BayLe
//
//  Created by tangwei1 on 15/11/26.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "AWRefreshBaseView.h"
#import <objc/message.h>

@interface AWRefreshBaseView ()
{
    CGFloat _lastOffsetY;
}
@property (nonatomic, assign, readwrite) UIScrollView* scrollView;
@property (nonatomic, assign, readwrite) UIEdgeInsets scrollViewOriginContentInset;
@property (nonatomic, assign, readwrite) AWRefreshState state;

@end

#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)

const CGFloat AWRefreshAnimationDuration = 0.25;

static NSString * const AWRefreshContentOffset = @"contentOffset";
static NSString * const AWRefreshContentSize = @"contentSize";

@implementation AWRefreshBaseView

@synthesize state = _state;

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Lifecycle Methods
///////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = 64.0;
    if ( self = [super initWithFrame:frame] ) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor  = [UIColor clearColor];
        
        // 设置默认状态
        _state = AWRefreshStateNormal;
        
        _lastOffsetY = 0.0;
    }
    return self;
}

- (void)dealloc
{
    self.beginRefreshingCallback = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self.superview removeObserver:self forKeyPath:AWRefreshContentOffset context:nil];
    
    // 上拉加载更多还需要观察contentSize改变
    if ( self.refreshMode == AWRefreshModePullUpLoadMore ) {
        [self.superview removeObserver:self forKeyPath:AWRefreshContentSize context:nil];
    }
    
    if ( newSuperview ) {
        [newSuperview addObserver:self forKeyPath:AWRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        self.scrollView = (UIScrollView *)newSuperview;
        self.scrollViewOriginContentInset = self.scrollView.contentInset;
        
        // 重新计算组件的frame
        [self recalcuFrame];
        
        // 添加KVO监听
        if ( self.refreshMode == AWRefreshModePullUpLoadMore ) {
            [newSuperview addObserver:self forKeyPath:AWRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    // 调用钩子方法
    [self originState];
}

// 获得scrollView的内容 超出 view 的高度
- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginContentInset.bottom - self.scrollViewOriginContentInset.top;
    return self.scrollView.contentSize.height - h;
}

- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginContentInset.top;
    } else {
        return - self.scrollViewOriginContentInset.top;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods
///////////////////////////////////////////////////////////////////////////////////////////
/** 开始刷新 */
- (void)beginRefreshing
{
    if ( self.state == AWRefreshStateRefreshing ) {
        [self invokeRefresh];
    } else {
        self.state = AWRefreshStateRefreshing;
    }
}

/** 完成刷新 */
- (void)endRefreshing
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AWRefreshAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.state = AWRefreshStateNormal;
    });
}

- (BOOL)isRefreshing
{
    return self.state == AWRefreshStateRefreshing;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 下面的方法需要被子类重写
///////////////////////////////////////////////////////////////////////////////////////////
- (void)originState
{
    NSLog(@"默认初始状态");
}

- (void)releaseToRefresh
{
    NSLog(@"拖动的临界状态，松开即将刷新");
}

- (void)changeToRefresh
{
    NSLog(@"开始刷新");
}

- (void)updateOffset:(CGFloat)dty
{
    
}

- (void)backToNormalState
{
    NSLog(@"回到正常状态");
}

/*
 ###########  注意：子类必须重写此方法 ###########
 */
- (AWRefreshMode)refreshMode
{
    [NSException raise:@"AWRefreshOverrideException" format:@"子类必须重写- (AWRefreshMode)refreshMode"];
    return AWRefreshModeUnKnown;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark KVO Method
///////////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // 如果控件被触摸被禁用或者控件看不见，直接不处理
    if ( self.userInteractionEnabled == NO || self.alpha <= 0.0001 || self.hidden ) {
        return;
    }
    
    if ( self.refreshMode == AWRefreshModePullUpLoadMore ) {
        // 加载更多
        if ( [keyPath isEqualToString:AWRefreshContentSize] ) {
            [self recalcuFrame];
        } else if ( [AWRefreshContentOffset isEqualToString:keyPath] ) {
            
            // 如果正在刷新，直接返回
            if ( self.state == AWRefreshStateRefreshing ) {
                return;
            }
            
            // 当前的contentOffset
            CGFloat currentOffsetY = self.scrollView.contentOffset.y;
            // 尾部控件刚好出现的offsetY
            CGFloat happenOffsetY = [self happenOffsetY];
            
            // 如果是向下滚动到看不见尾部控件，直接返回
            if (currentOffsetY <= happenOffsetY) return;
            
            if (self.scrollView.isDragging) {
                // 普通 和 即将刷新 的临界点
                CGFloat normal2pullingOffsetY = happenOffsetY + CGRectGetHeight(self.frame);
                
                if (self.state == AWRefreshStateNormal && currentOffsetY > normal2pullingOffsetY) {
                    // 转为即将刷新状态
                    self.state = AWRefreshStatePulling;
                } else if (self.state == AWRefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
                    // 转为普通状态
                    self.state = AWRefreshStateNormal;
                }
            } else if (self.state == AWRefreshStatePulling) {// 即将刷新 && 手松开
                // 开始刷新
                self.state = AWRefreshStateRefreshing;
            }
        }
    } else {
        
        // 如果正在刷新，直接返回
        if ( self.state == AWRefreshStateRefreshing ) {
            return;
        }
        
        // 下拉刷新
        if ( [keyPath isEqualToString:AWRefreshContentOffset] ) {
            // 当前的contentOffset
            CGFloat currentOffsetY = self.scrollView.contentOffset.y;

            // 头部控件刚好出现的offsetY
            CGFloat happenOffsetY = - self.scrollViewOriginContentInset.top;
            
            // 如果是向上滚动到看不见头部控件，直接返回
            if (currentOffsetY >= happenOffsetY) return;
            
            // 普通 和 即将刷新 的临界点
            if (self.scrollView.isDragging) {
                CGFloat normal2pullingOffsetY = happenOffsetY - CGRectGetHeight(self.frame);
                
                [self updateOffset:currentOffsetY / normal2pullingOffsetY];
                
                if (self.state == AWRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
                    // 转为即将刷新状态
                    self.state = AWRefreshStatePulling;
                } else if (self.state == AWRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
                    // 转为普通状态
                    self.state = AWRefreshStateNormal;
                }
            } else if (self.state == AWRefreshStatePulling) {// 即将刷新 && 手松开
                // 开始刷新
                self.state = AWRefreshStateRefreshing;
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Getters and Setters
///////////////////////////////////////////////////////////////////////////////////////////
- (void)setState:(AWRefreshState)state
{
    // 保存当前的contentInset
    if ( self.state != AWRefreshStateRefreshing ) {
        self.scrollViewOriginContentInset = self.scrollView.contentInset;
    }
    
    // 状态一样不处理
    if ( self.state == state ) {
        return;
    }
    
    switch (state) {
        case AWRefreshStateNormal:
        {
            [self backToNormalState];
            if ( self.state == AWRefreshStateRefreshing ) {
                
                _state = AWRefreshStatePulling;
                [UIView animateWithDuration:AWRefreshAnimationDuration animations:^{
                    UIEdgeInsets inset = self.scrollView.contentInset;
                    if ( self.refreshMode == AWRefreshModePullDownRefresh ) {
                        inset.top -= CGRectGetHeight(self.frame);
                    } else {
                        inset.bottom = self.scrollViewOriginContentInset.bottom;
                    }
                    
                    self.scrollView.contentInset = inset;
                } completion:^(BOOL finished) {
                    self.state = AWRefreshStateNormal;
                }];
            } else {
//                NSLog(@"默认状态");
                // self.state == AWRefreshStatePulling;
//                NSLog(@"即将回到正常状态");
//                _state = state;
            }
        }
            break;
        case AWRefreshStatePulling:
        {
            [self releaseToRefresh];
        }
            break;
        case AWRefreshStateRefreshing:
        {
            [self invokeRefresh];
            
            _state = state;
            
            // 调用钩子方法
            [self changeToRefresh];
            
            // 动态更新Scroll View的状态
            [self updateScrollViewState];
            
        }
            break;
            
        default:
            break;
    }
    
    _state = state;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////
- (void)updateScrollViewState
{
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    CGPoint offset = self.scrollView.contentOffset;
    
    if ( self.refreshMode == AWRefreshModePullDownRefresh ) {
        contentInset.top = self.scrollViewOriginContentInset.top + CGRectGetHeight(self.frame);
        offset.y = - contentInset.top;
    } else {
        CGFloat bottom = CGRectGetHeight(self.frame) + self.scrollViewOriginContentInset.bottom;
        CGFloat deltaH = [self heightForContentBreakView];
        if ( deltaH < 0 ) {
            bottom -= deltaH;
        }
        
        contentInset.bottom = bottom;
        
        offset.y += contentInset.bottom;
    }
    
    [UIView animateWithDuration:AWRefreshAnimationDuration animations:^{
        self.scrollView.contentInset = contentInset;
//        self.scrollView.contentOffset = offset;
        [self.scrollView setContentOffset:offset animated:NO];
    }];
}

- (void)recalcuFrame
{
    CGRect frame = self.frame;
    frame.size.height = 64;
    frame.size.width = CGRectGetWidth(self.scrollView.frame);
    frame.origin.x = 0;
    
    if ( self.refreshMode == AWRefreshModePullDownRefresh ) {
        // 下拉刷新
        frame.origin.y = 0;
    } else {
        // 内容的高度
        CGFloat contentHeight = self.scrollView.contentSize.height;
        // 滚动的高度
        CGFloat scrollHeight = CGRectGetHeight(self.scrollView.frame) - self.scrollViewOriginContentInset.top - self.scrollViewOriginContentInset.bottom;
        // 设置位置和尺寸
        frame.origin.y = MAX(contentHeight, scrollHeight);
    }
    
    self.frame = frame;
}

- (void)invokeRefresh
{
    // 真正回调刷新
    if ( self.beginRefreshingCallback ) {
        self.beginRefreshingCallback();
    } else if ( [self.beginRefreshingTarget respondsToSelector:self.beginRefreshingAction] ) {
      msgSend((__bridge void *)(self.beginRefreshingTarget), self.beginRefreshingAction, self);
    }
}

@end


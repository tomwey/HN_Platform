//
//  UIScrollView+AWRefresh.m
//  BayLe
//
//  Created by tangwei1 on 15/11/26.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "UIScrollView+AWRefresh.h"
#import <objc/runtime.h>

@interface UIScrollView (InternalProperty)

@property (nonatomic, assign) AWRefreshBaseView* headerRefreshView;
@property (nonatomic, assign) AWRefreshBaseView* footerLoadMoreView;

@end

@implementation UIScrollView (AWRefresh)

///////////////////////////////////////////////////////////////////////////////
#pragma mark - 运行时相关
///////////////////////////////////////////////////////////////////////////////

static char AWRefreshHeaderViewKey;
static char AWLoadMoreFooterViewKey;

- (void)setHeaderRefreshView:(AWRefreshBaseView *)refreshView
{
    [self willChangeValueForKey:@"AWRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &AWRefreshHeaderViewKey, refreshView, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"AWRefreshHeaderViewKey"];
}

- (AWRefreshBaseView*)headerRefreshView
{
    return objc_getAssociatedObject(self, &AWRefreshHeaderViewKey);
}

- (void)setFooterLoadMoreView:(AWRefreshBaseView *)loadMoreView
{
    [self willChangeValueForKey:@"AWLoadMoreFooterViewKey"];
    objc_setAssociatedObject(self, &AWLoadMoreFooterViewKey, loadMoreView, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"AWLoadMoreFooterViewKey"];
}

- (AWRefreshBaseView*)footerLoadMoreView
{
    return objc_getAssociatedObject(self, &AWLoadMoreFooterViewKey);
}

///////////////////////////////////////////////////////////////////////////////
#pragma mark - 下拉刷新
///////////////////////////////////////////////////////////////////////////////
- (void)addHeaderRefreshView:(AWRefreshBaseView *)refreshView withCallback:(void (^)())callback
{
    self.headerRefreshView = refreshView;
    [self addSubview:refreshView];
    
    CGRect frame = refreshView.frame;
    frame.origin.y = - CGRectGetHeight(frame);
    self.headerRefreshView.frame = frame;
    
    // 设置刷新回调
    self.headerRefreshView.beginRefreshingCallback = callback;
}

- (void)addHeaderRefreshView:(AWRefreshBaseView *)refreshView withTarget:(id)target action:(SEL)action
{
    self.headerRefreshView = refreshView;
    [self addSubview:refreshView];
    
    CGRect frame = refreshView.frame;
    frame.origin.y = 0;
    self.headerRefreshView.frame = frame;
    
    // 设置刷新回调
    self.headerRefreshView.beginRefreshingTarget = target;
    self.headerRefreshView.beginRefreshingAction = action;
}

- (void)removeHeaderRefreshView
{
    [self.headerRefreshView removeFromSuperview];
    self.headerRefreshView = nil;
}

- (void)headerRefreshViewBeginRefreshing
{
    if ( !self.headerRefreshView.isRefreshing ) {
        [self.headerRefreshView beginRefreshing];
    }
}

- (void)headerRefreshViewEndRefreshing
{
    [self.headerRefreshView endRefreshing];
}

- (void)setHeaderRefreshViewHidden:(BOOL)headerRefreshViewHidden
{
    self.headerRefreshView.hidden = headerRefreshViewHidden;
}

- (BOOL)isHeaderRefreshViewHidden { return self.headerRefreshView.hidden; }

- (BOOL)isHeaderRefreshViewRefreshing { return self.headerRefreshView.state == AWRefreshStateRefreshing; }

///////////////////////////////////////////////////////////////////////////////
#pragma mark - 上拉加载更多
///////////////////////////////////////////////////////////////////////////////
- (void)addFooterLoadMoreView:(AWRefreshBaseView *)refreshView withCallback:(void (^)())callback
{
    self.footerLoadMoreView = refreshView;
    [self addSubview:self.footerLoadMoreView];
    
    CGRect frame = self.footerLoadMoreView.frame;
    CGFloat deltaHeight = CGRectGetHeight(self.frame) - self.contentInset.bottom - self.contentInset.top;
    frame.origin.y = MAX(deltaHeight, self.contentSize.height);
    self.footerLoadMoreView.frame = frame;
    
    self.footerLoadMoreView.beginRefreshingCallback = callback;
}

- (void)addFooterLoadMoreView:(AWRefreshBaseView *)refreshView withTarget:(id)target action:(SEL)action
{
    self.footerLoadMoreView = refreshView;
    [self addSubview:self.footerLoadMoreView];
    
    CGRect frame = self.footerLoadMoreView.frame;
    CGFloat deltaHeight = CGRectGetHeight(self.frame) - self.contentInset.bottom - self.contentInset.top;
    frame.origin.y = MAX(deltaHeight, self.contentSize.height);
    self.footerLoadMoreView.frame = frame;
    
    self.footerLoadMoreView.beginRefreshingTarget = target;
    self.footerLoadMoreView.beginRefreshingAction = action;
}

- (void)removeFooterLoadMoreView
{
    [self.footerLoadMoreView removeFromSuperview];
    self.footerLoadMoreView = nil;
}

- (void)footerLoadMoreViewBeginLoading
{
    [self.footerLoadMoreView beginRefreshing];
}

- (void)footerLoadMoreViewEndLoading
{
    [self.footerLoadMoreView endRefreshing];
}

- (void)setFooterLoadMoreViewHidden:(BOOL)footerLoadMoreViewHidden
{
    self.footerLoadMoreView.hidden = footerLoadMoreViewHidden;
}

- (BOOL)isFooterLoadMoreViewHidden { return self.footerLoadMoreView.hidden; }

- (BOOL)isFooterLoadMoreViewLoading { return self.footerLoadMoreView.state == AWRefreshStateRefreshing; }

@end

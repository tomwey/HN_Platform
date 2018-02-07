//
//  UIScrollView+AWRefresh.h
//  BayLe
//
//  Created by tangwei1 on 15/11/26.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWRefreshBaseView.h"

@interface UIScrollView (AWRefresh)

//////////////////////////////////////////////////////////////////////////
#pragma mark - 头部下拉刷新
//////////////////////////////////////////////////////////////////////////

/**
 * 添加一个头部下拉刷新控件
 *
 * @param refreshView 刷新控件
 * @param callback 刷新回调
 */
- (void)addHeaderRefreshView:(AWRefreshBaseView *)refreshView
                withCallback:(void (^)())callback;

/**
 * 添加一个头部下拉刷新控件
 *
 * @param refreshView 刷新控件
 * @param target 目标
 * @param action 刷新回调方法
 */
- (void)addHeaderRefreshView:(AWRefreshBaseView *)refreshView
                  withTarget:(id)target
                      action:(SEL)action;

/**
 * 移除头部下拉刷新控件
 */
- (void)removeHeaderRefreshView;

/**
 * 头部下拉刷新控件开始刷新
 */
- (void)headerRefreshViewBeginRefreshing;

/**
 * 头部下拉刷新控件停止刷新
 */
- (void)headerRefreshViewEndRefreshing;

/** 设置头部下拉刷新控件是否隐藏 */
@property (nonatomic, assign, getter=isHeaderRefreshViewHidden) BOOL headerRefreshViewHidden;

/** 返回当前头部刷新控件是否正在刷新 */
@property (nonatomic, assign, readonly, getter=isHeaderRefreshViewRefreshing) BOOL headerRefreshViewRefreshing;

//////////////////////////////////////////////////////////////////////////
#pragma mark - 尾部上拉加载更多
//////////////////////////////////////////////////////////////////////////

/**
 * 添加一个尾部上拉加载更多控件
 *
 * @param refreshView 刷新控件
 * @param callback 刷新回调
 */
- (void)addFooterLoadMoreView:(AWRefreshBaseView *)refreshView
                 withCallback:(void (^)())callback;

/**
 * 添加一个尾部上拉加载更多控件
 *
 * @param refreshView 刷新控件
 * @param target 目标
 * @param action 刷新回调方法
 */
- (void)addFooterLoadMoreView:(AWRefreshBaseView *)refreshView
                   withTarget:(id)target
                       action:(SEL)action;

/**
 * 移除尾部上拉加载更多控件
 */
- (void)removeFooterLoadMoreView;

/**
 * 尾部上拉加载更多控件开始加载
 */
- (void)footerLoadMoreViewBeginLoading;

/**
 * 尾部上拉加载更多停止加载
 */
- (void)footerLoadMoreViewEndLoading;

/** 设置尾部上拉加载更多控件是否隐藏 */
@property (nonatomic, assign, getter=isFooterLoadMoreViewHidden) BOOL footerLoadMoreViewHidden;

/** 返回当前尾部加载控件是否正在加载 */
@property (nonatomic, assign, readonly, getter=isFooterLoadMoreViewLoading) BOOL footerLoadMoreViewLoading;

@end

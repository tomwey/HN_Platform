//
//  AWLoadingStateView.h
//  BSA
//
//  Created by tangwei1 on 16/11/9.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AWLoadingState) {
    AWLoadingStateDefault, // 初始化的状态
    AWLoadingStateLoading, // 开始加载的状态
    AWLoadingStateSuccess, // 加载成功
    AWLoadingStateFailure, // 加载失败
    AWLoadingStateEmptyResult, // 加载结果为空
};

/// 加载视图协议
@protocol AWLoadingViewProtocol <NSObject>

/**
 * 开始加载
 */
- (void)startLoading;

/**
 * 停止加载
 */
- (void)stopLoading;

@end

/// 加载完成的视图协议
@protocol AWLoadingResultViewProtocol <NSObject>

/**
 * 完成加载
 */
- (void)finishLoading:(AWLoadingState)loadingState;

@end

/// 加载状态协议
@protocol AWLoadingStateProtocol <NSObject>

/** 开始加载的视图 */
- (UIView <AWLoadingViewProtocol> *)viewForLoading;

/** 加载完成的结果视图 */
- (UIView <AWLoadingResultViewProtocol> *)viewForLoadingDone;

@end

/// 抽象的基类，必须被继承
@interface AWLoadingStateBaseView : UIView

@property (nonatomic, weak, readonly) UIView <AWLoadingStateProtocol> *child;

/** 当前加载状态 */
@property (nonatomic, assign, readonly) AWLoadingState loadingState;

/*********************************************************
 
          ######## 子类不要重写下面的方法 ########
 
 *********************************************************/

/**
 * 开始加载
 *
 * @param 网络加载失败时，点击屏幕重新加载的回调
 */
- (void)startLoading:(void (^)(void))reloadCallback;

/**
 * 完成加载
 *
 * @param loadingState 完成加载时的状态
 */
- (void)finishLoading:(AWLoadingState)loadingState;

@end

@interface UIViewController (AWLoadingStateView)

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
                                         reloadCallback:(void (^)(void))callback;

/**
 * 完成加载时需要调用该方法显示状态结果
 *
 * @param loadingState 当前加载的状态
 * @return
 *
 */
- (void)finishLoading:(AWLoadingState)loadingState;

@end


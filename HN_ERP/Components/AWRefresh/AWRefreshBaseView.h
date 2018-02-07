//
//  AWRefreshBaseView.h
//  BayLe
//
//  Created by tangwei1 on 15/11/26.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
/*****************************************************************
 此类为刷新控件基类，是抽象类，子类需要重写注释中提到的方法来自定义效果
 *****************************************************************/

// 定义控件的状态
typedef NS_ENUM(NSInteger, AWRefreshState) {
    AWRefreshStateUnKnown = -1,   // 未知状态
    AWRefreshStateNormal = 1,     // 正常状态
    AWRefreshStatePulling,        // 正在拖动状态
    AWRefreshStateWillRefreshing, // 即将开始刷新的状态
    AWRefreshStateRefreshing,     // 正在刷新状态
};

// 定义拖动刷新模式
typedef NS_ENUM(NSInteger, AWRefreshMode) {
    AWRefreshModeUnKnown = -1,    // 未知模式
    AWRefreshModePullDownRefresh, // 下拉刷新模式
    AWRefreshModePullUpLoadMore,  // 上拉加载更多模式
};

/** 动画时间长度 */
FOUNDATION_EXTERN const CGFloat AWRefreshAnimationDuration;

@interface AWRefreshBaseView : UIView

/** 开始刷新 */
- (void)beginRefreshing;

/** 完成刷新 */
- (void)endRefreshing;

/** 设置开始刷新的回调 */
@property (nonatomic, copy) void (^beginRefreshingCallback)();

/** 设置开始刷新的回调Target - Action */
@property (nonatomic, assign) id beginRefreshingTarget;
@property (nonatomic, assign) SEL beginRefreshingAction;

/** 返回当前UIScrollView */
@property (nonatomic, assign, readonly) UIScrollView* scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginContentInset;

/** 返回当前是否正在刷新 */
@property (nonatomic, assign, readonly) BOOL isRefreshing;

/** 返回当前状态 */
@property (nonatomic, assign, readonly) AWRefreshState state;

/////////////////////////////////////////////////////////////////
#pragma mark - 下面的方法需要子类重写
/////////////////////////////////////////////////////////////////
/** 
 * 默认状态，该组件被添加到视图中 
 */
- (void)originState;

/** 松开刷新 */
- (void)releaseToRefresh;

/** 开始刷新 */
- (void)changeToRefresh;

/** 下拉时调用 */
- (void)updateOffset:(CGFloat)dty;

/** 
 * 回到正常状态时调用
 *
 * 注意：有2种情况会回调该方法，
 * 1) 拖动组件，没有达到临界刷新点，没有刷新
 * 2) 拖动组件，开始刷新，刷新结束
 */
- (void)backToNormalState;

/** 
 * 子类重写返回正确的刷新模式，比如下拉刷新或者上拉加载更多
 */
- (AWRefreshMode)refreshMode;

@end


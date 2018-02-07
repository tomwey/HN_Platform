//
//  UIView+AWGeometry.h
//  Pods
//
//  Created by tangwei1 on 16/5/24.
//
//

#import <UIKit/UIKit.h>

@interface UIView (AWGeometry)

/** 设置位置大小 */
@property (nonatomic, assign) CGPoint position;

/** 设置宽和高 */
@property (nonatomic, assign) CGSize  boundsSize;

/** 设置位置x坐标值 */
@property (nonatomic, assign) CGFloat x;

/** 设置位置y坐标值 */
@property (nonatomic, assign) CGFloat y;

/** 设置宽度 */
@property (nonatomic, assign) CGFloat width;

/** 设置高度 */
@property (nonatomic, assign) CGFloat height;

/** 返回父容器坐标系中的中心点x坐标的值 */
@property (nonatomic, assign, readonly) CGFloat midX;

/** 返回父容器坐标系中的中心点y坐标的值 */
@property (nonatomic, assign, readonly) CGFloat midY;

/** 设置位置坐标x的值，等价于直接设置x的值 */
@property (nonatomic, assign) CGFloat left;

/** 设置位置坐标y的值，等价于直接设置y的值 */
@property (nonatomic, assign) CGFloat top;

/** 返回父容器坐标系中的x坐标的值+宽度 */
@property (nonatomic, assign, readonly) CGFloat right;

/** 返回父容器坐标系中的y坐标的值+高度 */
@property (nonatomic, assign, readonly) CGFloat bottom;

/** 返回父容器坐标系中的中心点 */
@property (nonatomic, assign, readonly) CGPoint centerInFrame;

/** 返回自己内部坐标系中的中心点 */
@property (nonatomic, assign, readonly) CGPoint centerInBounds;

/** 设置视图的圆角 */
@property (nonatomic, assign) CGFloat cornerRadius;

@end

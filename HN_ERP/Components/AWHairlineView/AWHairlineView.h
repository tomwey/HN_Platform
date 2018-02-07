//
//  AWHairlineView.h
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWHairlineView : UIView

//- (instancetype)initWithLineColor:(UIColor *)lineColor;

/**
 * 创建一根垂直头发丝
 *
 * @param height 线的高度
 * @param lineColor 线的颜色
 * @param superView 父视图
 */
+ (instancetype)verticalLineWithHeight:(CGFloat)height
                                 color:(UIColor *)lineColor
                                inView:(UIView *)superView;

/**
 * 创建一根水平头发丝
 *
 * @param width 线的长度
 * @param lineColor 线的颜色
 * @param superView 父视图
 */
+ (instancetype)horizontalLineWithWidth:(CGFloat)width
                                  color:(UIColor *)lineColor
                                 inView:(UIView *)superView;

@end

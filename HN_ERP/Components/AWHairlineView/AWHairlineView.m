//
//  AWHairlineView.m
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "AWHairlineView.h"

@implementation AWHairlineView

//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    return [self initWithLineColor:[UIColor lightGrayColor]];
//}

- (instancetype)initWithLineColor:(UIColor *)lineColor
{
    if ( self = [super init] ) {
        self.layer.borderColor = [lineColor CGColor];
        self.layer.borderWidth = ( 1.0 / [[UIScreen mainScreen] scale] ) / 2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/**
 * 创建一根垂直头发丝
 *
 * @param height 线的高度
 * @param lineColor 线的颜色
 * @param superView 父视图
 */
+ (instancetype)verticalLineWithHeight:(CGFloat)height
                                 color:(UIColor *)lineColor
                                inView:(UIView *)superView
{
    AWHairlineView *container = [[AWHairlineView alloc] initWithFrame:CGRectMake(0, 0, 1, height)];
    container.clipsToBounds = YES;
    [superView addSubview:container];
    container.backgroundColor = [UIColor clearColor];
    
    AWHairlineView *line = [[AWHairlineView alloc] initWithLineColor:lineColor];
    line.frame = CGRectMake(0, -1, 1, height + 2);
    [container addSubview:line];
    
    return container;
}

/**
 * 创建一根水平头发丝
 *
 * @param width 线的长度
 * @param lineColor 线的颜色
 * @param superView 父视图
 */
+ (instancetype)horizontalLineWithWidth:(CGFloat)width
                                  color:(UIColor *)lineColor
                                 inView:(UIView *)superView
{
    AWHairlineView *container = [[AWHairlineView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    container.clipsToBounds = YES;
    [superView addSubview:container];
    container.backgroundColor = [UIColor clearColor];
    container.layer.borderWidth = 0;
    
    AWHairlineView *line = [[AWHairlineView alloc] initWithLineColor:lineColor];
    line.frame = CGRectMake(-1, 0, width + 2, 1);
    [container addSubview:line];
    
    return container;
}

@end

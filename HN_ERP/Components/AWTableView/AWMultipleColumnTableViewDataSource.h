//
//  AWMultipleColumnTableViewDataSource.h
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "AWTableViewDataSource.h"

@interface AWMultipleColumnTableViewDataSource : AWTableViewDataSource

/** 设置每行的视图单元数，默认值为2 */
@property (nonatomic, assign) NSUInteger numberOfItemsPerRow;

/**
 * 每行中的单个列视图元素类名称
 * 注意：该类是UIView的子类，同时要实现AWTableDataConfig协议来进行数据绑定
 */
@property (nonatomic, copy) NSString* itemClass;

/** 设置每个列视图的大小 */
@property (nonatomic, assign) CGFloat marginTop;

/** 设置每行中每个列视图的y坐标，默认值为0.0 */
@property (nonatomic, assign) CGFloat offsetY;

/** 设置每行第一个列视图与表视图左边的间距或者每行最后一个列视图与表视图右边的间距，
 *  如果不设置默认为itemSpacing的值
 */
@property (nonatomic, assign) CGFloat itemMargin;

/** 每行中列视图之间的间距，必须设置 */
@property (nonatomic, assign) CGFloat itemSpacing;

/** 设置每个列视图的大小，必须设置 */
@property (nonatomic, assign) CGSize itemSize;

@end

/** 创建一个自动释放的表视图数据源适配器 */
static inline AWMultipleColumnTableViewDataSource* AWMultipleColumnTableViewDataSourceCreate(NSArray* dataSource, NSString* cellClass, NSString* identifier)
{
    return [AWMultipleColumnTableViewDataSource dataSourceWithArray:dataSource cellClass:cellClass identifier:identifier];
};

@interface UITableView (AWGridLayout)

- (void)resetForGridLayout;

@end

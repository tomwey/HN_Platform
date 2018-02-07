//
//  AWTableViewDataSource.h
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWTableDataConfig.h"
/*********************************************************************
 此UITableView数据源适配器只适用于普通的表视图，并且只有一个分区的表
 如果要支持其他情况，请继承该类，添加相应的功能支持
 *********************************************************************/
@interface AWTableViewDataSource : NSObject <UITableViewDataSource>

/** 设置数据源 */
@property (nonatomic, retain) NSArray* dataSource;

/**
 * 设置一个自定义的UITableViewCell类，不能为空
 * 注意：自定义cell类需要实现@seeAWTableDataConfig协议来绑定每行的数据
 */
@property (nonatomic, copy) NSString* cellClass;

/** 设置cell重用标识 */
@property (nonatomic, copy) NSString* identifier;

/** 设置当前表视图 */
@property (nonatomic, assign) UITableView* tableView;

/**
 * 设置对象点击回调
 * @param sender cell或者grid对象本身
 * @param selectedData 当前对象绑定的数据
 */
@property (nonatomic, copy) void (^itemDidSelectBlock)(UIView<AWTableDataConfig> *sender, id selectedData);

- (instancetype)initWithArray:(NSArray *)dataSource cellClass:(NSString *)cellClassName identifier:(NSString *)identifier;
+ (instancetype)dataSourceWithArray:(NSArray *)dataSource cellClass:(NSString *)cellClassName identifier:(NSString *)identifier;

/**
 * 通知表格刷新
 */
- (void)notifyDataChanged;

@end

/** 创建一个自动释放的表视图数据源适配器 */
static inline AWTableViewDataSource* AWTableViewDataSourceCreate(NSArray* dataSource, NSString* cellClass, NSString* identifier)
{
    return [AWTableViewDataSource dataSourceWithArray:dataSource cellClass:cellClass identifier:identifier];
};

//
//  LandListView.h
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandListView : UIView

@property (nonatomic, strong) NSDictionary *searchCondition;
@property (nonatomic, strong) id item;

@property (nonatomic, copy) void (^didSelectItemBlock)(LandListView *sender, id selectedItem);

/**
 * 开始加载数据
 * 
 * 该方法会先从缓存中去查找是否有数据，如果有数据，
 * 直接读取缓存数据，否则从网络加载并缓存
 *
 */
- (void)startLoading;

/**
 * 强制从网络加载第一页数据，并写入缓存
 */
- (void)forceRefreshing;

@end

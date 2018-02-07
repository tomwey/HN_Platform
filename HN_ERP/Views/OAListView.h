//
//  OAListView.h
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAListView : UIView

// 搜索条件
@property (nonatomic, strong) NSDictionary *searchCondition;

@property (nonatomic, copy) NSString *state;

// 来自相关流程的输入, from的值为某个相关流程的字段名
@property (nonatomic, copy) NSString *from;

- (void)startLoadingForState:(NSString *)state;

- (void)forceRefreshForState:(NSString *)state;

@end

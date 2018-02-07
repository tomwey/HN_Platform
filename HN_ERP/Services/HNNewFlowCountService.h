//
//  HNNewFlowCountService.h
//  HN_ERP
//
//  Created by tomwey on 3/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNNewFlowCountService : NSObject

// 是否可以获取新的待办流程数，默认为YES
@property (nonatomic, assign) BOOL canFetch;

+ (instancetype)sharedInstance;

- (void)startFetching:(void (^)(void))completion;

// 清零
- (void)resetNewFlowCount;
- (void)resetTotalFlowCount;

// 注册观察者
- (void)registerObserver:(id)observer;
// 取消注册观察者
- (void)unregisterObserver:(id)observer;

@end

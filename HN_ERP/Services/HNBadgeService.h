//
//  HNBadgeService.h
//  HN_ERP
//
//  Created by tomwey on 7/4/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kNeedReloadBadgeNotification;

@interface HNBadgeService : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor;

- (void)registerObserver:(id)observer forKey:(NSString *)key;

// 取消注册观察者
- (void)unregisterObserverForKey:(NSString *)key;

- (void)unregisterAllObservers;

@end

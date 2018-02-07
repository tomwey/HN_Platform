//
//  HNBadgeService.m
//  HN_ERP
//
//  Created by tomwey on 7/4/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNBadgeService.h"
#import "Defines.h"

@interface HNBadgeService ()

@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, assign) BOOL loading;

@end

NSString * const kNeedReloadBadgeNotification = @"kNeedReloadBadgeNotification";

@implementation HNBadgeService

+ (instancetype)sharedInstance
{
    static HNBadgeService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HNBadgeService alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if ( self = [super init] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startMonitor) name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startMonitor) name:kNeedReloadBadgeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startMonitor) name:@"kFlowHandleSuccessNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startMonitor) name:@"kMarkFlowReadNotification" object:nil];
    }
    return self;
}

- (void)startMonitor
{
    if ( self.loading ) return;
    
    self.loading = YES;
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSDictionary *params =  @{
                              @"dotype": @"GetData",
                              @"funname": @"移动端首页提醒APP",
                              @"param1": manID,      // man id
                              };
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:params completion:^(id result, NSError *error) {
         // 此处单例不考虑循环引用
         self.loading = NO;
         
         if ( !error ) {
             if ([result[@"rowcount"] integerValue] > 0) {
                 id data = [result[@"data"] firstObject];
                 [self handleResult:data];
             }
         }
     }];
}

- (void)handleResult:(id)result
{
//    NSLog(@"result: %@", result);
    for (id key in self.observers) {
        NSLog(@"key: %@", key);
        id observer = self.observers[key];
        
        if ( [key isEqualToString:@"flows"] ||
            [key isEqualToString:@"_flows"]) {
            NSInteger count = [result[@"flows"] integerValue];
            
            if ( [observer isKindOfClass:[UITabBarItem class]] ) {
                UITabBarItem *tabBar = (UITabBarItem *)observer;
                if (count <= 0) {
                    tabBar.badgeValue = nil;
                } else {
                    NSString *badgeValue = count > 99 ? @"99+" : [@(count) description];
                    tabBar.badgeValue = badgeValue;
                }
            } else if ( [observer isKindOfClass:[HNBadge class]] ) {
                HNBadge *badge = (HNBadge *)observer;
                
                if ( count != badge.badge ) {
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:@"kNeedReloadTodoFlowsNotification"
                                    object:nil];
                }
                
                badge.badge = count;
            }
        } else if ( [key isEqualToString:@"plans"] ) {
            NSInteger monthPlans = [result[@"month_plans"] integerValue];
            NSInteger projPlans  = [result[@"project_plans"] integerValue];
            NSInteger specialPlans = [result[@"special_plans"] integerValue];
            if ( [observer isKindOfClass:[HNBadge class]] ) {
                HNBadge *badge = (HNBadge *)observer;
                badge.badge = monthPlans + projPlans + specialPlans;
            }
        } else {
            if ( [observer isKindOfClass:[HNBadge class]] ) {
                HNBadge *badge = (HNBadge *)observer;
                badge.badge = [result[key] integerValue];
            }
        }
    }
}

- (void)registerObserver:(id)observer forKey:(NSString *)key
{
    if ( observer ) {
        [self.observers setObject:observer forKey:key];
    }
}

// 取消注册观察者
- (void)unregisterObserverForKey:(NSString *)key
{
    [self.observers removeObjectForKey:key];
}

- (void)unregisterAllObservers
{
    [self.observers removeAllObjects];
}

- (NSMutableDictionary *)observers
{
    if ( !_observers ) {
        _observers = [[NSMutableDictionary alloc] init];
    }
    return _observers;
}

@end

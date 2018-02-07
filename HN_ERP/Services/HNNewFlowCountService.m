//
//  HNNewFlowCountService.m
//  HN_ERP
//
//  Created by tomwey on 3/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNNewFlowCountService.h"
#import "APIService.h"
#import "UserService.h"
#import "HNBadge.h"

@interface HNNewFlowCountService ()

@property (nonatomic, assign) NSUInteger     newFlowCount;
@property (nonatomic, assign) NSUInteger     currentFlowCount;

@property (nonatomic, assign) BOOL           fetching;

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation HNNewFlowCountService

+ (instancetype)sharedInstance
{
    static HNNewFlowCountService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HNNewFlowCountService alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate
{
    if ( self = [super init] ) {
        self.canFetch = YES;
        
        self.newFlowCount = 0;
        self.currentFlowCount = 0;
        
        self.fetching     = NO;
        
        [self addObserver:self
               forKeyPath:@"newFlowCount"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(silentFetching) name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(silentFetching) name:@"kFlowHandleSuccessNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(silentFetching) name:@"kMarkFlowReadNotification" object:nil];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"该类为单例，不能使用init初始化对象");
    return self;
}

- (void)silentFetching
{
    [self startFetching:nil];
}

- (void)startFetching:(void (^)(void))completion
{
    if ( !self.canFetch ) return;
    
    if ( self.fetching ) return;
    
    self.fetching = YES;
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSDictionary *params =  @{
                              @"dotype": @"GetData",
                              @"funname": @"移动端流程未读查询",
                              @"param1": manID,      // man id
                              };
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:params completion:^(id result, NSError *error) {
         // 此处单例不考虑循环引用
         self.fetching = NO;
         if ( !error ) {
             id dict = [result[@"data"] firstObject];
             self.newFlowCount = [dict[@"total"] integerValue];
             
//             self.newFlowCount = [result[@"rowcount"] integerValue];
//             NSInteger count = [result[@"rowcount"] integerValue];
//             if ( self.currentFlowCount == 0 ) {
//                 self.currentFlowCount = count;
//                 self.newFlowCount = self.currentFlowCount;
//             } else {
//                 self.newFlowCount = count > self.currentFlowCount ? count - self.currentFlowCount : 0;
//                 self.currentFlowCount = count;
//             }
         }
     }];
}

// 清零
- (void)resetNewFlowCount
{    
//    self.newFlowCount = 0;
}

- (void)resetTotalFlowCount
{
//    self.currentFlowCount = 0;
}

- (void)registerObserver:(id)observer
{
    if ( [self.observers containsObject:observer] == NO ) {
        [self.observers addObject:observer];
    };
}

- (void)unregisterObserver:(id)observer
{
    [self.observers removeObject:observer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    for (id observer in self.observers) {
        if ( [observer isKindOfClass:[UITabBarItem class]] ) {
            UITabBarItem *tabBar = (UITabBarItem *)observer;
            if ( self.newFlowCount == 0 ) {
                tabBar.badgeValue = nil;
            } else {
                NSString *badgeValue = self.newFlowCount > 99 ? @"99+" : [@(self.newFlowCount) description];
                tabBar.badgeValue = badgeValue;
            }
        } else if ( [observer isKindOfClass:[HNBadge class]] ) {
            HNBadge *badge = (HNBadge *)observer;
            badge.badge = self.newFlowCount;
        }
    }
}

- (NSMutableArray *)observers
{
    if ( !_observers ) {
        _observers = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return _observers;
}

@end

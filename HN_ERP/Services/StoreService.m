//
//  StoreService.m
//  HN_ERP
//
//  Created by tomwey on 1/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "StoreService.h"

@implementation StoreService

+ (instancetype)sharedInstance
{
    static StoreService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[StoreService alloc] init];
    });
    return instance;
}

- (id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)saveObject:(id)object forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

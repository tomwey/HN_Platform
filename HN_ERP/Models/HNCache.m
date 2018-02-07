//
//  HNCache.m
//  HN_ERP
//
//  Created by tomwey on 2/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNCache.h"

@interface HNCache ()

@property (nonatomic, strong) NSCache *cache;

@end
@implementation HNCache

+ (instancetype)sharedInstance
{
    static HNCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HNCache alloc] __init];
    });
    return instance;
}

- (instancetype)__init
{
    if ( self = [super init] ) {
        self.cache = [[NSCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAllCaches) name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAllCaches)
                                                     name:@"kFlowHandleSuccessNotification"
                                                   object:nil];
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    return [self.cache objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    if ( object ) {
        [self.cache setObject:object forKey:key];
    } else {
        [self.cache removeObjectForKey:key];
    }
}

- (NSArray *)allCacheKeys
{
    return nil;
}

- (void)removeAllCaches
{
    [self.cache removeAllObjects];
}

- (void)removeCacheForKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

@end

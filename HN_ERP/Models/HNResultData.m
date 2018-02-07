//
//  HNResultData.m
//  HN_ERP
//
//  Created by tomwey on 2/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNResultData.h"

@implementation HNResultData

- (instancetype)init
{
    if ( self = [super init] ) {
        self.pageIndex = 0;
        self.tableOffset = CGPointZero;
        self.pageData = nil;
        self.latestData = nil;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"pageIndex: %d, tableOffset: %@",
            self.pageIndex,
            NSStringFromCGPoint(self.tableOffset)];
}

@end

@interface HNResultDataCache ()

@property (nonatomic, strong) NSCache *resultDataCache;

@end

@implementation HNResultDataCache

+ (instancetype)sharedInstance
{
    static HNResultDataCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HNResultDataCache alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate
{
    if ( self = [super init] ) {
        self.resultDataCache = [[NSCache alloc] init];
    }
    return self;
}

- (HNResultData *)resultDataForKey:(NSString *)key
{
    return [self.resultDataCache objectForKey:key];
}

- (void)cacheResultData:(HNResultData *)resultData forKey:(NSString *)key
{
    if ( resultData ) {
        [self.resultDataCache setObject:resultData forKey:key];
    } else {
        [self.resultDataCache removeObjectForKey:key];
    }
}

- (void)removeAllCaches
{
    [self.resultDataCache removeAllObjects];
}

- (void)removeResultDataForKey:(NSString *)key
{
    [self.resultDataCache removeObjectForKey:key];
}

@end

//
//  HNResultData.h
//  HN_ERP
//
//  Created by tomwey on 2/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNResultData : NSObject

/** 当前表视图的最新位置 */
@property (nonatomic, assign) CGPoint tableOffset;

/** 当前分页id */
@property (nonatomic, assign) NSInteger pageIndex;

/** 当前页的数据集 */
@property (nonatomic, strong) NSArray *pageData;

/** 最新的总数据集 */
@property (nonatomic, strong) NSArray *latestData;

@end

@interface HNResultDataCache : NSObject

+ (instancetype)sharedInstance;

- (HNResultData *)resultDataForKey:(NSString *)key;

- (void)cacheResultData:(HNResultData *)resultData forKey:(NSString *)key;

- (void)removeAllCaches;

- (void)removeResultDataForKey:(NSString *)key;

@end

static inline void HNResultDataSaveCache(HNResultData *resultData, NSString *key) {
    [[HNResultDataCache sharedInstance] cacheResultData:resultData forKey:key];
};

static inline HNResultData *HNResultDataForKey(NSString *key) {
    return [[HNResultDataCache sharedInstance] resultDataForKey:key];
};

static inline void HNResultDataRemoveForKey(NSString *key) {
    [[HNResultDataCache sharedInstance] removeResultDataForKey:key];
};

static inline void HNResultDataRemoveAllCaches() {
    [[HNResultDataCache sharedInstance] removeAllCaches];
};

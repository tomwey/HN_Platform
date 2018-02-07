//
//  HNCache.h
//  HN_ERP
//
//  Created by tomwey on 2/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNCache : NSObject

+ (instancetype)sharedInstance;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;

- (NSArray *)allCacheKeys;

- (void)removeAllCaches;
- (void)removeCacheForKey:(NSString *)key;

@end

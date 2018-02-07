//
//  StoreService.h
//  HN_ERP
//
//  Created by tomwey on 1/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreService : NSObject

+ (instancetype)sharedInstance;

- (id)objectForKey:(NSString *)key;

- (void)saveObject:(id)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end

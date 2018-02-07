//
//  RTIDataService.h
//  RTA
//
//  Created by tangwei1 on 16/10/25.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTIDataService : NSObject

- (NSUInteger)GET:(NSString *)uri
     params:(NSDictionary *)params
 completion:(void (^)(id result, NSError *error))completion;

- (NSUInteger)POST:(NSString *)uri
            params:(NSDictionary *)params
        completion:(void (^)(id result, NSError *error))completion;

- (NSUInteger)POST2:(NSString *)uri
            params:(NSDictionary *)params
        completion:(void (^)(id result, NSError *error))completion;

- (void)cancelAllRequests;

- (void)cancelRequestForTaskId:(NSUInteger)taskId;

@end

//
//  RTIDataService.h
//  RTA
//
//  Created by tangwei1 on 16/10/25.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIServiceConfig : NSObject

+ (instancetype)defaultConfig;

@property (nonatomic, copy) NSString *apiServer;

@end

@protocol APIServiceProtocol <NSObject>

@property (nonatomic, strong) APIServiceConfig *apiConfig;

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

@interface APIService : NSObject <APIServiceProtocol>

@property (nonatomic, strong) APIServiceConfig *apiConfig;

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

@interface NSObject (APIServiceCreator)

- (id <APIServiceProtocol>)apiServiceWithName:(NSString *)apiServiceName;

@end

//
//  NetworkService.h
//  deyi
//
//  Created by tomwey on 9/4/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkService : NSObject

- (void)GET:(NSString *)uri
     params:(NSDictionary *)params
 completion:(void (^)(id result, NSError *error))completion;

- (void)POST:(NSString *)uri
      params:(NSDictionary *)params
  completion:(void (^)(id result, NSError *error))completion;

@end

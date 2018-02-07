//
//  SysLogService.h
//  HN_ERP
//
//  Created by tomwey on 05/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysLogService : NSObject

+ (instancetype)sharedInstance;

- (void)logType:(NSInteger)type
          keyID:(NSInteger)keyID
        keyName:(NSString *)keyName
        keyMemo:(NSString *)memo;

- (void)logForLogin;

- (void)logForUserLogin;

@end

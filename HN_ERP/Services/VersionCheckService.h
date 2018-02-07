//
//  VersionCheckerService.h
//  RTA
//
//  Created by tangwei1 on 16/10/26.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionCheckService : NSObject

+ (instancetype)sharedInstance;

- (void)startCheckWithSilent:(BOOL)isSilent;

@property (nonatomic, strong, readonly) id appInfo;

@end

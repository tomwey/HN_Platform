//
//  SysLogService.m
//  HN_ERP
//
//  Created by tomwey on 05/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "SysLogService.h"
#import "Defines.h"

@interface SysLogService()

@property (nonatomic, strong) NSDateFormatter *dateFormater;

@end

@implementation SysLogService

+ (instancetype)sharedInstance
{
    static SysLogService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SysLogService alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(appResume)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    });
    return instance;
}

- (NSDateFormatter *)dateFormater
{
    if ( !_dateFormater ) {
        _dateFormater = [[NSDateFormatter alloc] init];
        _dateFormater.dateFormat = @"yyyyMMdd";
    }
    return _dateFormater;
}

- (void)logForLogin
{
    NSString *loginDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginDate"];
    
    NSString *now = [self.dateFormater stringFromDate:[NSDate date]];
    if ( loginDate && [loginDate isEqualToString:now] ) {
        return;
    }
    
    [self appResume];
}

- (void)logForUserLogin
{
    [self appResume];
}

- (void)appResume
{
    AFNetworkReachabilityStatus status = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    NSString *network = @"unknown";
    if ( status == AFNetworkReachabilityStatusReachableViaWWAN ) {
        network = @"4g";
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        network = @"wifi";
    }
    
    NSString *memo = [NSString stringWithFormat:@"%@,iOS %@,%@",
                      AWDevicePlatformString(),AWOSVersionString(), network];
    [self logType:10 keyID:0 keyName:nil keyMemo:memo];
}

- (void)logType:(NSInteger)type
          keyID:(NSInteger)keyID
        keyName:(NSString *)keyName
        keyMemo:(NSString *)memo
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"记录系统日志APP",
              @"param1": manID,
              @"param2": [@(type) description],
              @"param3": [@(keyID) description],
              @"param4": keyName ?: @"",
              @"param5": memo ?: @"",
              @"param6": @"1",
              } completion:^(id result, NSError *error) {
                  if ( type == 10 ) { // 一天只能统计一次登录
                      [[NSUserDefaults standardUserDefaults] setObject:[self.dateFormater stringFromDate:[NSDate date]] forKey:@"loginDate"];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                  }
              }];
}

@end

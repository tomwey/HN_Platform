//
//  UserService.m
//  deyi
//
//  Created by tomwey on 9/5/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "UserService.h"
#import "User.h"
#import "NSObject+RTIDataService.h"
#import "NetworkService.h"
#import "StoreService.h"
#import <CloudPushSDK/CloudPushSDK.h>

@interface UserService ()

// 用于登录,注册,获取个人信息相关
@property (nonatomic, strong) NetworkService *socialService;

// 用于修改密码，修改个人资料
@property (nonatomic, strong) NetworkService *updateService;

@property (nonatomic, strong) User *user;

@end

@implementation UserService

+ (UserService *)sharedInstance
{
    static UserService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[UserService alloc] init];
        }
    });
    return instance;
}

/**
 * 获取当前登录的用户，如果存在表示登录成功
 */
- (id)currentUser
{
//    self.user = [[User alloc] initWithDictionary:@{@"mobile": @"13312345677"}];
    
//    User *user = self.user ?: [self userFromDetached];
//#if DEBUG
//    NSLog(@"uid: %@, token: %@, name: %@, sex: %@, birth: %@", user.name, user.token, user.name, user.sex, user.birthday);
//#endif
//    return user;
    return [[StoreService sharedInstance] objectForKey:@"logined.user"];
}

- (NSString *)currentUserAuthToken
{
    return [[self currentUser] token] ?: @"";
}

/**
 * 注册
 */
- (void)signupWithMobile:(NSString *)mobile
                password:(NSString *)password
                    code:(NSString *)code
              inviteCode:(NSString *)inviteCode
              completion:(void (^)(User *aUser, NSError *error))completion
{
    [self.socialService POST:@"/account/signup"
                      params:@{ @"mobile" : mobile ?: @"",
                                @"password" : password ?: @"",
                                @"code": code ?: @"",
                                @"invite_code": inviteCode ?: @""
                                }
                  completion:^(id result, NSError *inError)
    {
                      
        [self handleResult:result error:inError completion:completion];
    }];
}

/**
 * 登录
 */
- (void)loginWithMobile:(NSString *)mobile
               password:(NSString *)password
             completion:(void (^)(User *aUser, NSError *error))completion
{
    [self.dataService   POST:@"UserLogin"
                      params:@{ @"loginname": mobile ?: @"",
                                @"pwd": password ?: @""
                                }
                  completion:^(id result, NSError *inError)
     {
         [self handleResult:result error:inError completion:completion];
     }];
}

/**
 * 获取用户个人资料
 */
- (void)loadUserProfile:(NSString *)token
             completion:(void (^)(User *aUser, NSError *error))completion
{
    [self.socialService GET:@"/user/me"
                     params:@{
                              @"token" : token ?: @""
                              }
                 completion:^(id result, NSError *error)
    {
        [self handleResult:result error:error completion:completion];
    }];
}

- (void)updateUserProfile:(NSDictionary *)params completion:(void (^)(User *aUser, NSError *error))completion
{
    NSMutableDictionary *newParam = [params mutableCopy];
//    [newParam setObject:[self currentUser].token forKey:@"userid"];
    
    if ( [newParam[@"key"] isEqualToString:@"birthday"] ) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
        [newParam setObject:[df stringFromDate:[params objectForKey:@"value"]] forKey:@"value"];
    }
    
    [self.dataService POST:@"UpdateUserInfo" params:newParam completion:^(id result, NSError *error) {
//        NSLog(@"");
        if ( completion ) {
            if ( error ) {
                completion(nil, error);
            } else {
                
                User *user = [self currentUser];
                if ( [params[@"key"] isEqualToString:@"username"] ) {
                    [user updateName:[params[@"value"] description]];
                }
                
                if ( [params[@"key"] isEqualToString:@"sex"] ) {
                    [user updateSex:params[@"value"]];
                }
                
                if ( [params[@"key"] isEqualToString:@"birthday"] ) {
                    [user updateBirth:params[@"value"]];
                }
                
                [self saveUser:user];
                
                completion(user, nil);
            }
        }
    }];
}

- (void)updateAvatar:(NSDictionary *)params
          completion:(void (^)(User *aUser, NSError *error))completion
{
//    [self.dataService POST2:@"UploadPic"
//                     params:@{ @"userid": [self currentUser].token ?: @"",
//                               @"imgstream": params[@"image"]
//                               }
//                 completion:^(id result, NSError *error) {
//                     if ( !error ) {
//                         User *user = [self currentUser];
//                         [user updateAvatar:result[@"imgurl"]];
//                         [self saveUser:user];
//                         
//                         if ( completion ) {
//                             completion(user, nil);
//                         }
//                     } else {
//                         if ( completion ) {
//                             completion(nil, error);
//                         }
//                     }
//                 }];
}

- (void)logout:(void (^)(id result, NSError *error))completion
{
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        
    }];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"logined.user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.user = nil;
    
    if ( completion ) {
        completion(@{}, nil);
    }
}

- (NetworkService *)socialService
{
    if ( !_socialService ) {
        _socialService = [[NetworkService alloc] init];
    }
    return _socialService;
}

- (NetworkService *)updateService
{
    if ( !_updateService ) {
        _updateService = [[NetworkService alloc] init];
    }
    return _updateService;
}

- (void)handleResult:(id)result
               error:(NSError *)inError
          completion:(void (^)(User *aUser, NSError *error))completion
{
    if ( inError ) {
        if ( completion ) {
            completion(nil, inError);
        }
    } else {
        User *user = [[User alloc] initWithDictionary:result];
        [self saveUser:user];
        if ( completion ) {
            completion(user, nil);
        }
    }
}

- (void)saveUser:(id)aUser
{
//    self.user = aUser;
    [[StoreService sharedInstance] saveObject:aUser forKey:@"logined.user"];
    
    [CloudPushSDK addAlias:[aUser[@"man_id"] description]
              withCallback:^(CloudPushCallbackResult *res) {
//        NSLog(@"res: %@", res);
                  if ( res.success ) {
                      
                  } else {
                      NSLog(@"res: %@", res.error);
                  }
    }];
    
    [CloudPushSDK bindAccount:[aUser[@"man_id"] description]
                 withCallback:^(CloudPushCallbackResult *res) {
                     if ( res.success ) {
                         
                     } else {
                         NSLog(@"res: %@", res.error);
                     }
    }];
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aUser];
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"logined.user"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (User *)userFromDetached
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"logined.user"];
    if ( !obj ) {
        return nil;
    }
    
    User *aUser = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
    self.user = aUser;
    return aUser;
}

@end

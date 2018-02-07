//
//  UserService.h
//  deyi
//
//  Created by tomwey on 9/5/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface UserService : NSObject

+ (UserService *)sharedInstance;

/**
 * 获取当前登录的用户，如果存在表示登录成功
 */
//"corp_id" = 1679537;
//"corp_name" = "\U96c6\U56e2\U603b\U90e8";
//"dept_id" = 1685034;
//"dept_name" = "\U57fa\U7840\U67b6\U6784\U7ec4";
//"man_id" = 286;
//"man_name" = "\U5f20\U4e39";
//safelevel = 50;
//"station_id" = 2126917;
//"station_name" = "\U57fa\U7840\U67b6\U6784\U9ad8\U7ea7\U4e13\U4e1a\U7ecf\U7406";
- (id)currentUser;

- (void)saveUser: (id)aUser;

/**
 * 获取当前用户认证Token
 */
- (NSString *)currentUserAuthToken;

/**
 * 注册
 */
- (void)signupWithMobile:(NSString *)mobile
                password:(NSString *)password
                    code:(NSString *)code
              inviteCode:(NSString *)inviteCode
              completion:(void (^)(User *aUser, NSError *error))completion;

/**
 * 登录
 */
- (void)loginWithMobile:(NSString *)mobile
               password:(NSString *)password
             completion:(void (^)(User *aUser, NSError *error))completion;

/**
 * 获取用户个人资料
 */
- (void)loadUserProfile:(NSString *)token
             completion:(void (^)(User *aUser, NSError *error))completion;

/**
 * 修改密码
 */

/**
 * 退出登录
 */
- (void)logout:(void (^)(id result, NSError *error))completion;

- (void)updateUserProfile:(NSDictionary *)params
               completion:(void (^)(User *aUser, NSError *error))completion;

- (void)updateAvatar:(NSDictionary *)params
          completion:(void (^)(User *aUser, NSError *error))completion;

@end

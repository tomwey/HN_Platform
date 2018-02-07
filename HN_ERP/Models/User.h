//
//  User.h
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *mobile;
@property (nonatomic, copy, readonly) NSString *avatar;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDate   *birthday;
@property (nonatomic, copy, readonly) NSNumber *sex;

@property (nonatomic, copy, readonly) NSString *token;

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult;

- (void)updateName:(NSString *)name;

- (void)updateBirth:(NSDate *)birth;

- (void)updateAvatar:(NSString *)avatar;

- (void)updateSex:(NSNumber *)sex;

@end

@interface User (Deco)

- (NSString *)nickname;
- (NSString *)formatBirth;
- (NSString *)formatSex;
- (NSString *)formatUsername;

- (BOOL)validateMobile;

@end

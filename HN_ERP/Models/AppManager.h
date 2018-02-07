//
//  AppManager.h
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddContactsModel;

@interface AppManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSArray *selectedPeople;

@property (nonatomic, strong) NSArray *breadcrumbs;

@property (nonatomic, strong) AddContactsModel *currentContactsModel;

/** 存储用户的操作权限 */
@property (nonatomic, strong, readonly) NSDictionary *manAbilities;

- (void)removeAllAbilities;

- (void)addAbility:(id)ability forKey:(NSString *)key;

@end

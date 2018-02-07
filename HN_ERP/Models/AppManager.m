//
//  AppManager.m
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AppManager.h"
#import "AddContactsModel.h"

@interface AppManager ()

//@property (nonatomic, strong) NSMutableArray *_selectedPeople;

@property (nonatomic, strong) NSMutableDictionary *abilities;

@end

@implementation AppManager

+ (instancetype)sharedInstance
{
    static AppManager* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[AppManager alloc] init];
        }
    });
    return instance;
}

- (void)removeAllAbilities
{
    [self.abilities removeAllObjects];
}

- (void)addAbility:(id)ability forKey:(NSString *)key
{
    NSMutableArray *val = self.abilities[key];
    if ( !val ) {
        val = [[NSMutableArray alloc] init];
        self.abilities[key] = val;
    }
    
    NSInteger count = 0;
    for (id obj in val) {
        if ( [obj[@"pi_name"] isEqualToString:ability[@"pi_name"]] ) {
            count++;
        }
    }
    
    if (count == 0) {
        [val addObject:ability];
    }
}

- (NSMutableDictionary *)abilities
{
    if ( !_abilities ) {
        _abilities = [[NSMutableDictionary alloc] init];
    }
    return _abilities;
}

- (NSDictionary *)manAbilities
{
    return [self.abilities copy];
}

@end

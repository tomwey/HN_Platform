//
//  ContactInsertHistoryTable.m
//  HN_ERP
//
//  Created by tomwey on 2/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContactInsertHistoryTable.h"
#import "ContactInsertHistory.h"

@implementation ContactInsertHistoryTable

- (NSString *)databaseName
{
    return @"db.sqlite";
}

- (NSString *)tableName
{
    return @"contacts";
}

- (NSDictionary *)columnInfo
{
    return @{
             @"_id": @"INTEGER PRIMARY KEY AUTOINCREMENT",
             @"mobile": @"TEXT",
             @"personID": @"INTEGER"
             };
}

- (Class)recordClass
{
    return [ContactInsertHistory class];
}

- (NSString *)primaryKeyName
{
    return @"_id";
}

@end

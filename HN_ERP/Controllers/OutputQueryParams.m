//
//  OutputQueryParams.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputQueryParams.h"
#import "UserService.h"

@implementation OutputQueryParams

- (instancetype)init
{
    if ( self = [super init] ) {
        self.queryType = @"1";
        self.projID = @"";
        
        id user = [[UserService sharedInstance] currentUser];
        NSString *manID = [user[@"man_id"] description];
        manID = manID ?: @"0";
        self.manID = manID;
        
        self.catalogID = @"0";
        
        self.where = @"";
        
        self.isFeeType = @"1";
    }
    return self;
}

- (NSString *)year
{
    if ( !_year ) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSInteger n = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
        
        _year = [@(n) description];
    }
    return _year;
}

- (NSString *)month
{
    if ( !_month ) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSInteger n = [calendar component:NSCalendarUnitMonth fromDate:[NSDate date]];
        
        _month = [@(n) description];
    }
    return _month;
}

@end

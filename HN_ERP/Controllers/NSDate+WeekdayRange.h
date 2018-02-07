//
//  NSDate+WeekdayRange.h
//  HN_ERP
//
//  Created by tomwey on 7/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WeekdayRange)

- (NSDate*)firstDayOfWeek;

- (NSDate*)lastDayOfWeek;

@end

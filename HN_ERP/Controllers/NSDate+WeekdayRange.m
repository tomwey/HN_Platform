//
//  NSDate+WeekdayRange.m
//  HN_ERP
//
//  Created by tomwey on 7/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NSDate+WeekdayRange.h"

@implementation NSDate (WeekdayRange)

- (NSDate*)firstDayOfWeek
{
    NSCalendar* cal = [[NSCalendar currentCalendar] copy];
    [cal setFirstWeekday:2]; //Override locale to make week start on Monday
    NSDate* startOfTheWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfTheWeek interval:&interval forDate:self];
    return startOfTheWeek;
}

- (NSDate*)lastDayOfWeek
{
    NSCalendar* cal = [[NSCalendar currentCalendar] copy];
    [cal setFirstWeekday:2]; //Override locale to make week start on Monday
    NSDate* startOfTheWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfTheWeek interval:&interval forDate:self];
    return [startOfTheWeek dateByAddingTimeInterval:interval - 1];
}

@end

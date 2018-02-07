//
//  MeetingDateRange.h
//  HN_ERP
//
//  Created by tomwey on 7/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingDateRange : UIView

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, assign) CGFloat arrowButtonMargin;

@property (nonatomic, assign, readonly) BOOL isThisWeek;
@property (nonatomic, assign, readonly) BOOL isLastWeek;
@property (nonatomic, assign, readonly) BOOL isNextWeek;

@property (nonatomic, copy) void (^changeBlock)(MeetingDateRange *sender, NSInteger weekOfYear, NSString *firstDate, NSString *lastDate);

@end

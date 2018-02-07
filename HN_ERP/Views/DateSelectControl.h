//
//  DateSelectControl.h
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DateControlMode) {
    DateControlModeDate,
    DateControlModeYearMonth,
    DateControlModeYear,
    DateControlModeDatetime, // 未实现
};

@interface DateSelectControl : UIView

// Defaults is DateControlModeDate
@property (nonatomic, assign) DateControlMode controlMode;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, copy, readonly) NSString *currentDateString;

@property (nonatomic, copy) void (^openDatePickerBlock)(DateSelectControl *sender);

@property (nonatomic, copy) void (^currentDateDidChangeBlock)(DateSelectControl *sender);

@end

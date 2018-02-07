//
//  DatePicker.h
//  HN_ERP
//
//  Created by tomwey on 1/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DatePickerMode) {
    DatePickerModeDate = 0,
    DatePickerModeTime = 1,
    DatePickerModeDateTime = 2,
};

@interface DatePicker : UIView

@property (nonatomic, strong) NSDate *currentSelectedDate;

@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, assign) NSInteger minuteInterval;

// 默认为日期
@property (nonatomic, assign) DatePickerMode pickerMode;

@property (nonatomic, copy) void (^didSelectDateBlock)(DatePicker *sender, id selectedDate);

- (void)showPickerInView:(UIView *)superView;

@end

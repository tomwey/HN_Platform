//
//  YearMonthPickerView.h
//  HN_ERP
//
//  Created by tomwey on 5/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YearMonthPickerView : UIView

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, copy) void (^doneCallback)(YearMonthPickerView *sender);

- (void)showInView:(UIView *)superView;

@end

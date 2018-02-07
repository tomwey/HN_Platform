//
//  SelectPicker.h
//  HN_ERP
//
//  Created by tomwey on 1/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectPicker : UIView

- (instancetype)initWithOptions:(NSArray *)options;

@property (nonatomic, strong) NSArray *options;

@property (nonatomic, strong) id currentSelectedOption;

@property (nonatomic, copy) void (^didSelectOptionBlock)(SelectPicker *sender, id selectedOption, NSInteger selectedIdx);

- (void)showPickerInView:(UIView *)superView;

- (void)dismiss;

@end

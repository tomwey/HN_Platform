//
//  RadioButton.h
//  HN_ERP
//
//  Created by tomwey on 4/21/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RadioButton;
@interface RadioButtonGroup : UIView

- (instancetype)initWithRadioButtons:(NSArray *)buttons;

@property (nonatomic, strong) NSArray *radioButtons;

@property (nonatomic, strong) id value;

@end

@interface RadioButton : UIView

- (instancetype)initWithIcon:(UIImage *)icon
                selectedIcon:(UIImage *)selectedIcon
                       label:(NSString *)label
                       value:(id)value;

@property (nonatomic, assign) BOOL checked;

@property (nonatomic, strong) id value;
@property (nonatomic, copy)   NSString *label;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;

@property (nonatomic, weak) RadioButtonGroup *group;

@property (nonatomic, copy) void (^didSelectBlock)(RadioButton *sender);

@end



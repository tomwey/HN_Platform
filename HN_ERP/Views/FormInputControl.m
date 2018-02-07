//
//  FormInputControl.m
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FormInputControl.h"

@interface FormInputControl ()

@property (nonatomic, strong) UILabel *labelLabel;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation FormInputControl

- (instancetype)initWithLabel:(NSString *)label name:(NSString *)name placeholder:(NSString *)placeholder value:(NSString *)value
{
    if ( self = [super initWithLabel:label name:name placeholder:placeholder] ) {
        self.value = value;
    }
    return self;
}

- (void)setLabel:(NSString *)name
{
    self.labelLabel.text = name;
}

- (NSString *)label { return self.labelLabel.text; }

- (void)setPlaceholder:(NSString *)placeholder
{
    self.textField.placeholder = placeholder;
}

- (NSString *)placeholder { return self.textField.placeholder; }

@end

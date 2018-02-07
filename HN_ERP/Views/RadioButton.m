//
//  RadioButton.m
//  HN_ERP
//
//  Created by tomwey on 4/21/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "RadioButton.h"
#import "Defines.h"

@interface RadioButtonGroup ()

@end

@implementation RadioButtonGroup

- (instancetype)initWithRadioButtons:(NSArray *)buttons
{
    if ( self = [super init] ) {
        self.radioButtons = buttons;
    }
    return self;
}

- (void)setRadioButtons:(NSArray *)radioButtons
{
    if ( _radioButtons != radioButtons ) {
        _radioButtons = radioButtons;
        
        for (RadioButton *rb in radioButtons) {
            [self addSubview:rb];
            rb.group = self;
            if ( [[rb.value description] isEqualToString:[self.value description]] ) {
                rb.checked = YES;
            } else {
                rb.checked = NO;
            }
        }
        
        [self setNeedsLayout];
    }
}

- (void)setValue:(id)value
{
    if (_value != value) {
        _value = value;
        
        for (RadioButton *rb in self.radioButtons) {
            if ( [[rb.value description] isEqualToString:[self.value description]] ) {
                rb.checked = YES;
            } else {
                rb.checked = NO;
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = 0;
    for (RadioButton *rb in self.radioButtons) {
        rb.position = CGPointMake(left, self.height / 2 - rb.height / 2);
        left = rb.right + 10;
    }
}

@end

////////////////////////////////////////////////////////////////////
@interface RadioButton ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *labelLabel;

@end

@implementation RadioButton

- (instancetype)initWithIcon:(UIImage *)icon
                selectedIcon:(UIImage *)selectedIcon
                       label:(NSString *)label
                       value:(id)value
{
    if ( self = [super init] ) {
        
        self.frame = CGRectMake(0, 0, 40, 40);
        
        _checked = NO;
        
        self.icon = icon;
        self.selectedIcon = selectedIcon;
        
        self.label = label;
        
        self.value = value;
        
        [self addGestureRecognizer:
         [[UITapGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(tap)]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.center = CGPointMake(self.iconView.width / 2,
                                       self.height / 2);
    
    if ( self.label ) {
        self.labelLabel.center = CGPointMake(self.iconView.right + 10 + self.labelLabel.width / 2,
                                             self.height / 2);
    }
}

- (void)tap
{
    for (RadioButton *rb in self.group.radioButtons) {
        rb.checked = NO;
    }
    
    self.checked = YES;
    self.group.value = self.value;
    
    if (self.didSelectBlock) {
        self.didSelectBlock(self);
    }
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    
    [self layoutUI];
}

- (void)layoutUI
{
    if ( self.checked ) {
        self.iconView.image = self.selectedIcon;
    } else {
        self.iconView.image = self.icon;
    }
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    
    self.labelLabel.text = label;
    
    [self.labelLabel sizeToFit];
    
    self.width = 40 + self.labelLabel.width;
}

- (void)setIcon:(UIImage *)icon
{
    _icon = icon;
    
    [self layoutUI];
}

- (void)setSelectedIcon:(UIImage *)icon
{
    _selectedIcon = icon;
    
    [self layoutUI];
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        _iconView.frame = CGRectMake(0, 0, 20, 20);
        [self addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)labelLabel
{
    if ( !_labelLabel ) {
        _labelLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    nil,
                                    [UIColor blackColor]);
        [self addSubview:_labelLabel];
    }
    return _labelLabel;
}

@end

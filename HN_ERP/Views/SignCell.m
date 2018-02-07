//
//  SignCell.m
//  HN_ERP
//
//  Created by tomwey on 3/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SignCell.h"
#import "Defines.h"

@interface DigitControl : UIView

@property (nonatomic, assign) NSInteger value;

// 默认为0
@property (nonatomic, assign) NSInteger minValue;

// 默认为1000
@property (nonatomic, assign) NSInteger maxValue;

- (void)hideKeyboard;

@end

@interface SignCell ()

@property (nonatomic, strong) UIButton     *checkboxBtn;

@property (nonatomic, strong) UILabel      *nameLabel;

@property (nonatomic, strong) DigitControl *digitControl;

@property (nonatomic, strong) UILabel      *sortLabel; // 顺序号

@end

@implementation SignCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.checkboxBtn.position = CGPointMake(5, self.height / 2 - self.checkboxBtn.height / 2);
    
    self.nameLabel.frame = CGRectMake(self.checkboxBtn.right, self.height / 2 - 34 / 2,
                                      60,
                                      34);
    
    self.digitControl.position =
        CGPointMake(self.width - 15 - self.digitControl.width,
                    self.height / 2 - self.digitControl.height / 2);
    
    self.sortLabel.frame = self.nameLabel.frame;
    self.sortLabel.left  = self.digitControl.left - self.sortLabel.width;
}

- (void)hideKeyboard
{
    [self.digitControl hideKeyboard];
}

- (void)setSignData:(SignData *)signData
{
    if ( _signData != signData ) {
        _signData = signData;
        
        self.nameLabel.text = signData.name;
        self.sortLabel.text = @"顺序号:";
    }
    
    if ( signData.checked ) {
        [self.checkboxBtn setImage:[UIImage imageNamed:@"icon_checkbox_click.png"] forState:UIControlStateNormal];
    } else {
        [self.checkboxBtn setImage:[UIImage imageNamed:@"icon_checkbox.png"] forState:UIControlStateNormal];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == self.digitControl && [keyPath isEqualToString:@"value"] ) {
        self.signData.sort = self.digitControl.value;
    }
}

- (void)dealloc
{
    [self.digitControl removeObserver:self forKeyPath:@"value"];
}

- (UIButton *)checkboxBtn
{
    if ( !_checkboxBtn ) {
        _checkboxBtn = AWCreateImageButtonWithSize(@"icon_checkbox.png", CGSizeMake(40, 40), self, @selector(doCheck:));
        [self.contentView addSubview:_checkboxBtn];
    }
    return _checkboxBtn;
}

- (void)doCheck:(UIButton *)sender
{
    self.signData.checked = !self.signData.checked;
    
    if ( self.signData.checked ) {
        [self.checkboxBtn setImage:[UIImage imageNamed:@"icon_checkbox_click.png"] forState:UIControlStateNormal];
    } else {
        [self.checkboxBtn setImage:[UIImage imageNamed:@"icon_checkbox.png"] forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCheckboxDidSelectNotification" object:self.signData];
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(15, NO),
                                   [UIColor blackColor]);
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (DigitControl *)digitControl
{
    if ( !_digitControl ) {
        _digitControl = [[DigitControl alloc] init];
        [_digitControl addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        [self.contentView addSubview:_digitControl];
    }
    return _digitControl;
}

- (UILabel *)sortLabel
{
    if ( !_sortLabel ) {
        _sortLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(115, 123, 135));
        [self.contentView addSubview:_sortLabel];
    }
    return _sortLabel;
}

@end

@interface DigitControl () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *inputField;

@end

@implementation DigitControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = CGRectMake(0, 0, 128, 34);
        
        _minValue = 0;
        _maxValue = 1000;
        
//        self.layer.cornerRadius = 6;
//        self.layer.borderColor  = AWColorFromRGB(201, 201, 201).CGColor;
//        self.layer.borderWidth  = 0.5;
//        self.clipsToBounds      = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *decreaseBtn = AWCreateTextButton(
                                                   CGRectMake(0, 0, 40, self.height),
                                                   @"－",
                                                   [UIColor blackColor],
                                                   self,
                                                   @selector(decrease));
        [self addSubview:decreaseBtn];
        
        decreaseBtn.layer.borderColor = AWColorFromRGB(201, 201, 201).CGColor;
        decreaseBtn.layer.borderWidth = 0.5;
        decreaseBtn.backgroundColor = [UIColor whiteColor];
        
        UIButton *increaseBtn = AWCreateTextButton(
                                                   CGRectMake(0, 0, 40, self.height),
                                                   @"＋",
                                                   [UIColor blackColor],
                                                   self,
                                                   @selector(increase));
        [self addSubview:increaseBtn];
        increaseBtn.left = self.width - increaseBtn.width;
        
        increaseBtn.layer.borderColor = AWColorFromRGB(201, 201, 201).CGColor;
        increaseBtn.layer.borderWidth = 0.5;
        
        increaseBtn.backgroundColor = [UIColor whiteColor];
        
        UITextField *inputField =
        [[UITextField alloc] initWithFrame:CGRectMake(decreaseBtn.right - 1,
                                                      0,
                                                      increaseBtn.left - decreaseBtn.right + 2,
                                                      self.height)];
        inputField.textAlignment = NSTextAlignmentCenter;
        inputField.font = AWSystemFontWithSize(14, NO);
        inputField.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:inputField];
        inputField.textColor = [UIColor blackColor];
        
        inputField.layer.borderColor = AWColorFromRGB(201, 201, 201).CGColor;
        inputField.layer.borderWidth = 0.5;
        
        [inputField addTarget:self
                       action:@selector(valueChanged:)
             forControlEvents:UIControlEventEditingChanged];
        
        [self sendSubviewToBack:inputField];
        
        self.inputField = inputField;
        
        self.value = 0;
    }
    return self;
}

- (void)hideKeyboard
{
    [self.inputField resignFirstResponder];
}

- (void)valueChanged:(UITextField *)sender
{
    self.value = [self.inputField.text integerValue];
}

- (void)decrease
{
    NSInteger val = self.value - 1;
    if ( val < self.minValue ) {
        val = self.minValue;
    }
    
    self.value = val;
}

- (void)increase
{
    NSInteger val = self.value + 1;
    if ( val > self.maxValue ) {
        val = self.maxValue;
    }
    
    self.value = val;
}

- (void)setValue:(NSInteger)value
{
    if ( value >= self.minValue && value < self.maxValue ) {
        _value = value;
        self.inputField.text = [@(value) description];
    } else {
        self.inputField.text = [self.inputField.text substringToIndex:self.inputField.text.length - 1];
    }
    
}

@end

@implementation SignData

- (instancetype)initWithName:(NSString *)name ID:(NSString *)ID sort:(NSInteger)sort
{
    if ( self = [super init] ) {
        self.name = name;
        self.ID = ID;
        self.sort = sort;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[SignData class]] && [self.ID isEqualToString:[object ID]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, ID: %@, sort: %d",
            self.name, self.ID, self.sort];
}

@end

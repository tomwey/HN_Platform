//
//  KeyboardManager.m
//  deyi
//
//  Created by tomwey on 9/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "AWKeyboardManager.h"

@interface AWKeyboardManager ()

@property (nonatomic, assign) CGFloat extraOffset;
@property (nonatomic, weak) UITextField *activeField;
@property (nonatomic, weak) UITextField *lastField;

@property (nonatomic, strong) NSMutableArray *textFields;

@property (nonatomic, strong) UITapGestureRecognizer *hideGesture;

@end

@implementation AWKeyboardManager

+ (AWKeyboardManager *)sharedInstance
{
    static AWKeyboardManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[AWKeyboardManager alloc] init];
        }
    });
    return instance;
}

- (void)registerKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)setAutoScrollUITextFieldsContainer:(UIScrollView *)autoScrollUITextFieldsContainer
{
    _autoScrollUITextFieldsContainer = autoScrollUITextFieldsContainer;
    
    if ( !self.hideGesture ) {
        self.hideGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(hideKeyboard)];
    }
    
    [_autoScrollUITextFieldsContainer removeGestureRecognizer:self.hideGesture];
    [_autoScrollUITextFieldsContainer addGestureRecognizer:self.hideGesture];
}

- (void)unregisterKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    NSAssert(!!self.autoScrollUITextFieldsContainer, @"必须指定autoScrollUITextFieldsContainer属性");
    
    CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationOptions = [noti.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    CGRect activeFieldFrame = [window convertRect:self.activeField.frame
                                         fromView:self.autoScrollUITextFieldsContainer];
    
    self.autoScrollUITextFieldsContainer.contentInset          =
    self.autoScrollUITextFieldsContainer.scrollIndicatorInsets =
        UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0);
    
    CGFloat dty = CGRectGetMaxY(activeFieldFrame) - CGRectGetMinY(keyboardFrame);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
         if ( self.activeField == self.lastField ) {
             CGFloat delta = dty > 0 ? dty : 0;
             self.autoScrollUITextFieldsContainer.contentOffset = CGPointMake(0, self.extraOffset + delta);
         } else {
             CGFloat offsetY = dty > 0 ? dty : 0;
             self.autoScrollUITextFieldsContainer.contentOffset = CGPointMake(0, offsetY);
         }
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationOptions = [noti.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
         self.autoScrollUITextFieldsContainer.contentInset          =
         self.autoScrollUITextFieldsContainer.scrollIndicatorInsets = UIEdgeInsetsZero;
         self.autoScrollUITextFieldsContainer.contentOffset = CGPointZero;
     } completion:nil];
}

/**
 * 添加需要自动滚动的输入框
 */
- (void)addAutoScrollUITextFields:(NSArray *)textFields
{
    for (UITextField *field in textFields) {
        [field addTarget:self
                  action:@selector(textFieldBeginEdit:)
        forControlEvents:UIControlEventEditingDidBegin];
        
        if ( ![self.textFields containsObject:field] ) {
            [self.textFields addObject:field];
        }
    }
}

- (void)removeAutoScrollUITextFields:(NSArray *)textFields
{
    for (UITextField *field in textFields) {
        [field removeTarget:self
                     action:@selector(textFieldBeginEdit:)
           forControlEvents:UIControlEventEditingDidBegin];
        
        [self.textFields removeObject:field];
    }
}

/**
 * 此方法适用于最后一个输入框下面还有需要响应的控件的时候，
 * 需要添加额外的偏移来显示这个输入框下面的空间
 */
- (void)addLastAutoScrollUITextField:(UITextField *)lastField
                         extraOffset:(CGFloat)offset
{
    [lastField addTarget:self
              action:@selector(textFieldBeginEdit:)
    forControlEvents:UIControlEventEditingDidBegin];
    self.extraOffset = offset;
    self.lastField = lastField;
    
    if ( ![self.textFields containsObject:lastField] ) {
        [self.textFields addObject:lastField];
    }
}

- (void)removeLastAutoScrollUITextField:(UITextField *)lastField
{
    [lastField removeTarget:self
                 action:@selector(textFieldBeginEdit:)
       forControlEvents:UIControlEventEditingDidBegin];
    
    [self.textFields removeObject:lastField];
}

- (void)textFieldBeginEdit:(UITextField *)sender
{
    self.activeField = sender;
}

- (void)hideKeyboard
{
    for (UITextField *field in self.textFields) {
        [field resignFirstResponder];
    }
}

- (NSMutableArray *)textFields
{
    if ( !_textFields ) {
        _textFields = [[NSMutableArray alloc] init];
    }
    return _textFields;
}

@end

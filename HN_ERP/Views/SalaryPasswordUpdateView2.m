//
//  SalaryPasswordUpdateView.m
//  HN_ERP
//
//  Created by tomwey on 4/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SalaryPasswordUpdateView2.h"
#import "Defines.h"

@interface SalaryPasswordUpdateView2 ()

@property (nonatomic, strong) UIView *boxView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UILabel *titleLabel;

//@property (nonatomic, strong) UITextField *currentPasswordField;
@property (nonatomic, strong) UITextField *passwordField1;
@property (nonatomic, strong) UITextField *passwordField2;

@property (nonatomic, copy) void (^doneCallback)(id inputData);
@property (nonatomic, copy) void (^dismissCallback)(void);

@property (nonatomic, strong) UIView *maskView;

- (void)show;

@end

@implementation SalaryPasswordUpdateView2

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = AWFullScreenBounds();
    }
    return self;
}

- (void)show
{
    self.maskView.alpha = 0.0;
    
    [self.passwordField1 becomeFirstResponder];
    
    self.boxView.center = CGPointMake(self.width / 2,
                                      - self.boxView.height / 2);
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.boxView.center = CGPointMake(self.width / 2,
                                          self.boxView.height / 2 + 88);
    } completion:^(BOOL finished) {
        
    }];
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.frame = self.bounds;
        
        _maskView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _maskView.alpha = 0.0;
        [self sendSubviewToBack:_maskView];
    }
    return _maskView;
}

- (void)dismiss
{
//    [self.currentPasswordField resignFirstResponder];
    [self.passwordField1 resignFirstResponder];
    [self.passwordField2 resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.boxView.center = CGPointMake(self.width / 2, - self.boxView.height);
    } completion:^(BOOL finished) {
        //
        if ( self.dismissCallback ) {
            self.dismissCallback();
        }
        [self removeFromSuperview];
    }];
}

+ (instancetype)showInView:(UIView *)superView
      doneCallback:(void (^)(id inputData))doneCallback
   dismissCallback:(void (^)(void))dismissCallback
{
    SalaryPasswordUpdateView2 *view = [[SalaryPasswordUpdateView2 alloc] init];
    [superView addSubview:view];
    [superView bringSubviewToFront:view];
    
    view.doneCallback = doneCallback;
    view.dismissCallback = dismissCallback;

    [view show];
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.okButton.frame = self.cancelButton.frame;
    self.okButton.left  = self.cancelButton.right + 20;
    
//    self.titleLabel.frame = CGRectMake(0, 0, self.boxView.width, 30);
    self.titleLabel.top = 20;
    
    self.passwordField2.top = self.okButton.top - 15 - self.passwordField2.height;
    self.passwordField1.top = self.passwordField2.top - 10 - self.passwordField1.height;
//    self.currentPasswordField.top = self.passwordField1.top - 10 - self.currentPasswordField.height;
    
//    self.titleLabel.top = self.currentPasswordField.top - 15 - self.titleLabel.height;
    
}

- (UIButton *)cancelButton
{
    if ( !_cancelButton ) {
        _cancelButton = AWCreateTextButton(CGRectZero,
                                           @"取消",
                                           [UIColor whiteColor],
                                           self,
                                           @selector(cancel));
        [self.boxView addSubview:_cancelButton];
        
        _cancelButton.backgroundColor = AWColorFromRGB(198, 198, 198);
        _cancelButton.cornerRadius = 6;
        
        CGFloat padding = 20;
        CGFloat width   = (self.boxView.width - padding * 3) / 2;
        
        _cancelButton.frame = CGRectMake(padding,
                                         self.boxView.height - 15 - 40,
                                         width,
                                         40);
    }
    return _cancelButton;
}

- (UIButton *)okButton
{
    if ( !_okButton ) {
        _okButton = AWCreateTextButton(CGRectZero,
                                       @"确定",
                                       [UIColor whiteColor],
                                       self,
                                       @selector(done));
        [self.boxView addSubview:_okButton];
        
        _okButton.backgroundColor = MAIN_THEME_COLOR;
        _okButton.cornerRadius = 6;
        
        
        
    }
    return _okButton;
}

- (void)done
{
//    if ( self.doneCallback ) {
//        id dict = @{ @"old_password": self.currentPasswordField.text ?: @"",
//                     @"new_password1": self.passwordField1.text ?: @"",
//                     @"new_password2": self.passwordField2.text ?: @"", };
//        self.doneCallback(dict);
//    }
//    [self dismiss];
    
//    if ( self.currentPasswordField.text.length == 0 ) {
//        [AWAppWindow() showHUDWithText:@"旧密码不能为空" offset:CGPointMake(0,20)];
//        return;
//    }
    
    if ( self.passwordField1.text.length == 0 ) {
        [AWAppWindow() showHUDWithText:@"密码不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( self.passwordField2.text.length == 0 ) {
        [AWAppWindow() showHUDWithText:@"确认密码不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( ![self.passwordField2.text isEqualToString:self.passwordField1.text] ) {
        [AWAppWindow() showHUDWithText:@"两次密码输入不一致" offset:CGPointMake(0,20)];
        return;
    }
    
    id user = [[UserService sharedInstance] currentUser];
    
    NSString *manID = [user[@"man_id"] ?: @"0" description];
    
    [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"工资密码修改APP",
              @"param1": manID,
              @"param2": @"",
              @"param3": self.passwordField1.text ?: @"",
              @"param4": self.passwordField2.text ?: @"",
              @"param5": @"1",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
};

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
    
    if ( error ) {
        [AWAppWindow() showHUDWithText:@"服务器出错" succeed:NO];
        
        [self resetForm];
        
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [AWAppWindow() showHUDWithText:@"修改密码失败" succeed:NO];
            
            [self resetForm];
        } else {
            id item = [result[@"data"] firstObject];
            
            if ( [item[@"recode"] integerValue] == 0 ) {
                [AWAppWindow() showHUDWithText:@"密码设置成功" succeed:YES];
                if ( self.doneCallback ) {
                    self.doneCallback(nil);
                }
                [self dismiss];
            } else {
                [AWAppWindow() showHUDWithText:item[@"remsg"] succeed:NO];
                
                [self resetForm];
            }
        }
    }
}

- (void)resetForm
{
//    self.currentPasswordField.text = nil;
    self.passwordField1.text = nil;
    self.passwordField2.text = nil;
    
    [self.passwordField1 becomeFirstResponder];
}

- (void)cancel
{
    [self dismiss];
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(18, YES),
                                    AWColorFromRGB(58, 58, 58));
        [self.boxView addSubview:_titleLabel];
        
        _titleLabel.frame = CGRectMake(20, 25,
                                       self.boxView.width - 40,
                                       37);
        _titleLabel.text = @"设置工资查询密码";
    }
    return _titleLabel;
}

- (UITextField *)passwordField1
{
    if ( !_passwordField1 ) {
        _passwordField1 = [[AWTextField alloc] init];
        [self.boxView addSubview:_passwordField1];
        _passwordField1.placeholder = @"输入密码";
        _passwordField1.returnKeyType = UIReturnKeyNext;
        
        _passwordField1.secureTextEntry = YES;
        
        _passwordField1.tintColor = MAIN_THEME_COLOR;
        
        [_passwordField1 addTarget:self
                            action:@selector(tapReturn:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _passwordField1.frame = self.titleLabel.frame;
        _passwordField1.top = self.cancelButton.top - 15 - _passwordField1.height;
    }
    return _passwordField1;
}

- (UITextField *)passwordField2
{
    if ( !_passwordField2 ) {
        _passwordField2 = [[AWTextField alloc] init];
        [self.boxView addSubview:_passwordField2];
        _passwordField2.placeholder = @"确认密码";
        _passwordField2.returnKeyType = UIReturnKeyDone;
        
        _passwordField2.secureTextEntry = YES;
        
        _passwordField2.tintColor = MAIN_THEME_COLOR;
        
        [_passwordField2 addTarget:self
                            action:@selector(tapReturn:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _passwordField2.frame = self.titleLabel.frame;
        _passwordField2.top = self.cancelButton.top - 15 - _passwordField2.height;
    }
    return _passwordField2;
}

- (void)tapReturn:(UITextField *)sender
{
    if ( sender == self.passwordField1 ) {
        [self.passwordField2 becomeFirstResponder];
    } else {
        [self done];
    }
}

- (UIView *)boxView
{
    if ( !_boxView ) {
        _boxView = [[UIView alloc] init];
        [self addSubview:_boxView];
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.frame = CGRectMake(0, 0, 260, 220);
        
        _boxView.layer.cornerRadius = 8;
        _boxView.clipsToBounds = YES;
    }
    return _boxView;
}

@end

//
//  SalaryPasswordView.m
//  HN_ERP
//
//  Created by tomwey on 4/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SalaryPasswordView.h"
#import "Defines.h"
#import "SalaryVC.h"

@interface SalaryPasswordView ()

@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) void (^doneCallback)(NSString *string);
@property (nonatomic, copy) void (^editCallback)(void);

- (void)show;

@end

@implementation SalaryPasswordView

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
    
    [self.textField becomeFirstResponder];
    
    self.boxView.center = CGPointMake(self.width / 2,
                                      - self.boxView.height / 2);
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.boxView.center = CGPointMake(self.width / 2,
                                          self.boxView.height / 2 + 88);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [self.textField resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.boxView.center = CGPointMake(self.width / 2, - self.boxView.height);
    } completion:^(BOOL finished) {
        //
        if ( self.didDismissBlock ) {
            self.didDismissBlock();
        }
        [self removeFromSuperview];
    }];
}

+ (instancetype)showInView:(UIView *)superView
              doneCallback:(void (^)(NSString *))doneCallback
              editCallback:(void (^)(void))editCallback
{
    SalaryPasswordView *view = [[SalaryPasswordView alloc] init];
    
    [superView addSubview:view];
    
    [superView bringSubviewToFront:view];
    
    view.doneCallback = doneCallback;
    view.editCallback = editCallback;
    
    [view show];
    
    return view;
}

- (void)openKeyboard
{
    [self.textField becomeFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.okButton.frame = self.editButton.frame;
    self.okButton.left  = self.editButton.right + 20;
    
//    self.editButton.frame = CGRectMake(self.boxView.width - 5 - 60,
//                                   5,
//                                   60,
//                                   30);
    
    self.titleLabel.top = self.textField.top - 10 - self.titleLabel.height;
    
    self.cancelButton.position = CGPointMake(self.boxView.width - self.cancelButton.width,
                                             0);
    
}

- (UIButton *)editButton
{
    if ( !_editButton ) {
        _editButton = AWCreateTextButton(CGRectZero,
                                           @"修改密码",
                                           [UIColor whiteColor],
                                           self,
                                           @selector(edit));
        [self.boxView addSubview:_editButton];
        
        _editButton.backgroundColor = AWColorFromRGB(198,198,198);
        _editButton.cornerRadius = 6;
        
        CGFloat padding = 20;
        CGFloat width   = (self.boxView.width - padding * 3) / 2;
        
        _editButton.frame = CGRectMake(padding,
                                         self.boxView.height - 15 - 40,
                                         width,
                                         40);
        
//        _editButton.titleLabel.font = AWSystemFontWithSize(14, NO);
    }
    return _editButton;
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
        
//        _okButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
    }
    return _okButton;
}

- (void)done
{
    if ([[self.textField.text trim] length] == 0) {
        [self.superview showHUDWithText:@"密码不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    [self loadingSalary:self.textField.text];
    
//    if ( self.doneCallback ) {
//        self.doneCallback(self.textField.text);
//    }
//    
//    [self dismiss];
}

- (void)loadingSalary:(NSString *)pwd
{
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth
                                                            value:-1
                                                           toDate:[NSDate date]
                                                          options:0];

    [[SalaryLoader sharedInstance] startLoadingWithPassword:pwd
                                                       date:date
                                                 completion:^(NSString *yearMonth,
                                                              id salaryData,
                                                              NSError *error, NSArray *yearMonths) {
                                                     if ( error ) {
                                                         [AWAppWindow() showHUDWithText:error.domain succeed:NO];
                                                         self.textField.text = nil;
                                                         [self.textField becomeFirstResponder];
                                                     } else {
                                                         
                                                         [self dismiss];
                                                         
                                                         UIViewController *vc =
                                                         [[AWMediator sharedInstance] openVCWithName:@"SalaryVC"
                                                                                                                     params:@{ @"pwd": pwd?:@"",
                                                                                                                               @"data": salaryData ?: @{},
                                                                                                                                                  @"yearMonth": yearMonth ?: @"",
                                                                                                                                                  @"yearMonths": yearMonths ?: @[]}];
                                                          [AWAppWindow().navController pushViewController:vc animated:YES];
                                                     }
                                                 }];
}

- (void)cancel
{
    [self dismiss];
}

- (void)edit
{
    if ( self.editCallback ) {
        self.editCallback();
    }
}

- (UIButton *)cancelButton
{
    if ( !_cancelButton ) {
        _cancelButton = HNCloseButton2(34, self, @selector(cancel), AWColorFromHex(@"#333333"));
        [self.boxView addSubview:_cancelButton];
    }
    return _cancelButton;
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
        _titleLabel.text = @"输入查询密码";
    }
    return _titleLabel;
}

- (UITextField *)textField
{
    if ( !_textField ) {
        _textField = [[AWTextField alloc] init];
        [self.boxView addSubview:_textField];
        _textField.placeholder = @"输入查询密码";
        _textField.returnKeyType = UIReturnKeyDone;
        
        _textField.secureTextEntry = YES;
        
        _textField.tintColor = MAIN_THEME_COLOR;
        
        [_textField addTarget:self
                       action:@selector(done)
             forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _textField.frame = self.titleLabel.frame;
        _textField.top = self.editButton.top - 15 - _textField.height;
    }
    return _textField;
}

- (UIView *)boxView
{
    if ( !_boxView ) {
        _boxView = [[UIView alloc] init];
        [self addSubview:_boxView];
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.frame = CGRectMake(0, 0, 260, 180);
        
        _boxView.layer.cornerRadius = 8;
        _boxView.clipsToBounds = YES;
    }
    return _boxView;
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

@end

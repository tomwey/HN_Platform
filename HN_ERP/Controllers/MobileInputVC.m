//
//  UserFormVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/24.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "MobileInputVC.h"
#import "Defines.h"

@interface MobileInputVC () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *userField;
@property (nonatomic, weak) UITextField *codeField;

//@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, weak) AWButton  *codeButton;
//@property (nonatomic, assign) NSUInteger counter;

@end

@implementation MobileInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"手机";//self.params[@"title"];
    
    // 用户输入背景
    UIView *inputBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 30, 108)];
    inputBGView.cornerRadius = 8;
    [self.contentView addSubview:inputBGView];
    inputBGView.backgroundColor = [UIColor whiteColor];
    
    inputBGView.layer.borderColor = [IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR CGColor];
    inputBGView.layer.borderWidth = 0.5;//( 1.0 / [[UIScreen mainScreen] scale] ) / 2;
    
    inputBGView.clipsToBounds = YES;
    
    inputBGView.center = CGPointMake(self.contentView.width / 2, 20 + inputBGView.height / 2);
    
    // 手机
    UITextField *userField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, inputBGView.width - 20, 34)];
    [inputBGView addSubview:userField];
    userField.placeholder = @"手机号";
    userField.keyboardType = UIKeyboardTypeNumberPad;
    
    userField.delegate = self;
    
    self.userField = userField;
    
    if ( [[UserService sharedInstance] currentUser] ) {
        userField.text = [[UserService sharedInstance] currentUserAuthToken];
        userField.enabled = NO;
    }
    
    // 获取验证码按钮
    AWButton *codeBtn = [AWButton buttonWithTitle:@"获取验证码" color:BUTTON_COLOR];
    [inputBGView addSubview:codeBtn];
    codeBtn.frame = CGRectMake(0, 0, 100, 40);
    codeBtn.left = inputBGView.width - 5 - codeBtn.width;
    codeBtn.top  = userField.midY - codeBtn.height / 2;
    
    self.codeButton  = codeBtn;
    
    userField.width -= codeBtn.width;
    
    [codeBtn addTarget:self forAction:@selector(doFetchCode:)];
    
    codeBtn.titleAttributes = @{ NSFontAttributeName: AWSystemFontWithSize(14, NO) };
    
    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:inputBGView.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:inputBGView];
    hairLine.center = CGPointMake(inputBGView.width / 2, inputBGView.height / 2);
    
    // 验证码
    UITextField *codeField = [[UITextField alloc] initWithFrame:CGRectMake(10, 54 + 10, inputBGView.width - 20, 34)];
    [inputBGView addSubview:codeField];
    codeField.placeholder = @"验证码";
    codeField.keyboardType = UIKeyboardTypePhonePad;
    codeField.returnKeyType = UIReturnKeyDone;
    
    codeField.delegate = self;
    
    self.codeField = codeField;
    
    // 确定按钮
    AWButton *okButton = [AWButton buttonWithTitle:@"确定" color:BUTTON_COLOR];
    [self.contentView addSubview:okButton];
    okButton.frame = CGRectMake(15, inputBGView.bottom  + 15, inputBGView.width, 50);
    [okButton addTarget:self forAction:@selector(doNext)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)doNext
{
    if ( [self.userField.text trim].length == 0 ) {
        [self.contentView makeToast:@"手机号不能为空"
                           duration:2.0
                           position:CSToastPositionTop];
        return;
    }
    
    NSString* reg = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    if ( ![predicate evaluateWithObject:self.userField.text] ) {
        [self.contentView makeToast:@"手机号不正确"
                           duration:2.0
                           position:CSToastPositionTop];
        return;
    }
    
    if ( [self.codeField.text trim].length == 0 ) {
        [self.contentView makeToast:@"验证码不能为空"
                           duration:2.0
                           position:CSToastPositionTop];
        return;
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [self.dataService POST:CHECK_VER_CODE params:@{ @"tel": self.userField.text,
                                                    @"vercode": self.codeField.text
                                                    }
                completion:^(id result, NSError *error) {
                    [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
                    
                    if ( error ) {
                        [me.contentView makeToast:error.domain
                                           duration:2.0
                                           position:CSToastPositionTop];
                    } else {
                        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PasswordVC"
                                                                                    params:@{ @"mobile": me.userField.text,
                                                                                              @"from": [self.params[@"title"] isEqualToString:@"注册"] ? @"signup" : @"forget"
                                                                                              }];
                        [me.navigationController pushViewController:vc animated:YES];
                    }
                }];
    
}

- (void)doFetchCode:(AWButton *)sender
{
    if ( [self.userField.text trim].length == 0 ) {
        [self.contentView makeToast:@"手机号不能为空"
                           duration:2.0
                           position:CSToastPositionTop];
        return;
    }
    
    NSString* reg = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    if ( ![predicate evaluateWithObject:self.userField.text] ) {
        [self.contentView makeToast:@"手机号不正确"
                           duration:2.0
                           position:CSToastPositionTop];
        return;
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    
    [self.dataService POST:IS_EXIST_USER_INFO params:@{ @"tel": self.userField.text } completion:^(id result, NSError *error) {
        if ( [me.params[@"title"] isEqualToString:@"注册"] ) {
            // 注册
            if ( error ) {
                [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
                [me.contentView makeToast:@"用户已存在" duration:2.0 position:CSToastPositionTop];
            } else {
                [me sendCode];
            }
        } else {
            // 忘记密码
            if ( error && error.code == 301 ) {
                // 用户存在
                [me sendCode];
            } else {
                // 用户未注册
                [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
                [me.contentView makeToast:@"用户未注册" duration:2.0 position:CSToastPositionTop];
            }
        }
    }];
}

- (void)sendCode
{
    __weak typeof(self) me = self;
    [self.dataService POST:SEND_VER_CODE params:@{ @"tel": self.userField.text }
                completion:^(id result, NSError *error) {
                    [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
                    
                    if ( !error ) {
                        [me.contentView makeToast:@"验证码已发送" duration:2.0 position:CSToastPositionTop];
                        
                        [me.codeButton disableDuration:60 completionBlock:^(AWButton *sender) {
                            NSLog(@"按钮可以用了");
                        }];
                    } else {
                        [me.contentView makeToast:error.domain duration:2.0 position:CSToastPositionTop];
                    }
                }];
}

@end

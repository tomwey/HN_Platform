//
//  LoginVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/24.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "LoginVC.h"
#import "Defines.h"

@interface LoginVC () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *userField;
@property (nonatomic, weak) UITextField *passField;

@end

@implementation LoginVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *bgView = AWCreateImageView(nil);
    [self.contentView addSubview:bgView];
    bgView.frame = self.contentView.bounds;
    
    bgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login-bg.png" ofType:nil]];
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    bgView.clipsToBounds = YES;
    
    ////////////////////////// logo
    UIImageView *logoView = AWCreateImageView(@"login-logo.png");
    [self.contentView addSubview:logoView];
    logoView.center = CGPointMake(self.contentView.width / 2,
                                  30 + logoView.height / 2);
    
    /////////////////////////////// 用户名
    UIView *inputBGView = [[UIView alloc] initWithFrame:
                           CGRectMake(0, 0, self.contentView.width * 0.8, 44)];
    inputBGView.cornerRadius = 8;
    [self.contentView addSubview:inputBGView];
    inputBGView.backgroundColor = [UIColor whiteColor];
    
    inputBGView.layer.borderColor = [MAIN_THEME_COLOR CGColor];
    inputBGView.layer.borderWidth = 0.5;
    inputBGView.clipsToBounds = YES;
    inputBGView.center = CGPointMake(self.contentView.width / 2,
                                     logoView.bottom + 30 + inputBGView.height / 2);
    
    UIImageView *iconView = AWCreateImageView(@"icon_user.png");
    [inputBGView addSubview:iconView];
    iconView.center = CGPointMake(15 + iconView.width / 2,
                                  inputBGView.height / 2);
    
    // 手机
    UITextField *userField = [[UITextField alloc] initWithFrame:
                              CGRectMake(iconView.right + 10,
                                         inputBGView.height / 2 - 34 / 2 + 1,
                                         inputBGView.width - iconView.right - 10, 34)];
    [inputBGView addSubview:userField];
    userField.placeholder = @"账号";
//    userField.keyboardType = UIKeyboardTypeNumberPad;
    userField.textColor = MAIN_THEME_COLOR;
    userField.returnKeyType = UIReturnKeyNext;
    
    userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userField.autocorrectionType     = UITextAutocorrectionTypeNo;
    
    userField.delegate               = self;
    
    /////////////////////////////// 密码
    UIView *inputBGView2 = [[UIView alloc] initWithFrame:
                           CGRectMake(0, 0, self.contentView.width * 0.8, 44)];
    inputBGView2.cornerRadius = 8;
    [self.contentView addSubview:inputBGView2];
    inputBGView2.backgroundColor = [UIColor whiteColor];
    
    inputBGView2.layer.borderColor = [MAIN_THEME_COLOR CGColor];
    inputBGView2.layer.borderWidth = 0.5;
    inputBGView2.clipsToBounds = YES;
    inputBGView2.center = CGPointMake(self.contentView.width / 2,
                                     inputBGView.bottom + 20 + inputBGView2.height / 2);
    
    UIImageView *iconView2 = AWCreateImageView(@"icon_pass.png");
    [inputBGView2 addSubview:iconView2];
    iconView2.center = CGPointMake(15 + iconView2.width / 2,
                                  inputBGView2.height / 2);
    
    
    UITextField *passField = [[UITextField alloc] initWithFrame:
                              CGRectMake(iconView2.right + 10,
                                         inputBGView2.height / 2 - 34 / 2 + 1,
                                         inputBGView2.width - iconView2.right - 10, 34)];
    [inputBGView2 addSubview:passField];
    passField.placeholder = @"密码";
    passField.secureTextEntry = YES;
    passField.returnKeyType   = UIReturnKeyGo;
    
    passField.delegate        = self;
    passField.textColor = MAIN_THEME_COLOR;
    
    UIButton *btn = AWCreateTextButton(CGRectMake(0, 0, 44, 30), @"显示", MAIN_THEME_COLOR, self, @selector(togglePass:));
    [btn titleLabel].font = AWSystemFontWithSize(14, NO);
    
    passField.rightView = btn;
    passField.rightViewMode = UITextFieldViewModeAlways;
    
    userField.contentVerticalAlignment =
    passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    self.userField = userField;
    self.passField = passField;
    
    self.userField.tintColor = self.passField.tintColor = MAIN_THEME_COLOR;
    
    ////////////////////// 登录按钮
    AWButton *loginButton = [AWButton buttonWithTitle:@"登录" color:MAIN_THEME_COLOR];
    loginButton.outline = YES;
    
    [self.contentView addSubview:loginButton];
    loginButton.frame = inputBGView.frame;
    loginButton.top = inputBGView2.bottom + 30;
    loginButton.cornerRadius = inputBGView.cornerRadius;
    
    [loginButton addTarget:self forAction:@selector(doLogin)];
    
    
    /////////////////// bottom
    UIImageView *bottomView = AWCreateImageView(@"login-bottom.png");
    [self.contentView addSubview:bottomView];
    bottomView.center = CGPointMake(self.contentView.width / 2,
                                   self.contentView.height - 30 - bottomView.height / 2);
    
}

- (void)togglePass:(UIButton *)sender
{
    if ( [[sender currentTitle] isEqualToString:@"显示"] ) {
        self.passField.secureTextEntry = NO;
        [sender setTitle:@"隐藏" forState:UIControlStateNormal];
    } else {
        self.passField.secureTextEntry = YES;
        [sender setTitle:@"显示" forState:UIControlStateNormal];
    }
    
    NSString *tempText = self.passField.text;
    self.passField.text = @" ";
    self.passField.text = tempText;
    
//    [self.passField setText:self.passField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == self.userField ) {
        [self.passField becomeFirstResponder];
    } else if ( textField == self.passField ) {
         [textField resignFirstResponder];
        [self doLogin];
    }
    
    return YES;
}

- (void)doLogin
{
    if ( [self.userField.text trim].length == 0 ) {
//        [self.contentView makeToast:@"账号不能为空"
//                           duration:2.0
//                           position:CSToastPositionCenter];
        [self.contentView showHUDWithText:@"账号不能为空" offset:CGPointMake(0, 0)];
        return;
    }
    
    if ( self.passField.text.length == 0 ) {
//        [self.contentView makeToast:@"密码不能为空"
//                           duration:2.0
//                           position:CSToastPositionCenter];
        [self.contentView showHUDWithText:@"密码不能为空" offset:CGPointMake(0, 0)];
        return;
    }

    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{ @"dotype": @"login",
                        @"username": [[self.userField.text trim] lowercaseString],
                        @"password": self.passField.text,//[[self.passField.text md5Hash] uppercaseString]
                        @"mantype": @"2"
                        }
     completion:^(id result, NSError *error) {
         [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
         if ( !error ) {
             
             // 保存登录信息
             id resultData = result[@"data"];
             
             if ( [result[@"rowcount"] integerValue] > 0 ) {
                 id item = [result[@"data"] firstObject];
                 if ( item[@"code"] && [item[@"code"] integerValue] != 0 ) {
                     [self.contentView showHUDWithText:@"账号或密码不正确" succeed:NO];
                     return;
                 }
             }
             
             if ( [resultData isKindOfClass:[NSArray class]] ) {
                 [[UserService sharedInstance] saveUser:resultData[0]];
             } else if ( [resultData isKindOfClass:[NSDictionary class]] ) {
                 [[UserService sharedInstance] saveUser:resultData];
             }
             
             // 显示提示信息
//             [self.contentView makeToast:@"登录成功"
//                                duration:2.0
//                                position:CSToastPositionCenter];
             
             // 页面跳转
             AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             
             [app resetRootController];
             
//             UINavigationController *nav = [[UINavigationController alloc] init];
//             [nav pushViewController:app.appRootController animated:NO];
             UINavigationController *nav = AWAppWindow().navController;
             [nav pushViewController:app.appRootController animated:YES];
             
             // 记录APP登录日志
             [[SysLogService sharedInstance] logForUserLogin];
             
//             AWAppWindow().rootViewController = app.appRootController;
             
//             [self.navigationController pushViewController:app.appRootController animated:YES];
         } else {
             [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
//             [self.contentView makeToast:error.domain
//                                duration:2.0
//                                position:CSToastPositionTop];
         }
     }];
}

@end

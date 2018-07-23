//
//  ForgetPasswordVC.m
//  HN_Vendor
//
//  Created by tomwey on 09/07/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "ForgetPasswordVC.h"
#import "Defines.h"
//#import <WebKit/WebKit.h>

@interface ForgetPasswordVC ()

@property (nonatomic, weak) UITextField *loginField;

@end

@implementation ForgetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"忘记密码";
    
    // 用户输入背景
    UIView *inputBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.contentView.width - 30, 50)];
    inputBGView.cornerRadius = 8;
    [self.contentView addSubview:inputBGView];
    inputBGView.backgroundColor = [UIColor whiteColor];
    
    inputBGView.layer.borderColor = [IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR CGColor];
    inputBGView.layer.borderWidth = 0.5;//( 1.0 / [[UIScreen mainScreen] scale] ) / 2;
    
    inputBGView.clipsToBounds = YES;
    
    inputBGView.center = CGPointMake(self.contentView.width / 2, 20 + inputBGView.height / 2);
    
    // 密码
    UITextField *loginField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, inputBGView.width - 20, 34)];
    [inputBGView addSubview:loginField];
    self.loginField = loginField;
    loginField.placeholder = @"账号/手机号";
    
    AWButton *okButton = [AWButton buttonWithTitle:@"下一步" color:BUTTON_COLOR];
    [self.contentView addSubview:okButton];
    okButton.frame = CGRectMake(15, inputBGView.bottom  + 20, inputBGView.width, 50);
    [okButton addTarget:self forAction:@selector(done)];
    
//    loginField.secureTextEntry = YES;
//    loginField.delegate = self;
}

- (void)done
{
    [self.loginField resignFirstResponder];
    
    if ([[self.loginField.text trim] length] == 0) {
        [self.contentView showHUDWithText:@"账号或手机号不能为空" offset:CGPointMake(0, 20)];
        return;
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"ERP获取用户手机号APP",
                       @"param1": [self.loginField.text trim]
                       } completion:^(id result, NSError *error) {
                           [me handleResult:result error:error];
                       }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"账号不存在" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            NSString *mobile = item[@"telephone"];
//            NSLog(@"mobile: %@", mobile);
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"UpdatePasswordVC" params:@{ @"mobile": mobile ?: @"" }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end

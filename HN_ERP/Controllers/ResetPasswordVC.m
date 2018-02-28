//
//  PasswordVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/24.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "ResetPasswordVC.h"
#import "Defines.h"

@interface ResetPasswordVC () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *password1Field;
@property (nonatomic, weak) UITextField *nPassword1Field;
//@property (nonatomic, weak) UITextField *nPassword2Field;

@end

@implementation ResetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"修改登录密码";
    
    [self addLeftItemWithView:nil];
    
    // 用户输入背景
    UIView *inputBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 30, 108)];
    inputBGView.cornerRadius = 8;
    [self.contentView addSubview:inputBGView];
    inputBGView.backgroundColor = [UIColor whiteColor];
    
    inputBGView.layer.borderColor = [IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR CGColor];
    inputBGView.layer.borderWidth = 0.5;//( 1.0 / [[UIScreen mainScreen] scale] ) / 2;
    
    inputBGView.clipsToBounds = YES;
    
    inputBGView.center = CGPointMake(self.contentView.width / 2, 20 + inputBGView.height / 2);
    
    // 密码
    UITextField *oldPassword = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, inputBGView.width - 20, 34)];
    [inputBGView addSubview:oldPassword];
    oldPassword.placeholder = @"输入新密码";
    oldPassword.secureTextEntry = YES;
    oldPassword.delegate = self;
    
    self.password1Field = oldPassword;
    
    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:inputBGView.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:inputBGView];
    hairLine.position = CGPointMake(0, oldPassword.bottom + 10);
    
    // 密码
    UITextField *newPassword1 = [[UITextField alloc] initWithFrame:CGRectMake(10, oldPassword.bottom + 10 + 10,
                                                                              inputBGView.width - 20, 34)];
    [inputBGView addSubview:newPassword1];
    newPassword1.placeholder = @"确认新密码";
    newPassword1.secureTextEntry = YES;
    newPassword1.delegate = self;
    
    self.nPassword1Field = newPassword1;
    
    hairLine = [AWHairlineView horizontalLineWithWidth:inputBGView.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:inputBGView];
    hairLine.position = CGPointMake(0, newPassword1.bottom + 10);
    
    // 确认密码
    
    self.password1Field.tintColor =
    self.nPassword1Field.tintColor = MAIN_THEME_COLOR;
    
    self.password1Field.returnKeyType = UIReturnKeyNext;
    self.nPassword1Field.returnKeyType = UIReturnKeyDone;
    
    // 确定按钮
    AWButton *okButton = [AWButton buttonWithTitle:@"完成" color:BUTTON_COLOR];
    [self.contentView addSubview:okButton];
    okButton.frame = CGRectMake(15, inputBGView.bottom  + 15, inputBGView.width, 50);
    [okButton addTarget:self forAction:@selector(done)];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == self.password1Field ) {
        [self.nPassword1Field becomeFirstResponder];
    } else if ( textField == self.nPassword1Field ) {
        [textField resignFirstResponder];
        [self done];
    }
    
    return YES;
}

- (void)done
{
    if ( self.password1Field.text.length == 0 ) {
        [self.contentView showHUDWithText:@"新密码不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( self.nPassword1Field.text.length == 0 ) {
        [self.contentView showHUDWithText:@"确认密码不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( self.password1Field.text.length < 6 || self.password1Field.text.length > 20 ) {
        [self.contentView showHUDWithText:@"密码长度为6-20位"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( self.nPassword1Field.text.length < 6 || self.nPassword1Field.text.length > 20 ) {
        [self.contentView showHUDWithText:@"密码长度为6-20位"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( ![self.nPassword1Field.text isEqualToString:self.password1Field.text] ) {
        [self.contentView showHUDWithText:@"两次密码输入不一致"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( [@"000000" isEqualToString:self.password1Field.text] ) {
        [self.contentView showHUDWithText:@"新密码不能为初始密码"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description] ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:
     @{
       @"dotype": @"changepwd",
       @"manid": manID,
       @"oldpwd": @"000000",
       @"newpwd": self.password1Field.text,
       } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
    
    
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"未知原因修改密码错误" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            NSInteger code = [item[@"code"] integerValue];
            NSString *msg = [item[@"codemsg"] description];
            
//            id resultData = result[@"data"];
            
//            [self.contentView showHUDWithText:msg succeed:code == 0];
            
            if ( code == 0 ) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasChangedPWD"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [app resetRootController];
                
                //             UINavigationController *nav = [[UINavigationController alloc] init];
                //             [nav pushViewController:app.appRootController animated:NO];
                UINavigationController *nav = AWAppWindow().navController;
                [nav pushViewController:app.appRootController animated:YES];
            } else {
                [self.contentView showHUDWithText:msg succeed:NO];
            }
            
        }
    }
}

@end

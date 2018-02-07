//
//  PasswordVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/24.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "PasswordVC.h"
#import "Defines.h"

@interface PasswordVC () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *password1Field;
@property (nonatomic, weak) UITextField *nPassword1Field;
@property (nonatomic, weak) UITextField *nPassword2Field;

@end

@implementation PasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"修改密码";
    
    // 用户输入背景
    UIView *inputBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width - 30, 108 + 54)];
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
    oldPassword.placeholder = @"输入旧密码";
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
    newPassword1.placeholder = @"输入新密码";
    newPassword1.secureTextEntry = YES;
    newPassword1.delegate = self;
    
    self.nPassword1Field = newPassword1;
    
    hairLine = [AWHairlineView horizontalLineWithWidth:inputBGView.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:inputBGView];
    hairLine.position = CGPointMake(0, newPassword1.bottom + 10);
    
    // 确认密码
    UITextField *codeField = [[UITextField alloc] initWithFrame:CGRectMake(10, newPassword1.bottom + 10 + 10, inputBGView.width - 20, 34)];
    [inputBGView addSubview:codeField];
    codeField.placeholder = @"确认新密码";
    codeField.returnKeyType = UIReturnKeyDone;
    codeField.secureTextEntry = YES;
    codeField.delegate = self;
    
    self.nPassword2Field = codeField;
    
    self.password1Field.tintColor =
    self.nPassword1Field.tintColor =
    self.nPassword2Field.tintColor = MAIN_THEME_COLOR;
    
    self.password1Field.returnKeyType =
    self.nPassword1Field.returnKeyType = UIReturnKeyNext;
    
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
        [self.nPassword2Field becomeFirstResponder];
    } else if ( self.nPassword2Field == textField ) {
        [textField resignFirstResponder];
        [self done];
    }
    
    return YES;
}

- (void)done
{
    if ( self.password1Field.text.length == 0 ) {
        [self.contentView showHUDWithText:@"旧密码不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( self.nPassword1Field.text.length == 0 ) {
        [self.contentView showHUDWithText:@"新密码不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( self.nPassword2Field.text.length == 0 ) {
        [self.contentView showHUDWithText:@"确认密码不能为空"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    if ( ![self.nPassword1Field.text isEqualToString:self.nPassword2Field.text] ) {
        [self.contentView showHUDWithText:@"两次密码输入不一致"
                                   offset:CGPointMake(0, 20)];
        return;
    }
    
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description] ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"changepwd",
              @"manid": manID,
              @"oldpwd": self.password1Field.text,
              @"newpwd": self.nPassword1Field.text,
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
            
//            [self.contentView showHUDWithText:msg succeed:code == 0];
            
            if ( code == 0 ) {
                [self.navigationController.view showHUDWithText:msg succeed:YES];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.contentView showHUDWithText:msg succeed:NO];
            }
            
        }
    }
}

@end

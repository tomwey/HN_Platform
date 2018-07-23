//
//  BindMobileVC.m
//  HN_ERP
//
//  Created by tomwey on 23/07/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "BindMobileVC.h"
#import "Defines.h"

@interface BindMobileVC () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSTimer *countDownTimer;

@property (nonatomic, weak) UIButton *codeBtn;

@property (nonatomic, weak) UITextField *mobileField;
@property (nonatomic, weak) UITextField *codeField;
@property (nonatomic, weak) UITextField *passwordField;

@end

@implementation BindMobileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"绑定手机";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = 50;
    
    self.tableView.scrollEnabled = NO;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 80)];
    self.tableView.tableFooterView = header;
    
    //    self.contentView.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    //    header.backgroundColor = self.contentView.backgroundColor;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:header.width - 15 color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:header];
    line.position = CGPointMake(15, 0);
    
    UIButton *btn = AWCreateTextButton(CGRectMake(15, 30, self.contentView.width - 30, 44), @"提交",
                                       [UIColor whiteColor], self, @selector(commit));
    [header addSubview:btn];
    btn.backgroundColor = MAIN_THEME_COLOR;
    btn.cornerRadius = 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ( indexPath.row == 0 ) {
            [self addMobileAndCode:cell];
        } else if ( indexPath.row == 1 ) {
            [self addCodeInput:cell];
        } else if ( indexPath.row == 2 ) {
            [self addPasswordInput:cell];
        }
//        else if ( indexPath.row == 3 ) {
//            [self addPasswordInput2:cell];
//        }
    }
    
    return cell;
}

- (void)addMobileAndCode:(UITableViewCell *)cell
{
    UITextField *mobileField = [[UITextField alloc] init];
    [cell.contentView addSubview:mobileField];
    mobileField.frame = CGRectMake(15, 0, 120, 50);
    self.mobileField = mobileField;
    
    mobileField.placeholder = @"请输入手机号";
    mobileField.enabled = NO;
    mobileField.font = AWSystemFontWithSize(15, NO);
    mobileField.textColor = AWColorFromHex(@"#999999");
    
    UIButton *codeBtn = AWCreateTextButton(CGRectMake(0, 0, 120, 40), @"获取验证码",
                                           MAIN_THEME_COLOR, self, @selector(getCode:));
    [cell.contentView addSubview:codeBtn];
    
    self.codeBtn = codeBtn;
    
    self.codeBtn.userData = @"59";
    
    codeBtn.titleLabel.font = AWSystemFontWithSize(15, NO);
    codeBtn.position = CGPointMake(self.contentView.width - 10 - codeBtn.width, 5);
}

- (void)getCode:(UIButton *)btn
{
    [self setCodeButtonEnabled:NO];
    
    [self.codeField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [self requestWithURI:@"sms/send"
                  params:@{ @"Mobile": self.params[@"mobile"] ?: @"",
                            @"Type": @(1)
                            }
              completion:^(NSInteger code, NSString *msg) {
                  [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
                  
                  if ( code == 0 ) {
                      [me.contentView showHUDWithText:msg succeed:YES];
                      [me startTimer];
                  } else {
                      [me.contentView showHUDWithText:msg succeed:NO];
                      [me setCodeButtonEnabled:YES];
                  }
                  
              }];
}

- (void)setCodeButtonEnabled:(BOOL)flag
{
    self.codeBtn.userInteractionEnabled = flag;
    
    if ( flag ) {
        [self.codeBtn setTitleColor:MAIN_THEME_COLOR forState:UIControlStateNormal];
    } else {
        [self.codeBtn setTitleColor:AWColorFromHex(@"#999999") forState:UIControlStateNormal];
    }
}

- (void)startTimer
{
    [self.countDownTimer setFireDate:[NSDate date]];
}

- (void)requestWithURI:(NSString *)uri
                params:(NSDictionary *)params
            completion:(void (^)(NSInteger code, NSString *msg))completion
{
    //    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSString *host = @"http://erp20-sms.heneng.cn:16710/api";
    
    NSString *Nonce = [NSString stringWithFormat:@"%ld", (NSInteger)[[NSDate date] timeIntervalSince1970]];
    NSString *Signature = [[NSString stringWithFormat:@"%@HN.Mobile.sms.2018-0", Nonce] md5Hash];
    
    NSMutableDictionary *newParams = [params mutableCopy];
    newParams[@"Nonce"] = Nonce;
    newParams[@"Signature"] = Signature;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:
                             [NSURLSessionConfiguration defaultSessionConfiguration]];
    
    __weak typeof(self) me = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", host, uri]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:newParams
                                                       options:0
                                                         error:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [me handleResult:data error:error completion:completion];
                                                });
                                            }];
    
    [task resume];
}

- (void)handleResult:(NSData *)data
               error:(NSError *)error
          completion:(void (^)(NSInteger code, NSString *msg))completion
{
    //    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        //        [self.contentView showHUDWithText:@"服务器出错了~" succeed:NO];
        if ( completion ) {
            completion(500, @"服务器出错了~");
        }
    } else {
        id object = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:nil];
        if ( !object ) {
            if ( completion ) {
                completion(-9, @"解析结果出错");
            }
        } else {
            NSInteger code = [object[@"code"] integerValue];
            if ( code == 0 ) {
                //                [self.contentView showHUDWithText:object[@"codemsg"] succeed:YES];
                if ( completion ) {
                    completion(0, object[@"codemsg"]);
                }
            } else {
                //                [self.contentView showHUDWithText:object[@"codemsg"] succeed:NO];
                if ( completion ) {
                    completion(code, object[@"codemsg"]);
                }
            }
            
            
        }
    }
}

- (void)commit
{
    [self.mobileField resignFirstResponder];
    [self.codeField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    if ( [[self.mobileField.text trim] length] == 0 ) {
        [self.contentView showHUDWithText:@"手机号不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( [[self.codeField.text trim] length] == 0 ) {
        [self.contentView showHUDWithText:@"验证码不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( [self.passwordField.text length] == 0 ) {
        [self.contentView showHUDWithText:@"密码不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    // 验证登录密码
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"平台验证密码APP",
              @"param1": [userInfo[@"man_id"] ?: @"0" description],
              @"param2": self.passwordField.text ?: @"",
              } completion:^(id result, NSError *error) {
                  [me handleResult1:result error:error];
              }];
    
//    if ( [self.passwordField2.text length] == 0 ) {
//        [self.contentView showHUDWithText:@"确认密码不能为空" offset:CGPointMake(0,20)];
//        return;
//    }
//
//    if ( [self.passwordField.text isEqualToString:self.passwordField2.text] == NO ) {
//        [self.contentView showHUDWithText:@"两次密码输入不一致" offset:CGPointMake(0,20)];
//        return;
//    }
    
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
//
//    __weak typeof(self) me = self;
//    [self requestWithURI:@"sms/code_verify"
//                  params:@{ @"Mobile": self.params[@"mobile"] ?: @"",
//                            @"Type": @(1),
//                            @"Code": [self.codeField.text trim] ?: @""
//                            }
//              completion:^(NSInteger code, NSString *msg) {
//                  if ( code == 0 ) {
//                      [me updatePassword];
//                  } else {
//                      [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
//                      [me.contentView showHUDWithText:msg succeed:NO];
//                  }
//              }];
}

- (void)handleResult1:(id)result error:(NSError *)error
{
    if ( error ) {
        [self.contentView showHUDWithText:@"服务器出错了~" succeed:NO];
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"未知错误" succeed:NO];
            [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        } else {
            id item = [result[@"data"] firstObject];
            if ( [item[@"hinttype"] integerValue] == 1 ) {
                [self verifyCode];
            } else {
                [self.contentView showHUDWithText:item[@"hint"] succeed:NO];
                [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
            }
        }
    }
}

- (void)verifyCode
{
    __weak typeof(self) me = self;
    [self requestWithURI:@"sms/code_verify"
                  params:@{ @"Mobile": self.params[@"mobile"] ?: @"",
                            @"Type": @(1),
                            @"Code": [self.codeField.text trim] ?: @""
                            }
              completion:^(NSInteger code, NSString *msg) {
                  if ( code == 0 ) {
                      [me updatePassword];
                  } else {
                      [HNProgressHUDHelper hideHUDForView:me.contentView animated:YES];
                      [me.contentView showHUDWithText:msg succeed:NO];
                  }
              }];
}

- (void)updatePassword
{
    //    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"平台用户绑定手机号APP",
              @"param1": [userInfo[@"man_id"] ?: @"0" description],
              @"param2": self.mobileField.text
              } completion:^(id result, NSError *error) {
                  [me handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if (error) {
        [self.contentView showHUDWithText:@"服务器出错了~" succeed:NO];
    } else {
        [self.navigationController.view showHUDWithText:@"手机绑定成功" succeed:YES];
        [self.navigationController popViewControllerAnimated:YES];
//        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.contentView showHUDWithText:@"未知错误" succeed:NO];
//        } else {
//            id item = [result[@"data"] firstObject];
//            if ( [item[@"hinttype"] integerValue] == 1 ) {
//                [self.navigationController.view showHUDWithText:@"手机绑定成功" succeed:YES];
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            } else {
//                [self.contentView showHUDWithText:item[@"hint"] succeed:NO];
//            }
//        }
    }
}

- (NSTimer *)countDownTimer
{
    if ( !_countDownTimer ) {
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(countDown)
                                                         userInfo:nil
                                                          repeats:YES];
        [_countDownTimer setFireDate:[NSDate distantFuture]];
    }
    return _countDownTimer;
}

- (void)countDown
{
    NSInteger counter = [self.codeBtn.userData integerValue];
    
    if ( counter == 0 ) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        
        self.codeBtn.userData = @"59";
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        [self setCodeButtonEnabled:YES];
        
    } else {
        [self.codeBtn setTitleColor:AWColorFromHex(@"#999999") forState:UIControlStateNormal];
        [self.codeBtn setTitle:[NSString stringWithFormat:@"重新发送(%d)", counter]
                      forState:UIControlStateNormal];
        
        self.codeBtn.userData = [@(counter - 1) description];
    }
}

- (void)addCodeInput:(UITableViewCell *)cell
{
    UITextField *mobileField = [[UITextField alloc] init];
    [cell.contentView addSubview:mobileField];
    mobileField.frame = CGRectMake(15, 0, 120, 50);
    self.codeField = mobileField;
    self.codeField.font = AWSystemFontWithSize(15, NO);
    mobileField.keyboardType = UIKeyboardTypeNumberPad;
    mobileField.placeholder = @"请输入验证码";
}

- (void)addPasswordInput:(UITableViewCell *)cell
{
    UITextField *mobileField = [[UITextField alloc] init];
    [cell.contentView addSubview:mobileField];
    self.passwordField = mobileField;
    self.passwordField.font = AWSystemFontWithSize(15, NO);
    mobileField.frame = CGRectMake(15, 0, 260, 50);
    mobileField.secureTextEntry = YES;
    mobileField.placeholder = @"请输入登录密码";
}

//- (void)addPasswordInput2:(UITableViewCell *)cell
//{
//    UITextField *mobileField = [[UITextField alloc] init];
//    [cell.contentView addSubview:mobileField];
//    self.passwordField2 = mobileField;
//    mobileField.frame = CGRectMake(15, 0, 260, 50);
//    mobileField.secureTextEntry = YES;
//    mobileField.placeholder = @"请输入确认密码";
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
}

@end

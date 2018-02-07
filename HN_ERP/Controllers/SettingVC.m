//
//  SettingVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "SettingVC.h"
#import "Defines.h"
#import "SalaryVC.h"
#import "SalaryPasswordUpdateView2.h"

@interface SettingVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, weak)   SettingTableHeader *tableHeader;

@property (nonatomic, assign) CGSize originalHeaderSize;

@end
@implementation SettingVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                        image:[UIImage imageNamed:@"tab_setting.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_setting_click.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"个人中心";
    
//    [self addLeftItemWithView:nil];
//    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = [[NSArray alloc] initWithContentsOfFile:
                       [[NSBundle mainBundle] pathForResource:@"Settings.plist" ofType:nil]];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    [self.contentView addSubview:self.tableView];
//    self.tableView.height -= 49;
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 50;
    
    SettingTableHeader *settingHeader = [[SettingTableHeader alloc] init];
    UIView *tableHeader = [[UIView alloc] initWithFrame:settingHeader.frame];
    [tableHeader addSubview:settingHeader];
    self.tableHeader = settingHeader;
    
    self.tableView.tableHeaderView = tableHeader;
    
    self.originalHeaderSize = self.tableHeader.frame.size;
    
//    __weak typeof(self) me = self;
//    self.tableHeader.didSelectCallback = ^(SettingTableHeader *sender) {
//        [me gotoUserProfile];
//    };
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.tableHeader.currentUser = [[UserService sharedInstance] currentUser];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id obj = self.dataSource[indexPath.section][indexPath.row];
    
    if ( [[[obj valueForKey:@"label"] description] isEqualToString:@"退出登录"] ) {
        NSString *cellId = @"cell2.id";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if ( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = AWColorFromRGB(135, 135, 135);//[UIColor redColor];
        
        cell.textLabel.text = @"退出登录";
        
        return cell;
    }
    
    static NSString *cellId = @"cell.id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    
    if ( ![obj valueForKey:@"action"] ) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *value = [[obj valueForKey:@"value"] description];
    
    if ( [value isEqualToString:@"qq"] ) {
        value = [[[[VersionCheckService sharedInstance] appInfo] valueForKey:@"QQ"] description];
    } else if ( [value isEqualToString:@"cache"] ) {
//        ([[NSURLCache sharedURLCache] currentMemoryUsage] + [AttachmentDownloadService cachedFileSize] ) / 1024.0 / 1024.0
        value = [NSString stringWithFormat:@"%.1fM", [[HNCacheHelper sharedInstance] readCacheSize]];
    } else if ( [value isEqualToString:@"version"] ) {
        value = AWAppVersion();
    }
    
    if ( [[[obj valueForKey:@"label"] description] isEqualToString:@"退出登录"] ) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
        
        cell.textLabel.text = [[obj valueForKey:@"label"] description];
    } else {
        cell.textLabel.text  = [[obj valueForKey:@"label"] description];
        cell.textLabel.textColor = AWColorFromRGB(135, 135, 135);
        
        cell.detailTextLabel.text = value;
        
        UIImage *image = nil;
//        if ( [[[obj valueForKey:@"label"] description] isEqualToString:@"清除缓存"] ) {
//            FAKFontAwesome *icon = [FAKFontAwesome trashOIconWithSize:26];
//            [icon addAttributes:@{ NSForegroundColorAttributeName: cell.textLabel.textColor }];
//            image = [icon imageWithSize:CGSizeMake(30, 30)];
//        } else {
        
        NSString *icon = [[obj valueForKey:@"icon"] description];
        if ( [icon hasSuffix:@".png"] ||
            [icon hasSuffix:@".jpg"] ||
            [icon hasSuffix:@".gif"]) {
            image = [UIImage imageNamed:icon];
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            FAKIonIcons *icon = [FAKIonIcons iconWithIdentifier:[[obj valueForKey:@"icon"] description]
                                                           size:26
                                                          error:nil];
            [icon addAttributes:@{ NSForegroundColorAttributeName: cell.textLabel.textColor }];
            image = [icon imageWithSize:CGSizeMake(30, 30)];
        }
        
        
//        }
        
        cell.imageView.image = image;
        
        cell.imageView.tintColor = cell.textLabel.textColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id obj = self.dataSource[indexPath.section][indexPath.row];
    NSString *action = [[obj valueForKey:@"action"] description];
    
    SEL selector = NSSelectorFromString(action);
    if ( [self respondsToSelector:selector] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:nil];
#pragma clang diagnostic pop
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = - scrollView.contentOffset.y;
    if ( y > 0 ) {
        CGFloat width = self.originalHeaderSize.width + y * 5 / 3;
        CGFloat height = self.originalHeaderSize.height + y;
        self.tableHeader.frame =
            CGRectMake(0, scrollView.contentOffset.y,width, height);
        self.tableHeader.center =
            CGPointMake(self.view.center.x,
                        self.tableHeader.center.y );
    }
}

- (void)gotoUserProfile
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MancardVC" params:@{ @"manid": manID }];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)updatePassword
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PasswordVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoQJ
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"ApplyLeaveVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoKQ
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttendanceVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoSalary
{
    BOOL hasPayPassword = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPayPassword"];
    if ( !hasPayPassword ) {
        id user = [[UserService sharedInstance] currentUser];
        
        NSString *manID = [user[@"man_id"] ?: @"0" description];
        
        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
        
        __weak typeof(self) me = self;
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"GetData",
                  @"funname": @"判断工资密码是否设置APP",
                  @"param1": manID,
                  } completion:^(id result, NSError *error) {
                      [me handleResult:result error: error];
                  }];
    } else {
        [self showSalaryLogin];
    }
}

- (void)showSalaryLogin
{
    __block SalaryPasswordView *view1 =
    [SalaryPasswordView showInView:self.view doneCallback:^(NSString *password) {
        //
        //        NSLog(@"string: %@", password);
        //        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"SalaryVC"
        //                                                                    params:@{ @"pwd": password ?: @"" }];
        //        [AWAppWindow().navController pushViewController:vc animated:YES];
        
        //        [me loadingSalary:password];
        
    } editCallback:^{
        //
        [SalaryPasswordUpdateView showInView:self.view
                                doneCallback:^(id inputData) {
                                    
                                }
                             dismissCallback:^{
                                 [view1 openKeyboard];
                             }];
    }];
}

- (void)showSettingPayPassword
{
    __weak typeof(self) me = self;
    [SalaryPasswordUpdateView2 showInView:self.view doneCallback:^(id inputData) {
        //
        [me gotoSalary];
    } dismissCallback:^{
        
    }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( !error ) {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"检测用户是否设置工资查询密码失败" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            
            if ( item[@"recode"] && [item[@"recode"] integerValue] == 1 ) {
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPayPassword"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self showSalaryLogin];
            } else {
                [self showSettingPayPassword];
            }
        }
    } else {
        [self.contentView showHUDWithText:@"检测用户是否设置工资查询密码失败" succeed:NO];
    }
}

- (void)logout
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您确定要退出登录吗？"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"取消", @"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        [[UserService sharedInstance] logout:^(id result, NSError *error) {
            
            // 清除缓存
            [[HNCache sharedInstance] removeAllCaches];
//            [[HNNewFlowCountService sharedInstance] resetTotalFlowCount];
            
            UIViewController *rootVC = [[NSClassFromString(@"LoginVC") alloc] init];
            UINavigationController *nav =
            [[UINavigationController alloc] initWithRootViewController:rootVC];
            nav.navigationBarHidden = YES;
            
            AWAppWindow().rootViewController = nav;
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [app resetRootController];
        }];
    }
}

- (void)openQRCode
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AppQrcodeVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)checkVersion
{
    [[VersionCheckService sharedInstance] startCheckWithSilent:NO];
}

- (void)gotoInvest
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"InvestVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoHelp
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"HelpVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)clearCache
{
    [HNProgressHUDHelper showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//        [AttachmentDownloadService removeAllCachedFiles];
        [[HNCacheHelper sharedInstance] clearFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HNProgressHUDHelper hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
        });
    });
}

- (void)gotoFeedback
{
//    WebViewVC *page = [[WebViewVC alloc] initWithURL:[NSURL URLWithString:FEEDBACK_URL] title:@"意见反馈"];
//    [AWAppWindow().navController pushViewController:page animated:YES];
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"FeedbackVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)openPhone
{
    NSString *phone = [NSString stringWithFormat:@"tel:%@", [[[[VersionCheckService sharedInstance] appInfo] valueForKey:@"Tel"] description]];
    NSURL *phoneURL = [NSURL URLWithString:phone];
    
    if ( [AWDeviceName() rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].location != NSNotFound &&
        [[UIApplication sharedApplication] canOpenURL:phoneURL] ) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    } else {
        [self showAlertWithTitle:@"提示" message:@"您的设备不支持打电话功能"];
    }
}

- (void)gotoVersion
{
    [[VersionCheckService sharedInstance] startCheckWithSilent:NO];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"确定",nil] show];
}

@end

//
//  VersionCheckerService.m
//  RTA
//
//  Created by tangwei1 on 16/10/26.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "VersionCheckService.h"
#import "Defines.h"

#import "UIView+TYAlertView.h"
// if you want blur efffect contain this
#import "TYAlertController+BlurEffects.h"

#import "UIApplication+Close.h"

@interface TYAlertController (HideStatusBar)

@end

@interface VersionCheckService ()

@property (nonatomic, assign) BOOL checking;

@property (nonatomic, strong, readwrite) id appInfo;

@property (nonatomic, assign) BOOL silent;

@end

@implementation VersionCheckService

+ (instancetype)sharedInstance
{
    static VersionCheckService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[VersionCheckService alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(startCheck)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
        }
    });
    return instance;
}

- (void)startCheck
{
    [self startCheckWithSilent:YES];
}

- (void)startCheckWithSilent:(BOOL)isSilent
{
    if ( self.checking ) {
        return;
    }
    
    self.checking = YES;
    
    self.silent = isSilent;
    
    if ( !isSilent ) {
        [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    }
    
    VersionCheckService * __weak weakSelf = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{ @"dotype": @"GetData",
               @"funname": @"版本信息查询APP",
               @"param1": AWAppVersion(),
               @"param2": @"iOS",
               }
     completion:^(id result, NSError *error) {
         [weakSelf handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
    
    if ( !error ) {
//        self.appInfo = result;
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            if ( !self.silent ) {
                [AWAppWindow() showHUDWithText:@"已经是最新版本" offset:CGPointMake(0,20)];
            }
            
            self.checking = NO;
        } else {
            self.appInfo = [result[@"data"] firstObject];
            
            [self showVersionTips];
        }
        
        
//        [self checkVersion];
    } else {
        self.checking = NO;
        
        if ( !self.silent ) {
            [AWAppWindow() showHUDWithText:@"获取版本信息失败" succeed:NO];
        } else {
            
        }
    }
}

- (void)showVersionTips
{
    NSString *title = [self.appInfo[@"version_desc"] description];
    if ( title.length == 0 || [title isEqualToString:@"NULL"] ) {
        title = @"有新版本可用";
    }
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:title
                                                     message:[self.appInfo[@"changelog"] description]];
    
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
//    alertView.contentViewSpace = 30;
    alertView.textLabelSpace   = 20;
    alertView.textLabelContentViewEdge = 35;
    
    if ( ![self.appInfo[@"must_update"] boolValue] ) {
        [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancel handler:^(TYAlertAction *action) {
            NSLog(@"%@",action.title);
            self.checking = NO;
        }]];
    }
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"立即更新" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
        NSLog(@"%@",action.title);
        self.checking = NO;
//        itms-services://?action=download-manifest&url=https://erp20.heneng.cn:16666/IOS/HN_ERP.plist
//        https://erp20.heneng.cn:16666/IOS
        BOOL flag = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://erp20.heneng.cn:16666/IOS/HN_ERP.plist"]];
        [[UIApplication sharedApplication] close];
        
        if ( flag ) {
//            [[UIApplication sharedApplication] performSelector:@selector(suspend) withObject:nil];
        } else {
            
        }
    }]];
    
    alertView.buttonDestructiveBgColor = MAIN_THEME_COLOR;
    
    // first way to show
    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
    
    [AWAppWindow().rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end

@implementation TYAlertController (HideStatusBar)

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

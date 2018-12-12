//
//  SaleRegVC.m
//  HN_ERP
//
//  Created by tomwey on 09/08/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "SaleRegVC.h"
#import <WebKit/WebKit.h>
#import "Defines.h"
#import "NSDataAdditions.h"

@interface SaleRegVC () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation SaleRegVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *statusBar = (UIView *)[[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.backgroundColor = MAIN_THEME_COLOR;

    CGFloat topMargin = 20;
    CGFloat dtHeight = 0;
    
    if (AWOSVersionIsLower(11)) {
        topMargin = 20;
        dtHeight  = 0;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else {
        if ( AWFullScreenHeight() == 812 ) {
            // iphone x
            topMargin = 44;
            dtHeight  = 34;
        } else {
            // 其它iphone
        }
    }
    
    self.webView = [[WKWebView alloc] initWithFrame:
                    CGRectMake(0, topMargin, AWFullScreenWidth(), AWFullScreenHeight() - topMargin - dtHeight)];
    [self.view addSubview:self.webView];
    
//    self.view.backgroundColor = [UIColor redColor];
    id user = [[UserService sharedInstance] currentUser];
    
    NSDictionary *dict = @{
                           @"manid": [user[@"man_id"] description] ?: @"",
                           @"manname": [user[@"man_name"] description] ?: @"",
                           @"powerids": self.params[@"powerids"]
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    NSString *result = [data aes256_encrypt_hex:@"Hnerp_2018"];
    NSLog(@"#####: %@", result);
    
    NSString *urlString = [NSString stringWithFormat:@"http://erp20-sms.heneng.cn:16712?key=%@",result];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 30;
//    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    self.webView.navigationDelegate = self;

    [self.webView loadRequest:request];

    self.webView.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    [HNProgressHUDHelper showHUDAddedTo:self.view animated:YES];
    
//    self.webView.backgroundColor = [UIColor redColor];
//
//    self.view.backgroundColor = [UIColor greenColor];
//
//    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIView *statusBar = (UIView *)[[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
//    NSLog(@"%@, %d", request, navigationAction.navigationType);
    if ( [[request.URL absoluteString] isEqualToString:@"salereg://back"] ) {
        
        [self.navigationController popViewControllerAnimated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ( [[request.URL absoluteString] hasPrefix:@"tel:"] ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[request.URL absoluteString]]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

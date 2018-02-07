//
//  NewsDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 4/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NewsDetailVC.h"
#import "Defines.h"
#import <QuickLook/QuickLook.h>

@interface NewsDetailVC () <QLPreviewControllerDataSource, UIWebViewDelegate>

@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, copy) NSString *rtfFilePath;

@property (nonatomic, assign) BOOL isNew;

@end

@implementation NewsDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = self.params[@"item"][@"title"] ?: @"新闻详情";
    
    self.isNew = [self.params[@"item"][@"isnew"] boolValue];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:webView];
    
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.backgroundColor = [UIColor whiteColor];
    
    NSString *html = @"<!DOCTYPE html><html lang=\"zh\"><head><meta charset=\"UTF-8\"><title></title><meta name=\"format-detection\" content=\"telephone=no\">%@</head>${content}</html>";
    NSString *styleFile = [[NSBundle mainBundle] pathForResource:@"news_style" ofType:nil];
    NSString *style = [[NSString alloc] initWithContentsOfFile:styleFile encoding:NSUTF8StringEncoding error:nil];
    html = [NSString stringWithFormat:html, style];
    html = [html stringByReplacingOccurrencesOfString:@"${content}" withString:self.params[@"item"][@"content"]];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"<BR>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"<BR />" withString:@""];
    
    html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"<BR/>" withString:@""];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [webView loadHTMLString:html
                    baseURL:nil];
    
    
    
}

- (void)markNewsRead
{
    NSString *newsID = [self.params[@"item"][@"id"] ?: @"0" description];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"新闻标记已读APP",
              @"param1": newsID,
              @"param2": manID,
              } completion:^(id result, NSError *error) {
                  if ( me.isNew ) {
                      [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadBadgeNotification object:nil];
                  }
              }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    [self markNewsRead];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.rtfFilePath];
}

- (QLPreviewController *)previewController
{
    if ( !_previewController ) {
        _previewController = [[QLPreviewController alloc] init];
        _previewController.dataSource = self;
        //        _previewController.delegate = self;
        
        _previewController.currentPreviewItemIndex = 0;
        
        _previewController.view.frame = self.contentView.bounds;
        
        [self addChildViewController:_previewController];
        [self.contentView addSubview:_previewController.view];
        
        [_previewController didMoveToParentViewController:self];
    }
    return _previewController;
}

@end

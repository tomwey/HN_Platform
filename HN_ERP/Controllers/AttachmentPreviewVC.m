//
//  AttachmentPreviewVC.m
//  HN_ERP
//
//  Created by tomwey on 2/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AttachmentPreviewVC.h"
#import "Defines.h"
#import <QuickLook/QuickLook.h>
#import "AttachmentDownloadService.h"
#import <WebKit/WebKit.h>

@interface AttachmentPreviewVC () <QLPreviewControllerDataSource, UIWebViewDelegate, WKNavigationDelegate>

@property (nonatomic, strong) AttachmentDownloadService *downloadService;
@property (nonatomic, strong) NSURL *attachmentURL;
@property (nonatomic, strong) QLPreviewController *previewController;

@property (nonatomic, strong) UIWebView *previewWebView;
@property (nonatomic, strong) WKWebView *previewWebView2;

@end

@implementation AttachmentPreviewVC

//- (void)dealloc
//{
//    [NSURLProtocol unregisterClass:[OfficeDocProtocol class]];
//    [NSURLProtocol wk_unregisterScheme:@"http"];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [NSURLProtocol registerClass:[OfficeDocProtocol class]];
//
//    [NSURLProtocol wk_registerScheme:@"http"];
    
    NSLog(@"item: %@", self.params[@"item"]);
    
    self.navBar.title = self.params[@"item"][@"filename"];
    
//    self.contentView.backgroundColor = [UIColor redColor];
    
    // 添加默认的返回按钮
    [self addLeftItemWithView:HNBackButton(24, self, @selector(back)) leftMargin:2];
    
    __weak typeof(self) me = self;
    if ( [self.params[@"item"][@"annexcount"] integerValue] > 0 ) {
        [self addRightItemWithTitle:@"查看附件" titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO)
                                                               }
                               size:CGSizeMake(84, 40)
                        rightMargin:2 callback:^{
                            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DocAttachmentListVC" params:@{ @"item": me.params[@"item"] ?: @{} }];
                            [me.navigationController pushViewController:vc animated:YES];
                        }];
    }
    
    BOOL isDoc = [self.params[@"item"][@"isdoc"] boolValue];
    if ( isDoc ) {
        [self startOnlinePreviewAttachment];
    } else {
        [self startLoadAttachment];
    }
}

- (void)startOnlinePreviewAttachment
{
    // http://weixin_gzh_hd.heneng.cn/op/embed.aspx
    
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    NSString *urlStr = self.params[@"item"][@"addr"];
    //        if ( [urlStr hasSuffix:@"docx"] ||
    //             [urlStr hasSuffix:@"doc"] ) {
    //            urlStr = [urlStr stringByAppendingPathComponent:@"contents"];
    //        }
    
    if ( urlStr.length == 0 ) {
        return;
    }
    
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"office/" withString:@"file/"];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"wopi/files/" withString:@""];
    
//    NSString *previewURL = [NSString stringWithFormat:@"%@%@",
//                            [self previewServerHost], urlStr];
    NSString *previewURL = [NSString stringWithFormat:@"http://erp20-mobiledoc.heneng.cn:16660/view/url?url=%@", [urlStr URLEncode]];
    NSLog(@"preview url: %@", previewURL);
    
    NSURL *url = [NSURL URLWithString:previewURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval = 60;
//    if ( [urlStr hasSuffix:@".ppt"]  ||
//         [urlStr hasSuffix:@".pptx"]
//        ) {
//        [self.previewWebView loadRequest:request];
//    } else {
        [self.previewWebView2 loadRequest:request];
//    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (NSString *)previewServerHost
{
    NSString *filename = [self.params[@"item"][@"addr"] lastPathComponent];
    if ( [filename hasSuffix:@"xls"] ||
         [filename hasSuffix:@"xlsx"] ) {
        return @"http://erp20-mobiledoc.heneng.cn:16665/x/_layouts/xlviewerinternal.aspx?WOPISrc=";
    } else if ( [filename hasSuffix:@"doc"] ||
                [filename hasSuffix:@"docx"] ) {
        return @"http://erp20-mobiledoc.heneng.cn:16665/wv/WordViewer/request.pdf?z=V0%2E0%2E1&type=printpdf&WOPIsrc=";
    } else if ( [filename hasSuffix:@"ppt"] ||
               [filename hasSuffix:@"pptx"]  ) {
        return @"http://erp20-mobiledoc.heneng.cn:16665/p/printhandler.ashx?PV=0&z=V0%2E0%2E1&Pid=WOPIsrc=";
        //@"http://erp20-mobiledoc.heneng.cn:16665/p/PowerPointFrame.aspx?PowerPointView=ChromelessView&WOPISrc=";
    } else if ( [filename hasSuffix:@"pdf"] ) {
        return @"http://erp20-mobiledoc.heneng.cn:16665/wv/wordviewerframe.aspx?embed=1&PdfMode=1&WOPISrc=";
    } else {
        return @"http://erp20-mobiledoc.heneng.cn:16665/wv/wordviewerframe.aspx?embed=1&WOPISrc=";
    }
}

- (void)close
{
    if ( ![self.params[@"item"][@"isdoc"] boolValue] ) {
        [self.previewController.view removeFromSuperview];
        [self.previewController removeFromParentViewController];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)back
{
    if ( ![self.params[@"item"][@"isdoc"] boolValue] ) {
        [self.previewController.view removeFromSuperview];
        [self.previewController removeFromParentViewController];
    }
    
//    [self.previewController.view removeFromSuperview];
//    [self.previewController removeFromParentViewController];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startLoadAttachment
{
    if ( [self.params[@"item"][@"addr"] description].length == 0 ) {
        [self.contentView showHUDWithText:@"附件不存在"
                                  succeed:NO];
        return;
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSString *attachFileUrl = self.params[@"item"][@"addr"];
    attachFileUrl = [attachFileUrl stringByAppendingPathComponent:@"contents"];
    
    self.downloadService = [[AttachmentDownloadService alloc] initWithURL:attachFileUrl];
        
    __weak typeof(self) me = self;
    [self.downloadService setCompletionBlock:^(NSURL *fileURL, NSError *error) {
        [me handleDownload:fileURL error:error];
    }];
    
    [self.downloadService startDownloadingToDirectory:nil];
}

- (void)handleDownload:(NSURL *)fileURL error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        [self.contentView makeToast:error.domain];
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [QLPreviewController canPreviewItem:fileURL] ) {
            [self updateReadStatus];
            self.attachmentURL = fileURL;
//            [self.previewController refreshCurrentPreviewItem];
        } else {
            [self.navigationController.view showHUDWithText:@"不能预览该文件" succeed:NO];
            
            self.attachmentURL = nil;
            
            self.previewController.view.hidden = YES;
        }
        
        [self.previewController reloadData];
        
        [self addChildViewController:self.previewController];
        
//        [self.previewController refreshCurrentPreviewItem];
    }
}

- (void)updateReadStatus
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"移动端公文标记已读",
                       @"param1": manID,
                       @"param2": self.params[@"item"][@"docid"] ?: @"0",
                       } completion:^(id result, NSError *error) {
                           //
                           if ( !error ) {
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"kDocHasReadedNotification" object:weakSelf.params[@"item"][@"docid"]];
                           }
                           
                       }];
}

- (QLPreviewController *)previewController
{
    if ( !_previewController ) {
        _previewController = [[QLPreviewController alloc] init];
        _previewController.dataSource = self;
        
        _previewController.currentPreviewItemIndex = 0;
        
        _previewController.view.frame = self.contentView.bounds;
        
//        [self addChildViewController:_previewController];
        [self.contentView addSubview:_previewController.view];
        
        [_previewController didMoveToParentViewController:self];
    }
    return _previewController;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    NSLog(@"url: %@", self.attachmentURL);
    return 1;//!!self.attachmentURL ? 1 : 0;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [self.attachmentURL copy];//[NSURL fileURLWithPath:self.attachmentURL.absoluteString];
    //[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test.xlsx" ofType:nil]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    [self updateReadStatus];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"redirect: %@", navigation);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    [self updateReadStatus];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
//    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

- (UIWebView *)previewWebView
{
    if ( !_previewWebView ) {
        _previewWebView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_previewWebView];
        
        _previewWebView.scalesPageToFit = YES;
        
        _previewWebView.delegate = self;
    }
    return _previewWebView;
}

- (WKWebView *)previewWebView2
{
    if ( !_previewWebView2 ) {
        _previewWebView2 = [[WKWebView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_previewWebView2];
        _previewWebView2.navigationDelegate = self;
    }
    return _previewWebView2;
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

@end

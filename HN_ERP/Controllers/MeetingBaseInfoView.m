//
//  MeetingBaseInfoView.m
//  HN_ERP
//
//  Created by tomwey on 7/28/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingBaseInfoView.h"
#import "Defines.h"

@interface MeetingBaseInfoView () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, assign) BOOL loading;

@end

@implementation MeetingBaseInfoView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.webView.frame = self.bounds;
}

- (void)setMeetingNotesData:(id)meetingNotesData
{
    if (_meetingNotesData == meetingNotesData) return;
    
    _meetingNotesData = meetingNotesData;
    
    [self loadMeetingDetail];
}

- (void)loadMeetingDetail
{
    if (self.loading) return;
    
    self.loading = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"会议纪要详情APP",
              @"param1": [self.meetingNotesData[@"id"] ?: @"0" description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.loading = NO;
    
    if (error) {
        [self showHUDWithText:error.localizedDescription succeed:NO];
    } else {
//        NSLog(@"%@", result);
        id item = [result[@"data"] firstObject];
        
        if ( item ) {
            [self fillContents:item];
        } else {
            [self showHUDWithText:@"未找到数据" succeed:NO];
        }
    }
    
    
//    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
}

- (void)fillContents:(id)item
{
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"meeting_base_info.html"
                                                                                              ofType:nil]
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${title}" withString:HNStringFromObject(item[@"title"], @"无")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${meetingType}" withString:HNStringFromObject(item[@"meet_typename"], @"--")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${meetingRoom}" withString:HNStringFromObject(item[@"mr_name"], @"--")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${dept}" withString:HNStringFromObject(item[@"manage_deptname"], @"--")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${meetingZC}" withString:HNStringFromObject(item[@"manage_name"], @"--")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${meetingTime}" withString:HNStringFromObject(item[@"orderdate"], @"--")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${joinMans}" withString:HNStringFromObject(item[@"man_names"], @"--")];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${meetingBody}" withString:[HNStringFromObject(item[@"meeting_result"], @"无") stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"]];
    
    NSString *annex_url = HNStringFromObject(item[@"annex_url"], @"");
    if ( annex_url.length > 0 ) {
        NSArray *annexs = [annex_url componentsSeparatedByString:@";"];
        if ( annexs.count == 0 ) {
            htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${attachments}" withString:@"无"];
        } else {
            NSMutableString *string = [NSMutableString string];
            NSInteger i = 0;
            for (NSString *url in annexs) {
                if ( url.length > 0 && [url hasPrefix:@"hnapp://open-file"] ) {
                        NSDictionary *queryParams = [[[url componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
//                    NSDictionary *params = [url queryDictionaryUsingEncoding:NSUTF8StringEncoding];
                    [string appendFormat:@"<li><a href=\"%@\">%d、%@</a></li>",url, ++i, queryParams[@"filename"]];
                }
                
            }
            
            if (string.length > 0) {
                htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${attachments}" withString:string];
            } else {
                htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${attachments}" withString:@"无"];
            }
        }
        
    } else {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"${attachments}" withString:@"无"];
    }
    
//    self.webView.hidden = YES;
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *url = [request.URL absoluteString];
        if ( [url hasPrefix:@"hnapp://open-file"] ) {
            // 打开附件
            [self openAttachment:url];
            return NO;
        }
        
        return YES;
    }
    return YES;
}

- (void)openAttachment:(NSString *)url
{
    NSDictionary *queryParams = [[[url componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
    
    // 打开相关附件
    NSDictionary *params = @{
                             @"addr": queryParams[@"file"] ?: @"",
                             @"filename": queryParams[@"filename"] ?: @"",
                             @"isdoc": queryParams[@"isdoc"] ?: @"0",
                             @"docid": queryParams[@"fileid"] ?: @"0",
                             };//[self parseAttachmentParamsForRequest:request];
    if ( params ) {
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": params }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
}

- (UIWebView *)webView
{
    if ( !_webView ) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
//        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor clearColor];
        [self addSubview:_webView];
    }
    return _webView;
}

@end

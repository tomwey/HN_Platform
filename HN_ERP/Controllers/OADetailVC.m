//
//  OADetailVC.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OADetailVC.h"
#import "Defines.h"
#import <WebKit/WebKit.h>

@interface OADetailVC () <UIWebViewDelegate,UIPopoverPresentationControllerDelegate,
    WKNavigationDelegate>

@property (nonatomic, strong) /*UIWebView*/WKWebView *webView;

@property (nonatomic, assign) BOOL openSuccess;

@property (nonatomic, weak) UIButton *commitBtn;
@property (nonatomic, weak) UIButton *moreBtn;

@property (nonatomic, weak) UIButton *undoBtn;

//@property (nonatomic, copy) NSArray *actions;

@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *nodeId;

@property (nonatomic, copy) NSString *curnodeid;

@property (nonatomic, strong) NSArray *audits;
@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSArray *requestAll;

@property (nonatomic, copy) NSString *nodeType;

@property (nonatomic, copy) NSString *opinionString;

@property (nonatomic, weak) UISegmentedControl *segControl;

@property (nonatomic, strong) HNLoadingView *loadingView;

@property (nonatomic, strong) NSArray *backNodes;
@property (nonatomic, strong) NSMutableArray *disableActions;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, weak)   UIAlertController *moreActionSheet;

@property (nonatomic, strong) NSMutableDictionary *htmlLoadTasks;

// 下一节点接收人与抄送人，在提交流程的时候需要弹出提示
@property (nonatomic, copy) NSString *getmannames;
@property (nonatomic, copy) NSString *ccmannames;

// 预览附件及文件
//@property (nonatomic, strong) AttachmentOperator *attachmentOperator;

@property (nonatomic, assign) BOOL fieldsRequired;

@property (nonatomic, copy) NSString *displayCss;

// 记录当前网页的滚动位置
@property (nonatomic, assign) CGPoint webViewScrollPosition;

// 保存意见是否为空的
@property (nonatomic, assign) BOOL opinionAllowNull;

@property (nonatomic, copy) NSString *createDate;

@property (nonatomic, assign) BOOL canUndo;

@end

@implementation OADetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navBar.title = @"提交流程";
    
    NSLog(@"%@", self.params[@"item"]);
    
    [self addLeftItemWithView:nil];
    
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    
    UIButton *backBtn = HNBackButton(24, self, @selector(back));
    [self.navBar addFluidBarItem:backBtn
                      atPosition:FluidBarItemPositionTitleLeft];
    
    if ( self.contentView.width <= 320 ) {
        backBtn.width = 34;
        backBtn.height = 34;
    }
    
    // 添加一个返回按钮，返回到最开始的流程详情
    if ( self.params[@"page"] ) {
        UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
        
        [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
        
        if ( self.contentView.width <= 320 ) {
            closeBtn.width = 34;
            closeBtn.height = 34;
        }
    }
    
    self.displayCss = @"display:none;";
    
    self.mid = [self.params[@"item"][@"mid"] description];
    
    self.curnodeid = [self.params[@"item"][@"cur_nodeid"] description];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.actions = @[@{
                         @"name": @"退回",
                         @"action": @"back",
                         },
                     @{
                         @"name": @"加签",
                         @"action": @"sign",
                         },
                     @{
                         @"name": @"流程复制",
                         @"action": @"flowcopy",
                         },
                     @{
                         @"name": @"转发查阅",
                         @"action": @"transmit",
                         },
                     @{
                         @"name": @"授权处理",
                         @"action": @"authorize",
                         },
                     @{
                         @"name": @"强制归档",
                         @"action": @"forceend",
                         },
                     ];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"流程详情", @"流程意见", @"流程图"]];
//    [self.contentView addSubview:control];
    control.frame = CGRectMake(0, 0, self.contentView.width * 0.60, 32);
    control.center = CGPointMake(self.contentView.width / 2, 30);
    control.selectedSegmentIndex = 0;
    control.tintColor = [UIColor whiteColor];
    
    self.navBar.titleView = control;
    
    [control addTarget:self
                action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.segControl = control;
    
    CGRect frame = CGRectMake(0, 0,
                              self.contentView.width, self.contentView.height);
    self.webView = [[/*UIWebView*/WKWebView alloc] initWithFrame:frame];
    [self.contentView addSubview:self.webView];
//    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = [UIColor clearColor];
//    self.webView.delegate = self;
    self.webView.navigationDelegate = self;
    
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.webViewScrollPosition = self.webView.scrollView.contentOffset;
    
    NSString *state = [self.params[@"state"] description];
    
    CGFloat height = 0;
    if ( [state isEqualToString:@"todo"] ) {
        UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                            50),
                                                 @"提交",
                                                 [UIColor whiteColor],
                                                 self,
                                                 @selector(commit));
        [self.contentView addSubview:commitBtn];
        commitBtn.backgroundColor = MAIN_THEME_COLOR;
        commitBtn.position = CGPointMake(0, self.contentView.height - 50);
        
        self.commitBtn = commitBtn;
        
        UIButton *moreBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                          50),
                                               @"更多",
                                               MAIN_THEME_COLOR,
                                               self,
                                               @selector(more));
        [self.contentView addSubview:moreBtn];
        
        self.moreBtn = moreBtn;
        
        moreBtn.backgroundColor = [UIColor whiteColor];
        moreBtn.position = CGPointMake(commitBtn.right, self.contentView.height - 50);
        
        UIView *hairLine = [AWHairlineView horizontalLineWithWidth:moreBtn.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:moreBtn];
        hairLine.position = CGPointMake(0,0);
        
        height = commitBtn.top;
    } else if ( [state isEqualToString:@"done"] ) {
        
//        __weak typeof(self) weakSelf = self;
        UIButton *btn = AWCreateImageButtonWithColor(@"icon_more.png", [UIColor whiteColor],
                                                      self,
                                                      @selector(doMore));
        btn.frame = CGRectMake(0, 0, 40, 40);
//        btn.backgroundColor = [UIColor redColor];
        [self addRightItemWithView:btn rightMargin:3];
        
//        self.undoBtn = (UIButton *)[self addRightItemWithTitle:@"撤回"
//                                   titleAttributes:
//  @{NSFontAttributeName: AWSystemFontWithSize(14, NO)}
//                                              size:
//                        CGSizeMake(40, 40) rightMargin:5 callback:^{
//                                   [weakSelf reback];
//                               }];
        
        height = self.contentView.height;
        
//        self.webView.scrollView.contentInset =
//        self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, rebackBtn.height + 20, 0);
    } else {
        height = self.contentView.height;
    }
    
    self.webView.height = height;
    
    // 默认进来先隐藏操作按钮
    self.webView.hidden = YES;
    [self hideOperButtons:YES animated:NO];
    
    // 提前加载流程意见和表单
//    [self startLoadOpinionWithType: 0];
    
    // 获取流程操作
    [self openFlow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshFlowPicture) name:@"kRefreshFlowPictureNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePopoverNotifi:)
                                                 name:@"kFlowPopoverDidDismissNotification"
                                               object:nil];
    
    [[SysLogService sharedInstance] logType:30
                                      keyID:[self.params[@"item"][@"mid"] integerValue]
                                    keyName:self.params[@"item"][@"flow_desc"]
                                    keyMemo:nil];
}

- (void)handlePopoverNotifi:(NSNotification *)noti
{
    NSString *val = [noti.object description];
    if ( [val isEqualToString:@"reback"] ) {
        [self reback];
    } else if ( [val isEqualToString:@"flowcopy"] ) {
        UIViewController *vc =
        [[AWMediator sharedInstance] openVCWithName:@"FlowcopyVC"
                                             params:@{
                                                      @"action": @{ @"action": @"flowcopy", @"name": @"流程复制" },
                                                      @"did": self.nodeId ?: @"",
                                                      @"nodeid": self.curnodeid ?: @"",
                                                      @"mid": self.mid ?: @"",
                                                      @"audits": self.audits ?: @[],
                                                      @"requests": self.requests ?: @[],
                                                      @"node_type": self.nodeType ?: @"",
                                                      @"item": self.params[@"item"] ?: @{},
                                                      @"backnodes": self.backNodes ?: @[],
                                                      @"required": @(self.fieldsRequired),
                                                      @"getmannames": self.getmannames ?: @"",
                                                      @"ccmannames": self.ccmannames ?: @"",
                                                      @"opinion_allow_null": @(self.opinionAllowNull)}];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backToPage
{
    id object = self.params[@"page"];
    if ( [object isKindOfClass:[UIViewController class]] ) {
        UIViewController *vc = (UIViewController *)object;
        [self.navigationController popToViewController:vc animated:YES];
    } else {
        NSLog(@"不是一个控制器对象");
    }
}

- (void)parseAndLoadHTML:(NSData *)data error:(NSError *)error
{
    self.commitBtn.enabled = self.moreBtn.enabled = !error;
    
    if ( error ) {
        NSLog(@"load html error: %@", error);
        if ( self.segControl.selectedSegmentIndex == 0 ) {
            self.loadingView.resultView.text = error.localizedDescription;
            [self.loadingView stopLoading:HNLoadingStateFail reloadCallback:nil];
        } else {
            [self.loadingView stopLoading:HNLoadingStateSuccessResult reloadCallback:nil];
        }
    } else {
        CGFloat scale = self.contentView.width * 0.95 / 533.0;
        
        NSString *htmlString = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000)];
        NSString *newHTMLString = [htmlString stringByReplacingOccurrencesOfString:@"initial-scale=0.59" withString:[NSString stringWithFormat:@"initial-scale=%.2f",
                                                                                                        scale]];
        if (self.opinionString.length > 0){
            newHTMLString = [newHTMLString stringByReplacingOccurrencesOfString:@"{$CONTENT}" withString:self.opinionString];
        } else {
            newHTMLString = [newHTMLString stringByReplacingOccurrencesOfString:@"{$CONTENT}" withString:@""];
        }

        [self.webView loadHTMLString:newHTMLString baseURL:nil];
    }
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (void)loadFlowForm
{
    // 取消所有的连接
    for (id taskId in self.htmlLoadTasks) {
        NSURLSessionTask *task = self.htmlLoadTasks[taskId];
        [task cancel];
    }
    
    [self.htmlLoadTasks removeAllObjects];
    
    [self.loadingView stopLoading:HNLoadingStateSuccessResult reloadCallback:nil];
    [self.loadingView startLoading];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/flow/%@/%@i.html", H5_HOST, self.createDate, self.mid]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = 20;
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong OADetailVC *strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *tempError = error;
            
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            if (resp.statusCode != 200) {
                tempError = [NSError errorWithDomain:@"此流程需在电脑端处理"
                                                code:resp.statusCode
                                            userInfo:@{ NSLocalizedDescriptionKey:@"此流程需在电脑端处理"  }];

            }
            
            if ( strongSelf ) {
                [strongSelf parseAndLoadHTML:data error:tempError];
            }
            
        });
        
    }];
    
    self.htmlLoadTasks[@(dataTask.taskIdentifier)] = dataTask;
    
    [dataTask resume];
}

- (void)controlValueChanged:(UISegmentedControl *)sender
{
    [self.loadingView stopLoading:HNLoadingStateSuccessResult reloadCallback:nil];
    
    self.webView.hidden = YES;
    
    self.displayCss = @"display:none;";
    if ( self.segControl.selectedSegmentIndex == 0 ) {
        // 加载流程意见和表单
        [self startLoadOpinionWithType: 0];
    } else {
        [self.loadingView startLoading];
        
        __weak typeof(self) me = self;
        if ( self.segControl.selectedSegmentIndex == 1 ) {
            // 流程意见
            [[self apiServiceWithName:@"APIService"]
             POST:nil params:@{
                               @"dotype": @"getopinion",
                               @"mid": self.mid,
                               @"detail": @"1",
                               } completion:^(id result, NSError *error) {
                                   [me handleDetailOpinion:result error:error];
                               }];
        } else {
            // 流程图
            [self.loadingView startLoading];
            
            [self refreshFlowPicture];
        }
    }
    
}

- (void)refreshFlowPicture
{
//    [self.loadingView startLoading];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"getflowmap",
                       @"mid": self.mid,
                       } completion:^(id result, NSError *error) {
                           [me handleFlowPicture:result error:error];
                       }];
}

- (NSString *)compOperStringForDict:(id)dict
{
    NSArray *names = [dict[@"domannames"] componentsSeparatedByString:@","];
    NSArray *ids = [dict[@"domanids"] componentsSeparatedByString:@","];
    NSMutableString *operString = [NSMutableString stringWithString:@"<div style=\"width: 70%;\">"];
    NSString *signdids = [dict[@"signdids"] description];
    
    NSArray *ssids = nil;
    if ( signdids.length > 0 ) {
        ssids = [signdids componentsSeparatedByString:@","];
    }
    
    for (int i=0; i<names.count; i++) {
        NSString *delString = @"";
        if (ssids && i < ssids.count) {
            delString = [NSString stringWithFormat:@"<span style=\"%@\">【<a href=\"hnapp://remove-sign?manid=%@&nodeid=%@\" style=\"color: #4472C4;text-decoration: none; font-size: 1em;font-weight:bold;\">删除</a>】</span>", self.displayCss, ssids[i], dict[@"nodeid"]];
        }
        [operString appendFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none; font-size: 1em;\">%@</a>%@,", ids[i], names[i], delString];
    }
    
    if (operString.length == 0) {
        return @"";
    }
    
    [operString deleteCharactersInRange:NSMakeRange(operString.length - 1, 1)];
    
    if ( dict[@"ccnames"] && [[dict[@"ccnames"] description] length] > 0 ) {
        NSMutableString *ccString = [NSMutableString string];
        
        NSArray *ccnames = [dict[@"ccnames"] componentsSeparatedByString:@","];
        NSArray *ccids   = [dict[@"ccids"] componentsSeparatedByString:@","];
        NSInteger count = MIN(ccids.count, ccnames.count);
        
        if ( count > 0 ) {
            [ccString appendString:@"<span style=\"font-weight:bold;\">抄送:</span>"];
            for (int i=0; i<count; i++) {
                [ccString appendFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none; font-size: 1em;\">%@</a>,", ccids[i], ccnames[i]];
            }
            [ccString deleteCharactersInRange:NSMakeRange(ccString.length - 1, 1)];
            
            [operString appendString:@" "];
            [operString appendString:ccString];
        }
        
    }
    
    [operString appendString:@"</div>"];
    
    return [operString copy];
}

- (void)handleFlowPicture:(id)result error:(NSError *)error
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
//        [self.contentView makeToast:error.domain];
        self.loadingView.resultView.text = error.domain;
        [self.loadingView stopLoading:HNLoadingStateFail reloadCallback:nil];
    } else {
        
        NSString *htmlFormatString = @"<div class=\"timeline-row\">\
        %@ \
        <div class=\"timeline-body %@ %@\"><span class=\"note-item\">%@%@</span><h2>%@</h2>%@</div>\
        %@ \
        </div>";
        
        NSString *newHTMLString = nil;
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            NSArray *data = result[@"data"];
            
                // 拼网页字符串
                NSMutableString *htmlString = [NSMutableString string];
                for (int i=0; i<data.count; i++) {
                    id dict = data[i];
                    
                    NSString *clsName = nil;
                    NSString *header  = nil;
                    NSString *footer  = nil;
                    
                    if ( i == 0 ) {
                        header = @"<div class=\"mask top-pos\"></div>";
                    } else {
                        header = @"";
                    }
                    
                    if ( i == data.count - 1 ) {
                        footer = @"<div class=\"mask bottom-pos\"></div>";
                    } else {
                        footer = @"";
                    }
                    
                    if ( [dict[@"iscurnode"] integerValue] == 0 ) {
                        clsName = @"current";
                    } else if ( [dict[@"iscurnode"] integerValue] == 1 ) {
                        clsName = @"done";
                    } else {
                        clsName = @"pending";
                    }
                    
                    NSString *cssName2 = nil;
                    if ( data.count == 1 ) {
                        cssName2 = @"timeline-body-no-border";
                    } else {
                        cssName2 = @"";
                    }
                    
                    NSString *addSign = @"";
                    if ( [dict[@"allowsign"] boolValue] ) {
                        addSign = [NSString stringWithFormat:@"<br><a class=\"btn custom-btn\" href=\"hnapp://add-sign?nodeid=%@\" style=\"%@\">加签 ↓</a>", dict[@"nodeid"] ?: @"0", self.displayCss];
                    }
                    
                    [htmlString appendFormat:htmlFormatString, header, clsName, cssName2, dict[@"nodetype"], addSign, dict[@"nodename"], [self compOperStringForDict:dict], footer];
//                    } // end if
                } // end for
                
                newHTMLString = [htmlString copy];
//            } // end if
            
            if ( newHTMLString.length > 0 ) {
                
                NSString *newHTML = [NSString stringWithContentsOfFile:
                                           [[NSBundle mainBundle] pathForResource:@"flowd.tpl" ofType:nil]
                                                                    encoding:NSUTF8StringEncoding error:nil];
                newHTML = [newHTML stringByReplacingOccurrencesOfString:@"{{content}}" withString:newHTMLString];
                
                [self.webView loadHTMLString:newHTML baseURL:nil];
            } else {
                self.loadingView.resultView.text = LOADING_REFRESH_NO_RESULT;
                [self.loadingView stopLoading:HNLoadingStateFail reloadCallback:nil];
            } // end if
        }
    }
        
}

- (void)handleDetailOpinion:(id)result error:(NSError *)error
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
//        [self.contentView makeToast:@"加载出错了"];
        self.loadingView.resultView.text = error.domain;
        [self.loadingView stopLoading:HNLoadingStateFail reloadCallback:nil];
    } else {
        if ([result[@"rowcount"] integerValue] == 0) {
//            [self.contentView makeToast:@"没有意见"];
            self.loadingView.resultView.text = LOADING_REFRESH_NO_RESULT;
            [self.loadingView stopLoading:HNLoadingStateEmptyResult reloadCallback:nil];
        } else {
            NSArray *data = result[@"data"];
            NSMutableString *htmlString = [NSMutableString string];
            for (id dict in data) {
                NSString *nodeName = dict[@"node_name"];
                
                NSString *action = dict[@"operationtype"];
                
                
                NSString *time = dict[@"dotime"];
                time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//                time = [time substringToIndex:time.length - 9];
                if (time.length > 9) {
                    time = [time substringToIndex:time.length - 9];
                }
                
                NSInteger doType = [dict[@"dotype"] integerValue];
                NSString *manString = nil;
                if ( doType == 2 ) {
                    // 授权
                    manString = [NSString stringWithFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none;\">%@</a><b>授权</b><a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none;\">%@</a>&nbsp;%@<br>%@", dict[@"src_manid"], dict[@"src_manname"],dict[@"domanid"], dict[@"domanname"], action, time];
                } else if ( doType == 3 ) {
                    // 代
                    manString = [NSString stringWithFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none;\">%@</a>(<b>代</b><a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none;\">%@</a>)&nbsp;%@<br>%@", dict[@"domanid"], dict[@"domanname"], dict[@"src_manid"], dict[@"src_manname"], action, time];
                } else {
                    manString = [NSString stringWithFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"color: #4472C4;text-decoration: none;\">%@</a>&nbsp;%@<br>%@", dict[@"domanid"], dict[@"domanname"], action, time];
                }
                
                NSString *opinion = dict[@"opinion"];
                if ([opinion length] == 0 ||
                    [opinion isEqualToString:@"NULL"]) {
                    opinion = @"无";
                }
                
                NSString *isAgree = [dict[@"isagree"] description];
                if ( isAgree.length == 0 || [isAgree isEqualToString:@"NULL"] ) {
                    
                } else {
//                    if ( [[dict[@"opinion"] description] length] > 0 &&
//                        ![[dict[@"opinion"] description] isEqualToString:@"NULL"]) {
//                        if ( [isAgree isEqualToString:@"0"] ) {
//                            // 不同意
//                            opinion = [NSString stringWithFormat:@"<span style=\"color:black;\">不同意：</span>%@", opinion];
//                        } else if ( [isAgree isEqualToString:@"1"] ) {
//                            // 同意
//                            opinion = [NSString stringWithFormat:@"<span style=\"color:black;\">同意：</span>%@", opinion];
//                        } else {
//                            opinion = dict[@"opinion"];
//                        }
//                    }
                    
                }
                
                NSString *receiver = dict[@"getmannames"];
                
                NSString *format = @"<tr>"
                                    @"<td width=\"20%%\">%@</td>"
                                    @"<td width=\"25%%\">%@</td>"
                                    @"<td width=\"40%%\">%@%@%@</td>"
                                    @"<td width=\"15%%\">%@</td>"
                                    @"</tr>";
                
                NSString *attachmentStrings = @"";
                
                if ( [dict[@"url"] description].length > 0 &&
                    ![[dict[@"url"] description] isEqualToString:@"NULL"]) {
                    NSArray *attachmentLinks = [[dict[@"url"] description] componentsSeparatedByString:@","];
                    NSMutableString *string = [NSMutableString stringWithString:@"<br /><br />"];
                    for (NSString *link in attachmentLinks) {
                        NSDictionary *queryParams = [[[link componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
                        [string appendFormat:@"<a href=\"%@\" style=\"color: #4472C4;word-break:break-all;word-wrap:break-word;\">%@</a><br />",
                         link, queryParams[@"filename"] ?: @""];
                    }
                    attachmentStrings = [string copy];
                }
                
                NSString *platformString = @"";
                if ( [dict[@"platformtypec"] description].length > 0 &&
                    ![[dict[@"platformtypec"] description] isEqualToString:@"NULL"]) {
                    platformString = [NSString stringWithFormat:@"<br /><br /><small style=\"color: rgb(110,110,110);\">来自 %@</small>", dict[@"platformtypec"]];
                }

                
                [htmlString appendFormat:format, nodeName, manString, opinion,attachmentStrings,platformString, receiver];
            }
            
            NSString *newHtml = [NSString stringWithContentsOfFile:
                                 [[NSBundle mainBundle] pathForResource:@"opinion.tpl" ofType:nil]
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
            newHtml = [newHtml stringByReplacingOccurrencesOfString:@"{{content}}" withString:htmlString];
            
            [self.webView loadHTMLString:newHtml baseURL:nil];
        }
    }
}

- (void)openFlow
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    [self.loadingView startLoading];
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{ @"dotype": @"openflow",
               @"mid": self.mid,
               @"manid": manID,
               } completion:^(id result, NSError *error) {
                   [me handleResult: result error: error];
               }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [self.loadingView stopLoading:HNLoadingStateSuccessResult reloadCallback:nil];
    if ( error ) {
        self.openSuccess = NO;
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( result[@"openinfo"] && [[result[@"openinfo"] description] length] > 0 )
        {
            [self.contentView showHUDWithText:[result[@"openinfo"] description]
                                      succeed:NO];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kMarkFlowReadNotification" object:self.params[@"item"]];
        // 显示操作按钮
        BOOL readonly = [result[@"readonly"] boolValue];
        if ( !readonly ) {
            [self hideOperButtons:NO animated:YES];
        }
        
        self.opinionAllowNull = [result[@"opinionallownull"] boolValue];
        
        self.getmannames = result[@"getmannames"];
        self.ccmannames = result[@"ccmannames"];
        
        // 处理操作状态
        [self handleOperationState:result];
        
        self.createDate = HNDateFromObject(result[@"create_date"], @"T");
        
        // 加载流程意见和表单
        [self startLoadOpinionWithType: 0];
    }
}

- (void)hideOperButtons:(BOOL)yesOrNo animated:(BOOL)animated
{
    CGFloat top = yesOrNo ? self.contentView.height : self.contentView.height - self.commitBtn.height;
    if ( animated ) {
        [UIView animateWithDuration:.25 animations:^{
            self.commitBtn.top = self.moreBtn.top = top;
            self.webView.height = top;
        }];
    } else {
        self.commitBtn.top = self.moreBtn.top = top;
        self.webView.height = top;
    }
}

- (void)startLoadOpinionWithType: (NSInteger)type
{
    [self.loadingView startLoading];
//    [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"getopinion",
                       @"mid": self.mid,
                       @"detail": [@(type) description],
                       } completion:^(id result, NSError *error) {
//                           NSLog(@"result: %@", result);
                           [me handleOpinion:result error:error];
                       }];
}

- (void)generateOpinionForResult:(id)result
{
    NSArray *data = result[@"data"];
    NSMutableString *string = [NSMutableString stringWithString:@"<div style=\"height: 30px; line-height: 30px; text-align:center; margin-top: 7px; background-color: rgb(242,242,242); color: rgb(97,94,94); font-size: 15px; font-weight: bold; border: 1px solid #D7D6D6;border-bottom:0;\">主要意见</div><table style=\"border: 1px solid rgb(205,205,205);width: 100%; border-spacing: 0; border-collapse: collapse;color: black;margin-bottom: 10px;\">"];
    for (id dict in data) {
        NSString *td = @"<tr><td style=\"padding: 5px; width: 80px; color: rgb(97,94,94); font-size: 14px; font-weight: bold; border: 1px solid rgb(205,205,205)\">%@</td><td style=\"padding: 5px;width: 120px;border: 1px solid rgb(205,205,205)\">%@<br>%@</td><td style=\"padding: 5px; border: 1px solid rgb(205,205,205)\">%@%@%@</td></tr>";
        
        // 处理意见
        NSString *opinion = dict[@"opinion"];
        if ([opinion length] == 0 ||
            [opinion isEqualToString:@"NULL"]) {
            opinion = @"无";
        }
        
//        NSString *isAgree = [dict[@"isagree"] description];
//        if ( [[dict[@"opinion"] description] length] > 0 &&
//            ![[dict[@"opinion"] description] isEqualToString:@"NULL"]) {
//            
//            if ( [isAgree isEqualToString:@"0"] ) {
//                // 不同意
//                opinion = [NSString stringWithFormat:@"<span style=\"color:black;\">不同意：</span>%@", opinion];
//            } else if ( [isAgree isEqualToString:@"1"] ) {
//                // 同意
//                opinion = [NSString stringWithFormat:@"<span style=\"color:black;\">同意：</span>%@", opinion];
//            } else {
//                opinion = dict[@"opinion"];
//            }
//        }
        
        // 处理时间
        NSString *time = dict[@"dotime"];
        time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        if (time.length > 9) {
            time = [time substringToIndex:time.length - 9];
        }
        
        // 处理操作人
        NSInteger doType = [dict[@"dotype"] integerValue];
        NSString *manString = nil;
        if ( doType == 2 ) {
            // 授权
            manString = [NSString stringWithFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"\">%@</a><b>授权</b><a href=\"hnapp://open-card?manid=%@\" style=\"\">%@</a>", dict[@"src_manid"], dict[@"src_manname"], dict[@"domanid"], dict[@"domanname"]];
        } else if ( doType == 3 ) {
            // 代
            manString = [NSString stringWithFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"\">%@</a>(<b>代</b><a href=\"hnapp://open-card?manid=%@\" style=\"\">%@</a>)", dict[@"domanid"], dict[@"domanname"], dict[@"src_manid"], dict[@"src_manname"]];
        } else {
            manString = [NSString stringWithFormat:@"<a href=\"hnapp://open-card?manid=%@\" style=\"\">%@</a>", dict[@"domanid"], dict[@"domanname"]];
        }
        
        NSString *attachmentStrings = @"";
        
        if ( [dict[@"url"] description].length > 0 &&
             ![[dict[@"url"] description] isEqualToString:@"NULL"]) {
            NSArray *attachmentLinks = [[dict[@"url"] description] componentsSeparatedByString:@","];
            NSMutableString *string = [NSMutableString stringWithString:@"<br /><br />"];
            for (NSString *link in attachmentLinks) {
                NSDictionary *queryParams = [[[link componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
                [string appendFormat:@"<a href=\"%@\" style=\"word-break: break-all;word-wrap:break-word;color: #4472C4;\">%@</a><br />",
                 link, queryParams[@"filename"] ?: @""];
            }
            attachmentStrings = [string copy];
        }
        
        NSString *platformString = @"";
        if ( [dict[@"platformtypec"] description].length > 0 &&
            ![[dict[@"platformtypec"] description] isEqualToString:@"NULL"]) {
            platformString = [NSString stringWithFormat:@"<br /><br /><small style=\"color: rgb(110,110,110);\">来自 %@</small>", dict[@"platformtypec"]];
        }
        
        NSString *tdVal = [NSString stringWithFormat:td, dict[@"node_name"],
                           manString,time, opinion, attachmentStrings, platformString];
        
        [string appendString:tdVal];
    }
    
    [string appendString:@"</table>"];
    
    self.opinionString = string;
    
    NSLog(@"string: %@", string);
}

- (void)handleOpinion:(id)result error:(NSError *)error
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
        [self generateOpinionForResult:result];
    }
    
    [self loadFlowForm];
}

- (void)handleOperationState:(id)result
{
    self.nodeId = [result[@"curdid"] description];
    
    self.curnodeid = [result[@"cur_nodeid"] description];
    
    self.fieldsRequired = [result[@"existnotnull"] boolValue];
    
    NSInteger doType = [result[@"dotype"] integerValue];
    if ( doType == 1 ) {
        [self.commitBtn setTitle:@"批注" forState:UIControlStateNormal];
    } else {
        [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    }
    
    // 保存一部分值
    self.nodeType = [result[@"node_type"] description];
    
//    if ( [result[@"rowcount"] integerValue] > 0 ) {
//        self.audits = result[@"data"];
//    }
    if ( result[@"audit"] && [result[@"audit"] isKindOfClass:[NSArray class]] ) {
        self.audits = result[@"audit"];
    }

    // 请示批复项目
//    self.requests = result[@"request"] ?: @[];
    if ( result[@"request"] && [result[@"request"] isKindOfClass:[NSArray class]] ) {
        self.requests = result[@"request"];
    }
    
    if ( result[@"requestall"] && [result[@"requestall"] isKindOfClass:[NSArray class]] ) {
        self.requestAll = result[@"requestall"];
    }
    
    // 权限处理
    [self handleOperAccess:result];
}

- (void)handleOperAccess:(id)result
{
    // 处理撤回权限
    BOOL flag = [result[@"canundo"] boolValue];
    self.canUndo = flag;
    
    if ( !flag ) {
        self.undoBtn.enabled = NO;
        self.undoBtn.alpha   = 0.5;
    } else {
        self.undoBtn.enabled = YES;
        self.undoBtn.alpha   = 1.0;
    }
    
    // 处理待办流程里面的更多操作权限
    BOOL needLoadBackList = NO;
    for (id action in self.actions) {
        NSString *actionName = [action[@"action"] description];
        if ( [actionName isEqualToString:@"authorize"] ) {
            actionName = @"grant";
        } else if ( [actionName isEqualToString:@"transmit"] ) {
            actionName = @"zfcy";
        }
        
        NSString *canKey = [NSString stringWithFormat:@"can%@", actionName];
        BOOL flag = [result[canKey] boolValue];
        
        if ( !flag && ![actionName isEqualToString:@"flowcopy"] ) {
            [self.disableActions addObject:action];
        } else {
            if ( [actionName isEqualToString:@"back"] ) {
                needLoadBackList = YES;
            }
        }
        /*
        if ( [actionName isEqualToString:@"back"] ) {
            [self.disableActions addObject:action];
        } else {
            // 特殊处理退回
            if ( !flag ) {
                [self.disableActions addObject:action];
            } else {
                needLoadBackList = YES;
            }
        }*/
    }
    
    if ( needLoadBackList ) {
        [self loadBackListIfNeeded];
    } else {
        [self updateMoreOperState];
    }
    
}

- (void)loadBackListIfNeeded
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"flowbacklist",
              @"manid": manID,
              @"mid": self.mid,
              } completion:^(id result, NSError *error) {
//                  [me handleResult: result error: error];
                  [me handleFlowback:result error:error];
              }];
}

- (void)handleFlowback:(id)result error:(NSError *)error
{
    if ( error ) {
        [self.disableActions addObject:[self.actions firstObject] ?: @{}];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.disableActions addObject:[self.actions firstObject] ?: @{}];
        } else {
            self.backNodes = result[@"data"];
        }
    }
    
    // 如果打开了more里面的功能
    [self updateMoreOperState];
}

- (UIAlertAction *)alertActionForTitle:(NSString *)title
{
    if ( !self.moreActionSheet ) return nil;
    for (UIAlertAction *action in self.moreActionSheet.actions) {
        if ( [action.title isEqualToString:title] ) {
            return action;
        }
    }
    return nil;
}

- (void)updateMoreOperState
{
    if ( self.moreActionSheet ) {
        for (id action in self.disableActions) {
            UIAlertAction *alertAction = [self alertActionForTitle:action[@"name"]];
            alertAction.enabled = NO;
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.webView.hidden = NO;
    
    self.openSuccess = YES;
    
    if ( [self.params[@"state"] isEqualToString:@"done"] ) {
        self.webView.scrollView.contentInset =
        self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 60, 0);
    }
    
    // 保持网页的滚动位置
    if ( self.segControl.selectedSegmentIndex == 2 ) {
        self.webView.scrollView.contentOffset = self.webViewScrollPosition;
    } else {
        self.webView.scrollView.contentOffset = CGPointZero;
    }
    
    [self.loadingView stopLoading:HNLoadingStateSuccessResult reloadCallback:nil];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( self.requestAll.count > 0 ) {
        // 植入请示批复的内容
        NSMutableString *string = [NSMutableString stringWithString:@"<table><tr><th>请示批复事项</th><th>批复人</th><th>是否同意</th><th>意见</th></tr>"];
        for (id dict in self.requestAll) {
            [string appendFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td></tr>", dict[@"itemname"], dict[@"man_name"], dict[@"isagree"],
             dict[@"memo"]];
        }
        [string appendString:@"</table>"];
        
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByClassName('cxgrid')[0].innerHTML='%@';", string];
//        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
        [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    self.webView.hidden = NO;
//    
//    self.openSuccess = YES;
//    
//    if ( [self.params[@"state"] isEqualToString:@"done"] ) {
//        self.webView.scrollView.contentInset =
//        self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 60, 0);
//    }
//    
//    // 保持网页的滚动位置
//    if ( self.segControl.selectedSegmentIndex == 2 ) {
//        self.webView.scrollView.contentOffset = self.webViewScrollPosition;
//    } else {
//        self.webView.scrollView.contentOffset = CGPointZero;
//    }
//    
//    [self.loadingView stopLoading:HNLoadingStateSuccessResult reloadCallback:nil];
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//    
//    if ( self.requestAll.count > 0 ) {
//        // 植入请示批复的内容
//        NSMutableString *string = [NSMutableString stringWithString:@"<table><tr><th>请示批复事项</th><th>批复人</th><th>是否同意</th><th>意见</th></tr>"];
//        for (id dict in self.requestAll) {
//            [string appendFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td></tr>", dict[@"itemname"], dict[@"man_name"], dict[@"isagree"],
//             dict[@"memo"]];
//        }
//        [string appendString:@"</table>"];
//        
//        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByClassName('cxgrid')[0].innerHTML='%@';", string];
//        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
//    }
}

- (NSDictionary *)parseAttachmentParamsForRequest:(NSURLRequest *)request
{
    NSString *url = [request.URL absoluteString];
    NSString *base64String = [[[url componentsSeparatedByString:@"?file="] lastObject] description];
    
    NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSError *error = nil;
    NSDictionary *decryptFileinfo = [NSJSONSerialization JSONObjectWithData:base64Data options:0 error:&error];
    
    if ( error ) {
        [self.contentView showHUDWithText:@"获取附件信息出错" offset:CGPointMake(0, 20)];
        return nil;
    } else {
        NSLog(@"file info: %@", decryptFileinfo);
        return decryptFileinfo;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    
    if ( navigationAction.navigationType == WKNavigationTypeLinkActivated ||
        [[request.URL absoluteString] hasPrefix:@"hnapp://"] ) {
        // 打开人员卡片
        //        queryDictionaryUsingEncoding
        NSDictionary *queryParams = [[[[request.URL absoluteString] componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
        
        if ( [[request.URL absoluteString] hasPrefix:@"hnapp://open-card"] ) {
            // 打开人员信息
            NSString *manID = queryParams[@"manid"];
            //        hnapp://open-card?manid=1691909
            if ( manID ) {
                //            [self openCardForManID:manID];
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MancardVC" params:@{ @"manid": manID }];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://open-flow"] ) {
            // 打开相关流程
            NSString *mid = queryParams[@"mid"];
            //        hnapp://open-card?manid=1691909
            if ( mid ) {
                //            [self openCardForManID:manID];
                __weak typeof(self) weakSelf = self;
                UIViewController *vc =
                [[AWMediator sharedInstance] openVCWithName:@"OADetailVC"
                                                     params:@{
                                                              @"page": self.params[@"page"] ?: weakSelf,
                                                              @"item": @{
                                                                      @"mid": mid,
                                                                      @"cur_nodeid": self.curnodeid ?: @""
                                                                      }
                                                              }];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://open-file"] )
        {
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
            
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://add-sign"] ) {
            // 加签
            self.webViewScrollPosition = self.webView.scrollView.contentOffset;
            
            NSString *nodeid = queryParams[@"nodeid"];
            NSLog(@"nodeid: %@", nodeid);
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AddSignVC" params:@{ @"nodeid": nodeid ?: @"", @"mid": self.mid ?: @"0" }];
            [self presentViewController:vc animated:YES completion:nil];
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://remove-sign"] ) {
            // 删除加签
            self.webViewScrollPosition = self.webView.scrollView.contentOffset;
            
            NSString *nodeid = queryParams[@"nodeid"];
            NSString *signid = queryParams[@"manid"];
            NSLog(@"nodeid: %@, sid: %@", nodeid, signid);
            
            [self removeSign:signid];
        } else {
            [[MBProgressHUD appearance] setContentColor:MAIN_THEME_COLOR];
            [self.contentView showHUDWithText:@"不能打开该资源" succeed:NO];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request: %@", request);
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ||
         [[request.URL absoluteString] hasPrefix:@"hnapp://"] ) {
        // 打开人员卡片
//        queryDictionaryUsingEncoding
        NSDictionary *queryParams = [[[[request.URL absoluteString] componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
        
        if ( [[request.URL absoluteString] hasPrefix:@"hnapp://open-card"] ) {
            // 打开人员信息
            NSString *manID = queryParams[@"manid"];
            //        hnapp://open-card?manid=1691909
            if ( manID ) {
                //            [self openCardForManID:manID];
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MancardVC" params:@{ @"manid": manID }];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://open-flow"] ) {
            // 打开相关流程
            NSString *mid = queryParams[@"mid"];
            //        hnapp://open-card?manid=1691909
            if ( mid ) {
                //            [self openCardForManID:manID];
                __weak typeof(self) weakSelf = self;
                UIViewController *vc =
                    [[AWMediator sharedInstance] openVCWithName:@"OADetailVC"
                                                         params:@{
                                                                  @"page": self.params[@"page"] ?: weakSelf,
                                                                  @"item": @{
                                                                          @"mid": mid,
                                                                          @"cur_nodeid": self.curnodeid ?: @""
                                                                          }
                                                                  }];
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://open-file"] )
        {
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
            
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://add-sign"] ) {
            // 加签
            self.webViewScrollPosition = self.webView.scrollView.contentOffset;
            
            NSString *nodeid = queryParams[@"nodeid"];
            NSLog(@"nodeid: %@", nodeid);
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AddSignVC" params:@{ @"nodeid": nodeid ?: @"", @"mid": self.mid ?: @"0" }];
            [self presentViewController:vc animated:YES completion:nil];
        } else if ( [[request.URL absoluteString] hasPrefix:@"hnapp://remove-sign"] ) {
            // 删除加签
            self.webViewScrollPosition = self.webView.scrollView.contentOffset;
            
            NSString *nodeid = queryParams[@"nodeid"];
            NSString *signid = queryParams[@"manid"];
            NSLog(@"nodeid: %@, sid: %@", nodeid, signid);
            
            [self removeSign:signid];
        } else {
            [[MBProgressHUD appearance] setContentColor:MAIN_THEME_COLOR];
            [self.contentView showHUDWithText:@"不能打开该资源" succeed:NO];
        }
        
        return NO;
    }
    return YES;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    self.openSuccess = NO;
    
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    [self.contentView makeToast:error.domain];
    self.loadingView.resultView.text = error.domain;
    [self.loadingView stopLoading:HNLoadingStateFail reloadCallback:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.openSuccess = NO;
    
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    [self.contentView makeToast:error.domain];
    self.loadingView.resultView.text = error.domain;
    [self.loadingView stopLoading:HNLoadingStateFail reloadCallback:nil];
}

- (void)removeSign:(NSString *)nodeid
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"删除加签APP",
              @"param1": manID,
              @"param2": nodeid,
              }completion:^(id result, NSError *error) {
                  [me handleRemoveSign:result error:error];
              }];
}

- (void)handleRemoveSign:(id)result error:(NSError *)error
{
    if ( error ) {
         [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshFlowPicture];
//        });
    }
}

- (void)handleAction: (id)action
{
    if ( !action ) {
        return;
    }
    
    // 加签处理
    if ( [action[@"action"] isEqualToString:@"sign"] ) {
        // 跳到流程图页面
        self.webView.hidden = YES;
        self.webViewScrollPosition = CGPointZero;
        
        self.segControl.selectedSegmentIndex = 2;
        
        self.displayCss = @"";
        
        [self.loadingView startLoading];
        
        [self refreshFlowPicture];
        
        return;
    }
    
    // 强制归档处理
    if ( [action[@"action"] isEqualToString:@"forceend"] ) {
        // 处理强制归档
        [self forceEndFlow];
        return;
    }
    
    // 退回处理
    if ( [action[@"action"] isEqualToString:@"back"] ) {
        if ( [self.backNodes count] == 0 ) {
//            [self.contentView makeToast:@"退回节点还未准备好"];
            [self.contentView showHUDWithText:@"退回节点还未准备好"];
            return;
        }
    }
    
    NSString *vcName = [[action[@"action"] capitalizedString] stringByAppendingString:@"VC"];
    UIViewController *vc =
    [[AWMediator sharedInstance] openVCWithName:vcName
                                         params:@{
                                                  @"action": action,
                                                  @"did": self.nodeId ?: @"",
                                                  @"nodeid": self.curnodeid ?: @"",
                                                  @"mid": self.mid ?: @"",
                                                  @"audits": self.audits ?: @[],
                                                  @"requests": self.requests ?: @[],
                                                  @"node_type": self.nodeType ?: @"",
                                                  @"item": self.params[@"item"] ?: @{},
                                                  @"backnodes": self.backNodes ?: @[],
                                                  @"required": @(self.fieldsRequired),
                                                  @"getmannames": self.getmannames ?: @"",
                                                  @"ccmannames": self.ccmannames ?: @"",
                                                  @"opinion_allow_null": @(self.opinionAllowNull)}];
    [self.navigationController pushViewController:vc animated:YES];
//    }
}

- (void)forceEndFlow
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak OADetailVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"强制归档",
                       @"param1": self.mid ?: @"",
                       @"param2": manID,
                       } completion:^(id result, NSError *error) {
                           [weakSelf handleForceEnd:result error:error];
                       }];
}

- (void)handleForceEnd:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        [self.navigationController.view showHUDWithText:@"强制归档成功" succeed:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowHandleSuccessNotification" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doMore
{
    NSDictionary *params = @{
                             @"canundo": @(self.canUndo),
                             @"did": self.nodeId ?: @"",
                             @"nodeid": self.curnodeid ?: @"",
                             @"mid": self.mid ?: @"",
                             @"audits": self.audits ?: @[],
                             @"requests": self.requests ?: @[],
                             @"node_type": self.nodeType ?: @"",
                             @"item": self.params[@"item"] ?: @{},
                             @"backnodes": self.backNodes ?: @[],
                             @"required": @(self.fieldsRequired),
                             @"getmannames": self.getmannames ?: @"",
                             @"ccmannames": self.ccmannames ?: @"",
                             @"opinion_allow_null": @(self.opinionAllowNull)};
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OAPopoverVC" params:params];
    
    vc.preferredContentSize = CGSizeMake(94, 80);
    
    vc.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popoverController = [vc popoverPresentationController];
    popoverController.delegate = self;
    
    popoverController.backgroundColor = AWColorFromRGBA(0, 0, 0, 0.9);
    popoverController.sourceView = self.navBar.rightItem;
    popoverController.sourceRect = self.navBar.rightItem.bounds;
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

//- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
//{
//    return self.navigationController;
//}

- (void)reback
{
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"您确定要撤回该流程吗？"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"取消"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *doneAction =
        [UIAlertAction actionWithTitle:@"确定"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doReback];
    }];
    [alert addAction:doneAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doReback
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak OADetailVC *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"强制收回APP",
                       @"param1": self.mid ?: @"",
                       @"param2": manID,
                       } completion:^(id result, NSError *error) {
                           [weakSelf handleReback:result error:error];
                       }];
}

- (void)handleReback:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            id dict = [result[@"data"] firstObject];
            if ( [dict[@"code"] integerValue] == 1 ) {
                [self.contentView showHUDWithText:dict[@"message"] succeed:NO];
            } else {
                [self.navigationController.view showHUDWithText:@"强制收回成功" succeed:YES];
                [self.navigationController popViewControllerAnimated:YES];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowHandleSuccessNotification" object:nil];
                });
            }
        }
    }
}

- (void)commit
{
    id action = nil;
    if ( [[self.commitBtn currentTitle] isEqualToString:@"批注"] ) {
        action = @{@"name": @"批注", @"action": @"comment"};
    } else {
        action = @{@"name": @"提交", @"action": @"submit"};
    }
    
    [self handleAction:action];
}

- (void)more
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.moreActionSheet = actionSheet;
    
    for (id actionData in self.actions) {
        UIAlertAction *alertAction = nil;
        alertAction =  [UIAlertAction actionWithTitle:actionData[@"name"]
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action)
            {
                [self handleAction:actionData];
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
        
        if ( [self.disableActions containsObject:actionData] ) {
            alertAction.enabled = NO;
        } else {
            alertAction.enabled = YES;
        }
        
        [actionSheet addAction:alertAction];
    }
    
    // 添加取消
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

//- (AttachmentOperator *)attachmentOperator
//{
//    if ( !_attachmentOperator ) {
//        _attachmentOperator = [[AttachmentOperator alloc] init];
//        _attachmentOperator.previewController = self;
//    }
//    return _attachmentOperator;
//}

- (NSMutableArray *)disableActions
{
    if ( !_disableActions ) {
        _disableActions = [[NSMutableArray alloc] init];
    }
    return _disableActions;
}

- (HNLoadingView *)loadingView
{
    if ( !_loadingView ) {
        _loadingView = [[HNLoadingView alloc] init];
        [self.contentView addSubview:_loadingView];
        _loadingView.frame = self.webView.frame;
//        _loadingView.backgroundColor = self.contentView.backgroundColor;
    }
    
    [self.contentView bringSubviewToFront:_loadingView];
    
    return _loadingView;
}

- (NSMutableDictionary *)htmlLoadTasks
{
    if ( !_htmlLoadTasks ) {
        _htmlLoadTasks = [[NSMutableDictionary alloc] init];
    }
    return _htmlLoadTasks;
}

- (void)dealloc
{
    for (id taskId in self.htmlLoadTasks) {
        NSURLSessionTask *task = self.htmlLoadTasks[taskId];
        [task cancel];
    }
}

@end

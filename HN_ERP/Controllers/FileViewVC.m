//
//  FileViewVC.m
//  HN_ERP
//
//  Created by tomwey on 3/3/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FileViewVC.h"
#import "Defines.h"
#import "AttachmentDownloadService.h"

@interface FileViewVC () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (nonatomic, strong) AttachmentDownloadService *downloadService;
@property (nonatomic, strong) NSURL *attachmentURL;

@end

@implementation FileViewVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = self.params[@"item"][@"filename"];
//    self.navigationController.navigationBarHidden = YES;
//    
//    self.navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : AWColorFromRGB(255,255,255) };
//    self.navBar.backgroundColor = MAIN_THEME_COLOR;
    
    self.contentView.backgroundColor = AWColorFromRGB(239, 239, 239);
    
    NSLog(@"item: %@", self.params[@"item"]);
    
//    self.navBar.title = self.params[@"item"][@"filename"];
    
    // 添加默认的返回按钮
    if ([self.params[@"is_close"] boolValue]) {
        __weak typeof(self) weakSelf = self;
        [self addLeftItemWithImage:@"btn_close.png"
                        leftMargin:5
                          callback:^{
                              [weakSelf dismissViewControllerAnimated:YES completion:nil];
                          }];
    } else {
        __weak typeof(self) me = self;
        [self addLeftItemWithImage:@"btn_back.png" leftMargin:2 callback:^{
            [me back];
        }];
    }

    self.dataSource = self;
    self.delegate = self;
    
    self.currentPreviewItemIndex = 0;
    
    [self startLoadAttachment];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startLoadAttachment
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSString *host = self.params[@"item"][@"host"];
    NSString *port = self.params[@"item"][@"port"];
    NSString *user = self.params[@"item"][@"username"];
    NSString *pass = self.params[@"item"][@"pwd"];
    
    self.downloadService = [[AttachmentDownloadService alloc] initWithHost:host
                                                                      port:port
                                                                  username:user
                                                                  password:pass];
    
    NSString *filePath = [NSString stringWithFormat:@"/file/%@/%@.hn",
                          self.params[@"item"][@"tablename"],
                          self.params[@"item"][@"fileid"]];
    NSLog(@"ftp file: %@", filePath);
    
    AttachmentFile *file = [[AttachmentFile alloc] initWithFTPFile:filePath unzipFilename:self.params[@"item"][@"filename"]];
    
    NSString *dir = [NSString stringWithFormat:@"Doc/%@", self.params[@"item"][@"docid"]];
    
    __weak typeof(self) me = self;
    [self.downloadService setCompletionBlock:^(NSURL *fileURL, NSError *error) {
        [me handleDownload:fileURL error:error];
    }];
    
    [self.downloadService startDownloadingFile:file
                                   toDirectory:dir];
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
            [self reloadData];
            //            [self.previewController refreshCurrentPreviewItem];
        } else {
            [self.contentView showHUDWithText:@"不能预览该文件" succeed:NO];
        }
        
    }
}

- (void)updateReadStatus
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"移动端公文标记已读",
                       @"param1": manID,
                       @"param2": self.params[@"item"][@"docid"] ?: @"0",
                       } completion:^(id result, NSError *error) {
                           //
                       }];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    NSLog(@"url: %@", self.attachmentURL);
    return !!self.attachmentURL ? 1 : 0;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [self.attachmentURL copy];//[NSURL fileURLWithPath:self.attachmentURL.absoluteString];
    //[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test.xlsx" ofType:nil]];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

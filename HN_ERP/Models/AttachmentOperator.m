//
//  AttachmentOperator.m
//  HN_ERP
//
//  Created by tomwey on 3/6/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AttachmentOperator.h"
#import "AttachmentDownloadService.h"
#import <QuickLook/QuickLook.h>
#import "Defines.h"

@interface AttachmentOperator () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) AttachmentDownloadService *downloadService;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic, weak) UIView *previewContainer;

@property (nonatomic, copy) NSString *docId;

@end
@implementation AttachmentOperator

- (void)startPreviewItem:(id)item
                  inView:(UIView *)aView
{
    if (!item) return;
    
    self.previewContainer = aView;
    
    NSString *host = item[@"host"];
    NSString *port = item[@"port"];
    NSString *user = item[@"username"];
    NSString *pass = item[@"pwd"];
    
    self.docId = item[@"docid"];
    
    [HNProgressHUDHelper showHUDAddedTo:aView animated:YES];
    
    if ( !self.downloadService ) {
        self.downloadService = [[AttachmentDownloadService alloc] initWithHost:host
                                                                          port:port
                                                                      username:user
                                                                      password:pass];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"/file/%@/%@.hn",
                          item[@"tablename"],
                          item[@"fileid"]];
//    NSLog(@"ftp file: %@", filePath);
    
    AttachmentFile *file = [[AttachmentFile alloc] initWithFTPFile:filePath unzipFilename:item[@"filename"]];
    
    NSString *dir = [NSString stringWithFormat:@"Doc/%@", item[@"docid"]];
    
    __weak typeof(self) me = self;
    [self.downloadService setCompletionBlock:^(NSURL *fileURL, NSError *error) {
        [me handleDownload:fileURL error:error];
    }];
    
    [self.downloadService startDownloadingFile:file
                                   toDirectory:dir];
}

- (void)handleDownload:(NSURL *)fileURL error:(NSError *)error
{
    if ( error ) {
        [HNProgressHUDHelper hideHUDForView:self.previewContainer animated:YES];
        [self.previewContainer showHUDWithText:error.domain succeed:NO];
    } else {
        if ( !self.documentController ) {
            self.documentController = [[UIDocumentInteractionController alloc] init];
            self.documentController.delegate = self;
        }
        
        self.documentController.URL = fileURL;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL flag = [self.documentController presentOptionsMenuFromRect:self.previewContainer.bounds inView:self.previewContainer animated:YES];
            if ( !flag ) {
                [self.previewContainer showHUDWithText:@"无法打开或预览该文件" succeed:NO];
            }
        });
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
                       @"param2": self.docId ?: @"0",
                       } completion:^(id result, NSError *error) {
                           //
                       }];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.previewController;
}

// Preview presented/dismissed on document.  Use to set up any HI underneath.
- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"will begin preview");
    [self updateReadStatus];
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"did end preview");
}

// Options menu presented/dismissed on document.  Use to set up any HI underneath.
- (void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"will present options menu");
    [HNProgressHUDHelper hideHUDForView:self.previewContainer animated:YES];
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"did dismiss options menu");
}

// Open in menu presented/dismissed on document.  Use to set up any HI underneath.
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"WillPresentOpenInMenu");
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"DidDismissOpenInMenu");
}

// Synchronous.  May be called when inside preview.  Usually followed by app termination.  Can use willBegin... to set annotation.
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application
{
    NSLog(@"willBeginSendingToApplication: %@", application);
    [self updateReadStatus];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(nullable NSString *)application
{
    NSLog(@"didEndSendingToApplication: %@", application);
}

@end

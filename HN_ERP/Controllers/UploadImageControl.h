//
//  UploadImageControl.h
//  HN_ERP
//
//  Created by tomwey on 25/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavBarVC.h"

@interface UploadImageControl : UIView

@property (nonatomic, strong, readonly) NSArray *attachmentIDs;

@property (nonatomic, strong, readonly) NSArray *deletedAttachmentIDs;

@property (nonatomic, strong, readonly) NSArray *attachments;

@property (nonatomic, weak) UIViewController *owner;

@property (nonatomic, copy) NSString *annexTableName;
@property (nonatomic, copy) NSString *annexFieldName;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, copy) void (^didUploadedImagesBlock)(UploadImageControl *sender);

- (instancetype)initWithAttachments:(NSArray *)attachments;

- (void)updateHeight;

@end

@interface UIButton (ImageData)

- (void)setBackgroundImageData:(NSData *)imageData
                      imageUTI:(NSString *)uti
                      forState:(UIControlState)state;

@end

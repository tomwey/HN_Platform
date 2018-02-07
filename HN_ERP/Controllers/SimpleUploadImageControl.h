//
//  UploadImageControl.h
//  HN_ERP
//
//  Created by tomwey on 25/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavBarVC.h"

@interface SimpleUploadImageControl : UIView

@property (nonatomic, strong, readonly) NSArray *attachmentIDs;

@property (nonatomic, weak) UIViewController *owner;

@property (nonatomic, copy) void (^didUploadedImagesBlock)(SimpleUploadImageControl *sender);

@end

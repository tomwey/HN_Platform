//
//  AttachmentOperator.h
//  HN_ERP
//
//  Created by tomwey on 3/6/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachmentOperator : NSObject

@property (nonatomic, weak) UIViewController *previewController;

- (void)startPreviewItem:(id)anItem
                  inView:(UIView *)aView;

@end

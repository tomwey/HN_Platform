//
//  UIView+MBProgressHUD.h
//  HN_ERP
//
//  Created by tomwey on 2/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MBProgressHUD)

- (void)showHUDWithText:(NSString *)text;

- (void)showHUDWithText:(NSString *)text offset:(CGPoint)offset;

- (void)showHUDWithText:(NSString *)text
                succeed:(BOOL)yesOrNo;

- (void)showHUDWithText:(NSString *)text
               duration:(NSTimeInterval)duration
                succeed:(BOOL)yesOrNo;

@end

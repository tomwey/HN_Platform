//
//  UIView+MBProgressHUD.m
//  HN_ERP
//
//  Created by tomwey on 2/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "UIView+MBProgressHUD.h"
#import "MBProgressHUD.h"
#import "Defines.h"

@implementation UIView (MBProgressHUD)

- (void)showHUDWithText:(NSString *)text succeed:(BOOL)yesOrNo
{
    [self showHUDWithText:text duration:1.5 succeed:yesOrNo];
}

- (void)showHUDWithText:(NSString *)text
{
    [self showHUDWithText:text offset:CGPointMake(0.f, MBProgressMaxOffset)];
}

- (void)showHUDWithText:(NSString *)text offset:(CGPoint)offset
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
//    hud.label.text = text;
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = AWSystemFontWithSize(16, YES);
    hud.detailsLabel.textColor = MAIN_THEME_COLOR;
    hud.userInteractionEnabled = NO;
    hud.offset = offset;
    [hud hideAnimated:YES afterDelay:2.0];
}

- (void)showHUDWithText:(NSString *)text
               duration:(NSTimeInterval)duration
                succeed:(BOOL)yesOrNo
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    
    NSString *imageName = yesOrNo ? @"hud_success.png" : @"hud_error.png";
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    
//    hud.square = YES;
    hud.userInteractionEnabled = NO;
    
    hud.label.text = text;
    
    [hud hideAnimated:YES afterDelay:duration];
}

@end

//
//  HNProgressHUDHelper.m
//  HN_ERP
//
//  Created by tomwey on 2/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNProgressHUDHelper.h"
#import "Defines.h"

@implementation HNProgressHUDHelper

+ (id)showHUDAddedTo:(UIView *)view animated:(BOOL)animated
{
    [[MBProgressHUD appearance] setContentColor:MAIN_THEME_COLOR];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated
{
    return [MBProgressHUD hideAllHUDsForView:view animated:animated];
}

@end

//
//  HNProgressHUDHelper.h
//  HN_ERP
//
//  Created by tomwey on 2/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNProgressHUDHelper : UIView

+ (id)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;

@end

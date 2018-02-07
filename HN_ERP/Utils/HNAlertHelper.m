//
//  HNAlertHelper.m
//  HN_ERP
//
//  Created by tomwey on 3/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNAlertHelper.h"
#import "TYAlertController.h"
#import "Defines.h"

void HNBaseAlert(NSString *title, NSString *message, UIViewController *vc)
{
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:title
                                                     message:message];
    
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
    //    alertView.contentViewSpace = 30;
    alertView.textLabelSpace   = 20;
    alertView.textLabelContentViewEdge = 35;
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancel handler:^(TYAlertAction *action) {
        
    }]];
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
        
    }]];
    
    alertView.buttonDestructiveBgColor = MAIN_THEME_COLOR;
    
    // first way to show
    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
    
    [AWAppWindow().rootViewController presentViewController:alertController animated:YES completion:nil];
}

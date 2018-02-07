//
//  SalaryPasswordView.h
//  HN_ERP
//
//  Created by tomwey on 4/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalaryPasswordView : UIView

+ (instancetype)showInView:(UIView *)superView
              doneCallback:(void (^)(NSString *password))doneCallback
              editCallback:(void (^)(void))editCallback;

@property (nonatomic, copy) void (^didDismissBlock)(void);

- (void)openKeyboard;

@end

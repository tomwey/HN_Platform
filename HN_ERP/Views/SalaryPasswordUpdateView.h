//
//  SalaryPasswordUpdateView.h
//  HN_ERP
//
//  Created by tomwey on 4/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalaryPasswordUpdateView : UIView

+ (instancetype)showInView:(UIView *)superView
              doneCallback:(void (^)(id inputData))doneCallback
           dismissCallback:(void (^)(void))dismissCallback;

@end

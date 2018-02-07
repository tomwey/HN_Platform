//
//  SelectButton.h
//  HN_ERP
//
//  Created by tomwey on 6/2/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectButton : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) void (^clickBlock)(SelectButton *sender);

@end

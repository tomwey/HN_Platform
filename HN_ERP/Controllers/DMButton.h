//
//  DMButton.h
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMButton : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void (^selectBlock)(DMButton *sender);

@property (nonatomic, strong) UIColor *contentColor;

@end

//
//  AWTextField.h
//  deyi
//
//  Created by tomwey on 9/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWTextField : UITextField

// 输入框内间距，默认为上下为0，左右为10
@property (nonatomic, assign) UIEdgeInsets padding;

// 边框线的大小，默认为0.3
@property (nonatomic, assign) CGFloat borderWidth;

// 边框颜色，默认为浅灰色
@property (nonatomic, strong) UIColor *borderColor;

// 倒角大小，默认为8
@property (nonatomic, assign) CGFloat cornerRadius;

@end

//
//  SettingsView.h
//  Wallpapers
//
//  Created by tangwei1 on 16/3/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BubbleView : UIView

@property (nonatomic, assign) CGFloat cornerRadius;

// 气泡尖的位置
@property (nonatomic, assign) CGFloat triangleMargin;

// 气泡尖的高度
@property (nonatomic, assign) CGFloat triangleHeight;

- (void)showInView:(UIView *)superView;

- (void)dismiss;

@end

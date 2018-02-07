//
//  BaseNavBarVC.m
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BaseNavBarVC.h"
#import "Defines.h"

#define kNavBarLeftItemTag 1011
#define kNavBarRightItemTag 1012

@interface BaseNavBarVC ()

@property (nonatomic, copy, nullable) void (^leftItemCallback)(void);
@property (nonatomic, copy, nullable) void (^rightItemCallback)(void);

@property (nonatomic, strong) UIView *internalContentView;

@end

@implementation BaseNavBarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : AWColorFromRGB(255,255,255) };
    self.navBar.backgroundColor = MAIN_THEME_COLOR;
    
    self.contentView.backgroundColor = AWColorFromRGB(239, 239, 239);
    
    // 添加默认的返回按钮
//    __weak typeof(self) me = self;
    UIButton *backBtn = HNBackButton(24, self, @selector(back));
    [self addLeftItemWithView:backBtn leftMargin:2];
    
    // 添加手势滑动
    if ( [self supportsSwipeToBack] ) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:swipe];
    }
}

- (BOOL)supportsSwipeToBack
{
    return YES;
}

- (void)back
{
    if ( self.navigationController ) {
        if ( [[self.navigationController viewControllers] count] == 1 ) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            // > 1
            if ( [self.parentViewController isKindOfClass:[UITabBarController class]] &&
                [self.parentViewController isEqual:[self.navigationController.viewControllers lastObject]] ) {
                NSLog(@"当前页面不需要返回");
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

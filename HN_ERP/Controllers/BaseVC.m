//
//  BaseVC.m
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BaseVC.h"
#import "Defines.h"

@interface BaseVC () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) LoadingView *loadingView;

@end
@implementation BaseVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"------------> dealloc %@", self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = MAIN_BG_COLOR;
    
    // 手势滑动返回上一个页面
//    UIScreenEdgePanGestureRecognizer *panGesture = (UIScreenEdgePanGestureRecognizer *)self.navigationController.interactivePopGestureRecognizer;
//    panGesture.delegate = self;
//    panGesture.edges = UIRectEdgeLeft | UIRectEdgeRight;
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

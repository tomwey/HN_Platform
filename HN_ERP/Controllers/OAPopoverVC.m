//
//  OAPopoverVC.m
//  HN_ERP
//
//  Created by tomwey on 9/8/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OAPopoverVC.h"
#import "Defines.h"

@interface OAPopoverVC ()

@property (nonatomic, strong) UIButton *flowcopyButton;
@property (nonatomic, strong) UIButton *rebackButton;
@property (nonatomic, strong) AWHairlineView *horizontalLine;

@end

@implementation OAPopoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL canundo = [self.params[@"canundo"] boolValue];
    
    self.rebackButton.enabled = canundo;
    self.rebackButton.alpha   = canundo ? 1.0 : 0.5;
    
    NSLog(@"%@", self.params);
}

- (void)viewWillLayoutSubviews
{
    self.flowcopyButton.frame = CGRectMake(15, 0, self.view.width - 30, 40);
    self.rebackButton.frame   = self.flowcopyButton.frame;
    self.rebackButton.top     = self.flowcopyButton.bottom;
    
    if ( !self.horizontalLine ) {
        self.horizontalLine = [AWHairlineView horizontalLineWithWidth:self.flowcopyButton.width
                                                                color:[UIColor whiteColor]
                                                               inView:self.view];
    }
    
    self.horizontalLine.position = CGPointMake(self.flowcopyButton.left,
                                               self.flowcopyButton.bottom);
}

- (UIButton *)flowcopyButton
{
    if ( !_flowcopyButton ) {
        _flowcopyButton = AWCreateTextButton(CGRectZero,
                                             @"流程复制",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(flowCopy));
        [self.view addSubview:_flowcopyButton];
        
        _flowcopyButton.titleLabel.font = AWSystemFontWithSize(14, NO);
    }
    return _flowcopyButton;
}

- (void)flowCopy
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowPopoverDidDismissNotification" object:@"flowcopy"];
    }];
}

- (UIButton *)rebackButton
{
    if ( !_rebackButton ) {
        _rebackButton = AWCreateTextButton(CGRectZero,
                                             @"撤回",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(reback));
        [self.view addSubview:_rebackButton];
        
        _rebackButton.titleLabel.font = AWSystemFontWithSize(14, NO);
    }
    return _rebackButton;
}

- (void)reback
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowPopoverDidDismissNotification" object:@"reback"];
    }];
}

@end

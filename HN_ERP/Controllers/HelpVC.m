//
//  HelpVC.m
//  HN_ERP
//
//  Created by tomwey on 3/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HelpVC.h"
#import "Defines.h"

@interface HelpVC ()

@end

@implementation HelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"使用帮助";
    
    UILabel *coomingSoon = AWCreateLabel(CGRectZero,
                                         @"尽请期待...",
                                         NSTextAlignmentCenter, nil, [UIColor blackColor]);
    [self.contentView addSubview:coomingSoon];
    coomingSoon.frame = CGRectMake(0, 168, self.contentView.width, 40);
}


@end

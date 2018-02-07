//
//  ApplyLeaveVC.m
//  HN_ERP
//
//  Created by tomwey on 5/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ApplyLeaveVC.h"
#import "Defines.h"

@interface ApplyLeaveVC ()

@end

@implementation ApplyLeaveVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navBar.title = @"请假";
    
    UILabel *coomingSoon = AWCreateLabel(CGRectZero,
                                         @"敬请期待...",
                                         NSTextAlignmentCenter, nil, [UIColor blackColor]);
    [self.contentView addSubview:coomingSoon];
    coomingSoon.frame = CGRectMake(0, 168, self.contentView.width, 40);
}

@end

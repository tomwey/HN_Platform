//
//  PlanProjectView.m
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanProjectView.h"
#import "Defines.h"

@interface PlanProjectView ()

@property (nonatomic, strong) UILabel *coomingSoonLabel;

@end

@implementation PlanProjectView

- (void)startLoading
{
    self.coomingSoonLabel.text = @"敬请期待...";
}

- (UILabel *)coomingSoonLabel
{
    if ( !_coomingSoonLabel ) {
        _coomingSoonLabel = AWCreateLabel(CGRectZero,
                                          nil,
                                          NSTextAlignmentCenter,
                                          nil,
                                          [UIColor blackColor]);
        [self addSubview:_coomingSoonLabel];
        
        _coomingSoonLabel.frame = CGRectMake(0, 60, self.width, 30);
    }
    return _coomingSoonLabel;
}

@end

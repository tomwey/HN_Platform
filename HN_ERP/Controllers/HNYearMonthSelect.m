//
//  HNYearMonthSelect.m
//  HN_ERP
//
//  Created by tomwey on 9/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNYearMonthSelect.h"
#import "Defines.h"
#import "SelectButton.h"

@interface HNYearMonthSelect ()

@property (nonatomic, strong) SelectButton *beginYearButton;
@property (nonatomic, strong) SelectButton *beginMonthButton;

@property (nonatomic, strong) SelectButton *endYearButton;
@property (nonatomic, strong) SelectButton *endMonthButton;

@property (nonatomic, strong) NSArray *yearData;
@property (nonatomic, strong) NSArray *monthData;

@end

@implementation HNYearMonthSelect

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [[UIDatePicker alloc] init];
    }
    return self;
}

@end

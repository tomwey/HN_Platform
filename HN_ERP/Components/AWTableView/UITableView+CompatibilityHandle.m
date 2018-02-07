//
//  CompatibilityHandle.m
//  BayLe
//
//  Created by tangwei1 on 15/11/23.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "UITableView+CompatibilityHandle.h"

@implementation UITableView (CompatibilityHandle)

- (void)removeCompatibility
{
    if ( [self respondsToSelector:@selector(setSeparatorInset:)] ) {
        self.separatorInset = UIEdgeInsetsZero;
    }
    
    if ( [self respondsToSelector:@selector(setLayoutMargins:)] ) {
        self.layoutMargins = UIEdgeInsetsZero;
    }
}

@end

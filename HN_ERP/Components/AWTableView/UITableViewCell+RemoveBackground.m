//
//  RemoveBackground.m
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "UITableViewCell+RemoveBackground.h"

@implementation UITableViewCell (RemoveBackground)

- (void)removeBackground
{
    self.backgroundColor = [UIColor clearColor];
}

@end

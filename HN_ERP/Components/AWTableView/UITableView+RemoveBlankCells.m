//
//  RemoveBlankCells.m
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "UITableView+RemoveBlankCells.h"

@implementation UITableView (RemoveBlankCells)

- (void)removeBlankCells
{
    self.tableFooterView = [[UIView alloc] init];
}

@end

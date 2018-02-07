//
//  CompatibilityHandle.h
//  BayLe
//
//  Created by tangwei1 on 15/11/23.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (CompatibilityHandle)

/**
 * 去掉不同系统之间的兼容性问题
 */
- (void)removeCompatibility;

@end

//
//  EmployCell.h
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Employ;
@interface EmployCell : UITableViewCell

@property (nonatomic, strong) Employ *employ;

@property (nonatomic, assign) BOOL checked;

@end

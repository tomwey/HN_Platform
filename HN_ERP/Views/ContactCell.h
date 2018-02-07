//
//  ContactCell.h
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (nonatomic, readonly) BOOL opened;

- (void)setOpened:(BOOL)opened animated:(BOOL)animated;

@end

//
//  UIActionSheet+DisabledButtons.h
//  HN_ERP
//
//  Created by tomwey on 2/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (DisabledButtons)

@property (nonatomic, strong) NSArray<NSString *> *disabledButtons;

@end

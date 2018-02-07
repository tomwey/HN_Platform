//
//  HNTimeSelect.h
//  HN_ERP
//
//  Created by tomwey on 9/6/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNTimeSelect : UIView

@property (nonatomic, assign) BOOL needUpdateWeekOfMonth;

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger quarter;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger weekOfMonth;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, copy) void (^timeSelectDidChange)(HNTimeSelect *sender);

- (void)prepareInitData;

@end

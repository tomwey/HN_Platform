//
//  HNCityAreaSelect.h
//  HN_ERP
//
//  Created by tomwey on 21/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNCityAreaSelect : UIView

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, copy) NSString *cityID; // 城市ID
@property (nonatomic, copy) NSString *platID; // 板块ID

@property (nonatomic, copy) void (^selectBlock)(HNCityAreaSelect *sender);

- (void)prepareData;

@end

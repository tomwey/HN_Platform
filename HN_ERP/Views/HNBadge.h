//
//  BadgeView.h
//  HN_ERP
//
//  Created by tomwey on 3/8/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNBadge : NSObject

- (instancetype)initWithBadge:(NSUInteger)badge
                       inView:(UIView *)view;

@property (nonatomic, assign) NSUInteger badge;

@property (nonatomic, weak)   UIView *badgeContainer;

@property (nonatomic, assign) CGPoint position;

@end

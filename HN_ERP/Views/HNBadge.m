//
//  BadgeView.m
//  HN_ERP
//
//  Created by tomwey on 3/8/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNBadge.h"
#import "Defines.h"

@interface HNBadge ()

@property (nonatomic, strong) UILabel *badgeLabel;
//@property (nonatomic, weak)   UIView  *badgeContainer;

@end
@implementation HNBadge

- (instancetype)initWithBadge:(NSUInteger)badge inView:(UIView *)view
{
    if ( self = [super init] ) {
        _position = CGPointZero;
        
        self.badgeContainer = view;
        self.badge = badge;
    }
    return self;
}

- (void)setBadge:(NSUInteger)badge
{
    _badge = badge;
    
    if ( badge == 0 ) {
        self.badgeLabel.frame = CGRectZero;
    } else {
        NSString *badgeValue = [@(badge) description];
        if ( badge > 99 ) {
            badgeValue = @"99+";
        }
        
        self.badgeLabel.text = badgeValue;
        [self.badgeLabel sizeToFit];
        
        NSInteger tmpWidth = ceil(self.badgeLabel.width);
        
        CGFloat width = tmpWidth + 8;
        width = MAX(width, 18);
        
        self.badgeLabel.frame = CGRectMake(0, 0, width, 18);
        self.badgeLabel.cornerRadius = self.badgeLabel.height / 2;
        self.badgeLabel.position = self.position;
    }
}

- (void)setPosition:(CGPoint)position
{
    _position = position;
    
    self.badgeLabel.position = position;
}

- (UILabel *)badgeLabel
{
    if ( !_badgeLabel ) {
        _badgeLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(13, NO),
                                    [UIColor whiteColor]);
        [self.badgeContainer addSubview:_badgeLabel];
        _badgeLabel.backgroundColor = AWColorFromRGB(245, 34, 38);
    }
    return _badgeLabel;
}

@end

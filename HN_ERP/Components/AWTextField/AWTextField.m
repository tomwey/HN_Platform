//
//  AWTextField.m
//  deyi
//
//  Created by tomwey on 9/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "AWTextField.h"

@implementation AWTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.clipsToBounds = YES;
    
    self.borderWidth = ( 1.0 / [[UIScreen mainScreen] scale] ) / 2.0;
    self.cornerRadius = 8;
    self.borderColor = [UIColor colorWithRed:201/255.0
                                       green:201/255.0
                                        blue:201/255.0
                                       alpha:1.0];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    
    self.layer.cornerRadius = cornerRadius;
    
    self.clipsToBounds = YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect frame = bounds;
    frame.origin.x += self.padding.left;
    frame.size.width -= (self.padding.left + self.padding.right);
    frame.origin.y += self.padding.top;
    frame.size.height -= ( self.padding.top + self.padding.bottom );
    return frame;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end

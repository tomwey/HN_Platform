//
//  UIView+AWGeometry.m
//  Pods
//
//  Created by tangwei1 on 16/5/24.
//
//

#import "UIView+AWGeometry.h"

@implementation UIView (AWGeometry)

@dynamic position, boundsSize, x, y, width, height;

- (void)setPosition:(CGPoint)position
{
    CGRect frame = self.frame;
    frame.origin = position;
    self.frame = frame;
}

- (CGPoint)position { return self.frame.origin; }

- (void)setBoundsSize:(CGSize)boundsSize
{
    CGRect frame = self.frame;
    frame.size = boundsSize;
    self.frame = frame;
}

- (CGSize)boundsSize { return self.frame.size; }

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x { return self.position.x; }

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y { return self.position.y; }

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width { return self.boundsSize.width; }

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height { return self.boundsSize.height; }

- (CGFloat)minX { return self.x; }
- (CGFloat)minY { return self.y; }

- (CGFloat)maxX { return CGRectGetMaxX(self.frame); }
- (CGFloat)maxY { return CGRectGetMaxY(self.frame); }

- (CGFloat)midX { return CGRectGetMidX(self.frame); }
- (CGFloat)midY { return CGRectGetMidY(self.frame); }

- (void)setLeft:(CGFloat)left
{
    self.x = left;
}

- (CGFloat)left { return self.x; }

- (void)setTop:(CGFloat)top
{
    self.y = top;
}

- (CGFloat)top { return self.y; }

- (CGFloat)right { return CGRectGetMaxX(self.frame); }
- (CGFloat)bottom { return CGRectGetMaxY(self.frame); }

- (CGPoint)centerInFrame { return self.center; }
- (CGPoint)centerInBounds { return CGPointMake(self.width / 2, self.height / 2); }

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

@end

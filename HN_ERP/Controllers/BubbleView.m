//
//  SettingsView.m
//  Wallpapers
//
//  Created by tangwei1 on 16/3/31.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "BubbleView.h"

@interface BubbleView () //<UITableViewDataSource, UITableViewDelegate>
{
    CGMutablePathRef outlinePath;
    UIView* _tapView;
}

@end
@implementation BubbleView

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.backgroundColor = [UIColor clearColor];
        
//        CGRect frame = CGRectMake(0, 0, 194, 247);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, .5f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    
    UIColor* color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    //[UIColor colorWithWhite:1.0 alpha:.9];
    //TMColorForIdentifier(@"settingsViewBubbleBackgroundColor");
    [color setFill];
    
    CGFloat radius = self.cornerRadius;
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    outlinePath = CGPathCreateMutable();
    
    miny += 10;
    CGPathMoveToPoint(outlinePath, nil, minx, midy);
    CGPathAddArcToPoint(outlinePath, nil, minx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, maxx, midy, radius);
    CGPathAddArcToPoint(outlinePath, nil, maxx, miny, midx, miny, radius);
    CGPathAddLineToPoint(outlinePath, nil, maxx - 66, miny);
    CGPathAddLineToPoint(outlinePath, nil, maxx - 56, miny - 10);
    CGPathAddLineToPoint(outlinePath, nil, maxx - 46, miny);
    CGPathAddArcToPoint(outlinePath, nil, minx, miny, minx, midy, radius);
    CGPathCloseSubpath(outlinePath);
    
    CGContextAddPath(ctx, outlinePath);
    CGContextFillPath(ctx);
    
//    self.layer.shadowPath = outlinePath;
//    self.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor];
//    self.layer.shadowRadius = 2;
//    self.layer.shadowOffset = CGSizeZero;
//    self.layer.shadowOpacity = 1.0;
    
}

- (void)dealloc
{
    CGPathRelease(outlinePath);
}

- (void)showInView:(UIView *)superView
{
    if ( self.superview ) {
        return;
    }
    
    UIButton* tapView = [[UIButton alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [superView addSubview:tapView];
    
    [tapView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    _tapView = tapView;
    
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
//    self.frame = CGRectMake(10, 70, 0, 0);
    
//    _tableView.frame = CGRectMake(5, 15, 0, 0);
    
    self.layer.shadowPath = outlinePath;
    self.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor];
    self.layer.shadowRadius = 2;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 1.0;
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    self.frame = CGRectMake(width - 15 - 180, 70, 180,
                            180);
    
    self.alpha = 0.0;
    
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [_tapView removeFromSuperview];
    _tapView = nil;
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.alpha = 0.0;
//        self.frame = CGRectMake(10, 70, 0, 0);
//        
////        _tableView.alpha = 0.0;
////        
////        _tableView.frame = CGRectMake(5, 15, 0, 0);
//
        self.layer.shadowPath = NULL;
        self.layer.shadowOpacity = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (CGFloat)cornerRadius
{
    if ( _cornerRadius == 0.0 ) {
        _cornerRadius = 6;
    }
    return _cornerRadius;
}

@end

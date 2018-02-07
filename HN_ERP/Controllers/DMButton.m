//
//  DMButton.m
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DMButton.h"
#import "Defines.h"

@interface DMButton ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *caretView;

@end
@implementation DMButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(tap)]];
    }
    return self;
}

- (void)tap
{
    if ( self.selectBlock ) {
        self.selectBlock(self);
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.label.text = title;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.caretView.position = CGPointMake(self.width - 5 - self.caretView.width,
//                                          self.height - 5 - self.caretView.height);

    
    self.label.frame = CGRectMake(5, 0,
                                  self.width - self.caretView.width - 5 - 5 - 5,
                                  self.height);
    
    CGSize size = [self.title sizeWithAttributes:@{ NSFontAttributeName: self.label.font }];
    
    CGFloat width = MIN(size.width, self.label.width);
    
    self.caretView.position = CGPointMake(self.width / 2 + width / 2,
                                          self.height / 2 - self.caretView.height / 2);
}

- (void)setContentColor:(UIColor *)contentColor
{
    _contentColor = contentColor;
    
    self.caretView.tintColor = contentColor;
    
    self.label.textColor = contentColor;
}

- (UILabel *)label
{
    if ( !_label ) {
        _label = AWCreateLabel(CGRectZero,
                               nil,
                               NSTextAlignmentCenter,
                               AWSystemFontWithSize(15, NO),
                               AWColorFromRGB(88, 88, 88));
        [self addSubview:_label];
    }
    
    return _label;
}

- (UIImageView *)caretView
{
    if ( !_caretView ) {
        _caretView = AWCreateImageView(nil);
        _caretView.image = [[UIImage imageNamed:@"icon_triangle.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _caretView.frame = CGRectMake(0, 0, 12, 12);
        _caretView.tintColor = AWColorFromHex(@"#999999");
        [self addSubview:_caretView];
    }
    return _caretView;
}

@end

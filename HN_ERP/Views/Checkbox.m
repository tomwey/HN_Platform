//
//  Checkbox.m
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "Checkbox.h"
#import "Defines.h"

@interface Checkbox ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@end

#define kMaxLabelLength 120

@implementation Checkbox

@synthesize labelAttributes = _labelAttributes;

- (instancetype)initWithNormalImage:(UIImage *)normalImage
                      selectedImage:(UIImage *)selectedImage
{
    if ( self = [super initWithFrame:CGRectZero] ) {
        self.normalImage = normalImage;
        self.selectedImage = selectedImage;
        
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithNormalImage:nil selectedImage:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithNormalImage:nil selectedImage:nil];
}

- (void)setup
{
    // 最小的宽度是40
    self.frame = CGRectMake(0, 0, 40, 40);
    
    _label = nil;
    _checked = NO;
    _maximumWidth = 180;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
}

- (void)setNormalImage:(UIImage *)normalImage
{
    if (_normalImage == normalImage) return;
    
    _normalImage = normalImage;
    
    [self updateIconView];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    if ( _selectedImage == selectedImage ) return;
    
    _selectedImage = selectedImage;
    
    [self updateIconView];
}

- (void)setChecked:(BOOL)checked
{
    if ( _checked == checked ) return;
    
    _checked = checked;
    
    [self updateIconView];
}

- (void)setLabel:(NSString *)label
{
    if ( label.length > 0 && _label != label ) {
        
        _label = label;
        
        self.nameLabel.text = label;
        
        [self updateFrame];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( self.label.length > 0 ) {
        self.iconView.center = CGPointMake(self.iconView.width / 2,
                                           self.height / 2);
        
        self.nameLabel.position = CGPointMake(self.iconView.right + 10, 0);
    } else {
        self.iconView.center = CGPointMake(self.width / 2,
                                           self.height / 2);
    }
}

- (void)updateIconView
{
    self.iconView.image = self.checked ? self.selectedImage : self.normalImage;
    [self.iconView sizeToFit];
    
    CGFloat height = MIN(30, self.iconView.height);
    self.iconView.frame = CGRectMake(0, 0, height, height);
    
    [self setNeedsLayout];
}

- (void)updateFrame
{
    CGSize size = [self.nameLabel.text sizeWithAttributes:self.labelAttributes];
    CGFloat width = size.width;
    
//    CGFloat padding = 10;
    CGFloat labelWidth = MIN(width, (self.maximumWidth - 40));
    
    self.nameLabel.frame = CGRectMake(0, 0, labelWidth, self.height);
    
    // 更新自己的大小
    self.width = labelWidth + 40;
    
    // 重新布局
    [self setNeedsLayout];
}

- (void)tap
{
    self.checked = !self.checked;
    
    if ( self.didChangeBlock ) {
        self.didChangeBlock(self);
    }
}

 - (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        [self addSubview:_iconView];
        _iconView.frame = CGRectMake(0, 0, 30, 30);
    }
    return _iconView;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   self.labelAttributes[NSFontAttributeName],
                                   self.labelAttributes[NSForegroundColorAttributeName]);
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (void)setLabelAttributes:(NSDictionary *)labelAttributes
{
    if ( _labelAttributes != labelAttributes ) {
        _labelAttributes = labelAttributes;
        
        if ( self.label.length > 0 ) {
            if ( labelAttributes[NSFontAttributeName] ) {
                self.nameLabel.font = labelAttributes[NSFontAttributeName];
            }
            
            if ( labelAttributes[NSForegroundColorAttributeName] ) {
                self.nameLabel.textColor = labelAttributes[NSForegroundColorAttributeName];
            }
            
            [self updateFrame];
        }
    }
}

- (NSDictionary *)labelAttributes
{
    if ( !_labelAttributes ) {
        _labelAttributes = [@{ NSFontAttributeName: AWSystemFontWithSize(14, NO),
                               NSForegroundColorAttributeName: [UIColor blackColor]
                              } copy];
    }
    return _labelAttributes;
}

@end

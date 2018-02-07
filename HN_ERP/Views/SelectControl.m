//
//  SelectControl.m
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SelectControl.h"
#import "Defines.h"

@interface SelectControl ()

@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, assign, readwrite) BOOL selected;

@property (nonatomic, strong) UIButton *clickBtn;

@end
@implementation SelectControl

- (instancetype)initWithNormalImage:(UIImage *)normalImage
                      selectedImage:(UIImage *)selectedImage
                               name:(NSString *)name
                              value:(NSString *)value
{
    if ( self = [super init] ) {
        self.normalImage = normalImage;
        self.selectedImage = selectedImage;
        
        self.name = name;
        self.value = value;
        
        _selected = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.clickBtn.frame = self.bounds;
    
    self.iconView.frame = CGRectMake(10, 4, 32, 32);
    self.nameLabel.frame = CGRectMake(self.iconView.right + 5,
                                      3, self.width - 10 - self.iconView.right + 10,
                                      34);
}

- (void)setControlGroup:(SelectControlGroup *)controlGroup
{
    _controlGroup = controlGroup;
    
    self.delegate = controlGroup;
    
    [controlGroup addControl:self];
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    self.nameLabel.text = name;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    self.iconView.image = selected ? self.selectedImage : self.normalImage;
}

- (void)doClick
{
    self.selected = !self.selected;
    if ( [self.delegate respondsToSelector:@selector(didSelectControl:)] ) {
        [self.delegate performSelector:@selector(didSelectControl:) withObject:self];
    }
}

- (UIButton *)clickBtn
{
    if ( !_clickBtn ) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(doClick) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        [self addSubview:_clickBtn];
    }
    return _clickBtn;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,nil,NSTextAlignmentLeft,
                                   nil, [UIColor blackColor]);
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        [self addSubview:_iconView];
    }
    
    self.iconView.image = self.selected ? self.selectedImage : self.normalImage;
    
    return _iconView;
}

@end

@interface SelectControlGroup ()

@property (nonatomic, strong) NSMutableArray *controls;

@end
@implementation SelectControlGroup

- (void)addControl:(SelectControl *)control
{
    if ( ![self.controls containsObject:control] ) {
        [self.controls addObject:control];
    }
}

- (void)removeControl:(SelectControl *)control
{
    if ( [self.controls containsObject:control] ) {
        [self.controls removeObject:control];
    }
}

- (void)didSelectControl:(SelectControl *)control
{
    if ( self.supportsMultipleSelect ) {
        if ( control.selected ) {
            [self addControl:control];
        } else {
            [self removeControl:control];
        }
    } else {
        for (SelectControl *c in self.controls) {
            c.selected = NO;
        }
        
        control.selected = YES;
    }
}

- (void)removeAllControls
{
    [self.controls removeAllObjects];
}

- (NSMutableArray *)controls
{
    if ( !_controls ) {
        _controls = [[NSMutableArray alloc] init];
    }
    return _controls;
}

@end

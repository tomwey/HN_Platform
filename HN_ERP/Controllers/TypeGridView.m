//
//  TypeGridView.m
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "TypeGridView.h"
#import "Defines.h"

@interface TypeGridView ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@end

@implementation TypeGridView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    }
    return self;
}

- (void)tap
{
    if ( self.tapCallback ) {
        self.tapCallback(self);
    }
}

- (void)setItem:(id)item
{
    if ( _item == item ) return;
    
    _item = item;
    
    self.nameLabel.text = item[@"typename"];
    self.iconView.image = [UIImage imageNamed:@"icon_folder.png"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.center = CGPointMake(self.width / 2, self.iconView.height / 2 + 3);
    
    self.nameLabel.frame = CGRectMake(0, 0, self.width, 20);
    self.nameLabel.center = CGPointMake(self.width / 2,
                                        self.iconView.bottom + self.nameLabel.height / 2 + 5);
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        [self addSubview:_iconView];
        _iconView.frame = CGRectMake(0, 0, 32, 32);
    }
    return _iconView;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(58, 58, 58));
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

@end

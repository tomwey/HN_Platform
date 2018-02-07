//
//  AWSectionHeaderView.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AWSectionHeaderView.h"
#import "Defines.h"

@interface AWSectionHeaderView ()

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel     *titleLabel;

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation AWSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        _opened = NO;
        
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor whiteColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        
        [self sendSubviewToBack:view];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen)]];
    }
    return self;
}

- (void)setSectionData:(id)sectionData
{
    _sectionData = sectionData;
    
    self.iconView.image = [UIImage imageNamed:[sectionData valueForKey:@"icon"]];
    self.titleLabel.text = [sectionData valueForKey:@"title"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    view.frame = self.bounds;
    
    self.iconView.center = CGPointMake(15 + self.iconView.width / 2,
                                       self.height / 2);
    
    self.arrowView.position = CGPointMake(self.width - 15 - self.arrowView.width,
                                          self.height / 2 - self.arrowView.height / 2);
    
    self.titleLabel.frame = CGRectMake(self.iconView.right + 10,
                                       self.height / 2 - 34 / 2,
                                       self.arrowView.left - 10 - self.iconView.right - 15,
                                       34);
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        _iconView.frame = CGRectMake(0, 0, 40, 40);
        _iconView.cornerRadius = _iconView.height / 2;
        [self addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    nil,
                                    [UIColor blackColor]);
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)arrowView
{
    if ( !_arrowView ) {
        _arrowView = AWCreateImageView(@"icon_arrow-right.png");
//        _iconView.frame = CGRectMake(0, 0, 40, 40);
        [self addSubview:_arrowView];
    }
    return _arrowView;
}

- (void)toggleOpen
{
    if ( _opened ) {
        [self setOpened:NO animated:YES];
    } else {
        [self setOpened:YES animated:YES];
    }
}

- (void)setOpened:(BOOL)opened
{
    _opened = opened;
    
    [self setOpened:opened animated:NO];
}

- (void)setOpened:(BOOL)opened animated:(BOOL)animated
{
    _opened = opened;
    
    if ( opened ) {
        [UIView animateWithDuration:.25 animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        }];
        
        if ( [self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)] ) {
            [self.delegate sectionHeaderView:self sectionOpened:self.section];
        }
    } else {
        
        [UIView animateWithDuration:.25 animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0);
        }];
        
        if ( [self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)] ) {
            [self.delegate sectionHeaderView:self sectionClosed:self.section];
        }
    }
}

@end

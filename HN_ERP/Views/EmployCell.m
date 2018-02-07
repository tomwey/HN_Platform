//
//  EmployCell.m
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "EmployCell.h"
#import "Defines.h"
#import "Employ.h"

@interface EmployCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *jobLabel;

//@property (nonatomic, strong) AWHairlineView *hairlineView;

@end

@implementation EmployCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        
    }
    return self;
}

- (void)setEmploy:(Employ *)aEmploy
{
//    if ( employData != nil && _employ != aEmploy ) {
//        _employData = employData;
    
    _employ = aEmploy;
    
    self.iconView.hidden = ![_employ.supportsSelecting boolValue];
    
    // 设置头像
    self.avatarView.image = [UIImage imageNamed:@"default_avatar.png"];
//    [HNImageHelper imageForName:aEmploy.name
//                          manID:[aEmploy._id integerValue]
//                           size:CGSizeMake(40, 40)
//                completionBlock:^(UIImage *anImage, NSError *error) {
//                    if ( anImage ) {
//                        self.avatarView.image = anImage;
//                    }
//                }];
    
    [self.avatarView setImageWithManInfo:HNManInfoCreate([aEmploy._id integerValue], aEmploy.name)];
    
    self.nameLabel.text = _employ.name;
    self.jobLabel.text  = _employ.job;
//    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.avatarView setImageWithManInfo:HNManInfoCreate([self.employ._id integerValue], self.employ.name)];
    
//    [self.avatarView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self.avatarView setImageWithManInfo:HNManInfoCreate([self.employ._id integerValue], self.employ.name)];
    
//    [self.avatarView setNeedsDisplay];
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    
    if ( checked ) {
        self.iconView.image = [UIImage imageNamed:@"icon_checkbox_click.png"];
    } else {
        self.iconView.image = [UIImage imageNamed:@"icon_checkbox.png"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = 0;
    if ( self.iconView.hidden ) {
        self.iconView.frame = CGRectZero;
//        self.iconView.left  = 15;
        left = 15;
    } else {
        self.iconView.frame = CGRectMake(0, 0, 22, 22);
        self.iconView.center = CGPointMake(15 + self.iconView.width / 2, self.height / 2);
        left = self.iconView.right + 10;
    }
    
    self.avatarView.position = CGPointMake(left, self.height / 2 - self.avatarView.height / 2);
    
    self.nameLabel.frame = CGRectMake(self.avatarView.right + 10,
                                      10, self.width - 30 - self.avatarView.right - 10, 20);
    self.jobLabel.frame  = self.nameLabel.frame;
    self.jobLabel.top = self.nameLabel.bottom;
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(@"icon_checkbox.png");
        _iconView.frame = CGRectMake(0, 0, 22, 22);
        [self.contentView addSubview:_iconView];
    }
    return _iconView;
}

- (UIImageView *)avatarView
{
    if ( !_avatarView ) {
        _avatarView = AWCreateImageView(@"default_avatar.png");
        _avatarView.cornerRadius = _avatarView.height / 2;
        [self.contentView addSubview:_avatarView];
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   nil,
                                   [UIColor blackColor]);
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)jobLabel
{
    if ( !_jobLabel ) {
        _jobLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR);
        [self.contentView addSubview:_jobLabel];
    }
    return _jobLabel;
}

//- (AWHairlineView *)hairlineView
//{
//    if ( !_hairlineView ) {
//        _hairlineView = [AWHairlineView horizontalLineWithWidth:0
//                                                          color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:self.contentView];
//    }
//    return _hairlineView;
//}

@end

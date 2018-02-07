//
//  MessageCell.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MessageCell.h"
#import "Defines.h"

@interface MessageCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *badge;

@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
//        self.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.iconView.image = [UIImage imageNamed:data[@"icon"]];
    self.titleLabel.text = data[@"name"];
    self.bodyLabel.text = data[@"body"];
    self.timeLabel.text = data[@"time"];
    
    if ( [data[@"count"] integerValue] > 0) {
        self.badge.text = [data[@"count"] integerValue] > 99 ?
                           @"99+" : data[@"count"];
        self.badge.hidden = NO;
    } else {
        self.badge.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.badge.backgroundColor = [UIColor redColor];
    self.badge.textColor = [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    self.badge.backgroundColor = [UIColor redColor];
    self.badge.textColor = [UIColor whiteColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.center = CGPointMake(15 + self.iconView.width / 2,
                                       self.height / 2);
    self.titleLabel.frame = CGRectMake(self.iconView.right + 15,
                                       self.iconView.top - 10,
                                       self.width - self.iconView.right - 15 - 15 - 60, 37);
    self.bodyLabel.frame = self.titleLabel.frame;
    self.bodyLabel.top = self.iconView.bottom - self.bodyLabel.height + 10;
    
    self.timeLabel.frame = CGRectMake(self.width - 15 - 60,
                                      self.titleLabel.top,
                                      60, 37);
    
    CGSize size = [self.badge.text sizeWithAttributes:@{ NSFontAttributeName: self.badge.font }];
    
    if ( size.width > 24 ) {
        self.badge.width = 40;
    } else {
        self.badge.width = 24;
    }
//    self.badge.width = size.width + 6;
    
    self.badge.center = CGPointMake(self.timeLabel.right - self.badge.width / 2,
                                    
                                    self.timeLabel.bottom + self.badge.height / 2);
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        _iconView.frame = CGRectMake(0, 0, 48, 48);
        _iconView.cornerRadius = _iconView.height / 2;
        [self.contentView addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    [UIColor blackColor]);
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)bodyLabel
{
    if ( !_bodyLabel ) {
        _bodyLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(13, NO),
                                    AWColorFromRGB(181,181,181));
        [self.contentView addSubview:_bodyLabel];
    }
    return _bodyLabel;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(13, NO),
                                   AWColorFromRGB(181,181,181));
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)badge
{
    if ( !_badge ) {
        _badge = AWCreateLabel(CGRectMake(0, 0, 24, 24),
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(13, NO),
                                   [UIColor whiteColor]);
        [self.contentView addSubview:_badge];
        _badge.cornerRadius = _badge.height / 2;
        _badge.backgroundColor = [UIColor redColor];
    }
    return _badge;
}

@end

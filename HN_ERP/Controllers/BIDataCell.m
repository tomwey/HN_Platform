//
//  BIDataCell.m
//  HN_ERP
//
//  Created by tomwey on 6/5/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BIDataCell.h"
#import "Defines.h"

@interface BIDataCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *realLabel;
@property (nonatomic, strong) UILabel *doneLabel;

@end

@implementation BIDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.titleLabel.text = [NSString stringWithFormat:@"[%@ - %@] %@",
                            data[@"area_name"],data[@"usertype_name"],data[@"project_name"]];
    
    self.planLabel.text = [NSString stringWithFormat:@"计划\n%.2f万",
                           [data[@"conplan"] floatValue]];
    self.realLabel.text = [NSString stringWithFormat:@"实际\n%.2f万",
                           [data[@"conreal"] floatValue]];
    
    self.doneLabel.text = [NSString stringWithFormat:@"完成\n%d%%",
                           [data[@"conrate"] integerValue]];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(15, 10, self.width - 30,
                                       30);
    
    CGFloat width = ( self.width - 30 - 30 ) / 3.0;
    
    self.planLabel.frame = CGRectMake(15, self.titleLabel.bottom + 10,
                                      width,
                                      width);
    
    self.realLabel.frame = self.planLabel.frame;
    self.realLabel.left  = self.planLabel.right + 15;
    
    self.doneLabel.frame = self.planLabel.frame;
    self.doneLabel.left  = self.realLabel.right + 15;
    
    self.planLabel.cornerRadius =
    self.realLabel.cornerRadius =
    self.doneLabel.cornerRadius = width / 2.0;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)planLabel
{
    if ( !_planLabel ) {
        _planLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_planLabel];
        _planLabel.numberOfLines = 2;
        
        _planLabel.layer.borderColor = AWColorFromRGB(235,235,235).CGColor;
        _planLabel.layer.borderWidth = 1;
    }
    return _planLabel;
}

- (UILabel *)realLabel
{
    if ( !_realLabel ) {
        _realLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_realLabel];
        _realLabel.numberOfLines = 2;
        
        _realLabel.layer.borderColor = AWColorFromRGB(235,235,235).CGColor;
        _realLabel.layer.borderWidth = 1;
    }
    return _realLabel;
}

- (UILabel *)doneLabel
{
    if ( !_doneLabel ) {
        _doneLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_doneLabel];
        _doneLabel.numberOfLines = 2;
        
        _doneLabel.layer.borderColor = AWColorFromRGB(235,235,235).CGColor;
        _doneLabel.layer.borderWidth = 1;
    }
    return _doneLabel;
}

@end

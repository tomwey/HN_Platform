//
//  InvestNewsCell.m
//  HN_ERP
//
//  Created by tomwey on 01/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "InvestNewsCell.h"
#import "Defines.h"

@interface InvestNewsCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *summaryLabel;

@property (nonatomic, strong) UIImageView *readIconView;

@end

@implementation InvestNewsCell

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.titleLabel.text = data[@"title"];
    
    if ( data[@"projname"] ) {
        self.summaryLabel.text = [NSString stringWithFormat:@"%@   %@",
                                  data[@"projname"], HNDateFromObject(data[@"releasedate"], @"T")];
    } else {
        self.summaryLabel.text = HNDateFromObject(data[@"releasedate"], @"T");
    }

    self.readIconView.hidden = ![data[@"isnew"] boolValue];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self.titleLabel sizeToFit];
    
    self.titleLabel.frame = CGRectMake(15, 0, self.width - 15 - self.readIconView.width - 5,
                                       60);
    
    self.summaryLabel.frame = CGRectMake(15, self.titleLabel.bottom, self.width - 30, 30);
    
    self.readIconView.position = CGPointMake(self.width - self.readIconView.width,
                                             0);
    
    //    if ( !self.iconView.image ) {
    //        self.iconView.frame = CGRectZero;
    //        self.titleLabel.left = 15;
    //        self.summaryLabel.left = self.titleLabel.left;
    //    }
}

- (UIImageView *)readIconView
{
    if ( !_readIconView ) {
        _readIconView = AWCreateImageView(@"icon_unread.png");
        [self.contentView addSubview:_readIconView];
        _readIconView.frame = CGRectMake(0, 0, 30, 30);
    }
    return _readIconView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)summaryLabel
{
    if ( !_summaryLabel ) {
        _summaryLabel = AWCreateLabel(CGRectZero,
                                      nil,
                                      NSTextAlignmentLeft,
                                      AWSystemFontWithSize(13, NO),
                                      AWColorFromRGB(133,133,133));
        [self.contentView addSubview:_summaryLabel];
    }
    return _summaryLabel;
}

@end

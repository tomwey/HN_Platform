//
//  NewsCell.m
//  HN_ERP
//
//  Created by tomwey on 5/8/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NewsCell.h"
#import "Defines.h"

@interface NewsCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *summaryLabel;

@property (nonatomic, strong) UIImageView *readIconView;

@end

@implementation NewsCell


- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.titleLabel.text = data[@"title"];
    
    
    NSString *imageUrl = [[data[@"image_url"] componentsSeparatedByString:@"?"] lastObject];
    NSDictionary *params = [imageUrl queryDictionaryUsingEncoding:NSUTF8StringEncoding];
    imageUrl = [params[@"file"] stringByAppendingPathComponent:@"contents"];
    
    self.iconView.image = nil;
    NSURL *url = [NSURL URLWithString:imageUrl];
    [self.iconView setImageWithURL:url];
    
    self.summaryLabel.text = [[data[@"releasedate"] componentsSeparatedByString:@"T"] firstObject];
    
    self.readIconView.hidden = ![data[@"isnew"] boolValue];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake(15, 15, 80, 60);
    self.titleLabel.frame = CGRectMake(self.iconView.right + 10,
                                       self.iconView.top,
                                       self.width - self.iconView.right - 10 - 35 - 15,
                                       40);
    [self.titleLabel sizeToFit];
    
    self.summaryLabel.frame = CGRectMake(self.titleLabel.left,
                                         self.iconView.bottom - 20 + 2,
                                         self.titleLabel.width,
                                         20);
    
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

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        [self.contentView addSubview:_iconView];
        _iconView.backgroundColor = AWColorFromRGB(241, 241, 241);
        _iconView.contentMode = UIViewContentModeScaleToFill;
        _iconView.clipsToBounds = YES;
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

//
//  SubCatalogCell.m
//  HN_ERP
//
//  Created by tomwey on 27/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "SubCatalogCell.h"
#import "Defines.h"

@interface SubCatalogCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation SubCatalogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = AWColorFromRGB(244, 244, 244);
    }
    return self;
}

- (void)configData:(id)data
{
    self.nameLabel.text = [data name];
    
    NSInteger total = [[data total] integerValue];
    if (total > 9) {
        self.countLabel.text = @"9+";
    } else {
        self.countLabel.text = [[data total] description];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.countLabel.frame = CGRectMake(self.width - 40 - 5, 0, 40, self.height);
    
    self.nameLabel.frame = CGRectMake(5, 0, self.countLabel.left - 5, self.height);
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(13, NO),
                                   AWColorFromHex(@"#666666"));
        [self.contentView addSubview:_nameLabel];
        
        _nameLabel.numberOfLines = 2;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _nameLabel;
}

- (UILabel *)countLabel
{
    if ( !_countLabel ) {
        _countLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(13, NO),
                                   AWColorFromHex(@"#666666"));
        [self.contentView addSubview:_countLabel];
    }
    return _countLabel;
}

@end

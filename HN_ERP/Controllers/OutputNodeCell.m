//
//  OutputNodeCell.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputNodeCell.h"
#import "Defines.h"

@interface OutputNodeCell ()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UIImageView *doneView;

@property (nonatomic, strong) void (^didSelectItemBlock)(UIView<AWTableDataConfig> *sender, id selectedData);

@end

@implementation OutputNodeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.nameLabel.text = [data[@"outnodename"] description];
    
    self.userData = data;
    
    self.didSelectItemBlock = selectBlock;
    
    NSString *val = HNStringFromObject(data[@"nodecurendvalue"], @"--");
    if (![val isEqualToString:@"--"]) {
        val = [@([val integerValue]) description];
        if ([val isEqualToString:@"0"]) {
            val = @"--";
        }
    }
    
    NSString *progress = [NSString stringWithFormat:@"%@ %@ / %@ %@",
                          val, data[@"nodenumberunit"], [@([data[@"maxnum"] integerValue]) description],
                          data[@"nodenumberunit"]];
    
    NSRange range = [progress rangeOfString:@"/"];
    range.length = range.location - 1;
    range.location = 0;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:progress];
    [string addAttributes:@{ NSForegroundColorAttributeName: MAIN_THEME_COLOR } range:range];
    
    self.progressLabel.attributedText = string;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(15, 0, self.width - 30, 50);
    
    self.nameLabel.frame = CGRectMake(10, 0, self.containerView.width - 115,
                                      self.containerView.height);
    
    self.progressLabel.frame = CGRectMake(0, 0, 102, self.containerView.height);
    
    self.progressLabel.position = CGPointMake(self.containerView.width - self.nameLabel.left - self.progressLabel.width,
                                              0);
}

- (UIView *)containerView
{
    if ( !_containerView ) {
        _containerView = [[UIView alloc] init];
        [self.contentView addSubview:_containerView];
        
        _containerView.backgroundColor = AWColorFromRGB(247, 247, 247);
        
        [_containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tap)]];
    }
    return _containerView;
}

- (void)tap
{
    if ( self.didSelectItemBlock ) {
        self.didSelectItemBlock(self, self.userData);
    }
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(74, 74, 74));
        [self.containerView addSubview:_nameLabel];
        
        _nameLabel.numberOfLines = 2;
    }
    return _nameLabel;
}

- (UILabel *)progressLabel
{
    if ( !_progressLabel ) {
        _progressLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(74, 74, 74));
        [self.containerView addSubview:_progressLabel];
//        _progressLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _progressLabel;
}

- (UIImageView *)doneView
{
    if ( !_doneView ) {
        _doneView = AWCreateImageView(@"icon_gou.png");
        [self.containerView addSubview:_doneView];
    }
    return _doneView;
}

@end

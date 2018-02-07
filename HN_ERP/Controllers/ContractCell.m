//
//  ContractCell.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractCell.h"
#import "Defines.h"

@interface CustomProgressView : UIView

@property (nonatomic, assign) float progress;

@property (nonatomic, strong) UIColor *progressColor;

@end

@interface ContractCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *contractNoLabel;
@property (nonatomic, strong) UILabel *contractNameLabel;
@property (nonatomic, strong) UILabel *companyLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *realLabel;
@property (nonatomic, strong) UILabel *yfLabel;

@property (nonatomic, strong) UILabel *percentLabel1;
@property (nonatomic, strong) UILabel *percentLabel2;

@property (nonatomic, copy) void (^didSelectItemBlock)(UIView<AWTableDataConfig> *sender, id data);

@end

@implementation ContractCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView  = nil;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.didSelectItemBlock = selectBlock;
    
    self.userData = data;
    
    self.contractNoLabel.text = [NSString stringWithFormat:@"   %@", [data[@"contractphyno"] description]];
    self.contractNameLabel.text = [data[@"contractname"] description];
    self.companyLabel.text = [data[@"supname"] description];
    
    [self setLabel1:data[@"contractmoney"]
               name:@"总金额"
           forLabel:self.totalLabel
              color:MAIN_THEME_COLOR];
    
    [self setLabel1:data[@"contractfactoutvalue"]
               name:@"累计实际产值"
           forLabel:self.realLabel
              color:AWColorFromRGB(74, 144, 226)];
    
    [self setLabel1:data[@"contractpayableoutvalue"]
               name:@"累计应付产值"
           forLabel:self.yfLabel
              color:AWColorFromRGB(120, 120, 120)];
    
    
    float total = [data[@"contractmoney"] floatValue];
    
    float val1 = [data[@"contractfactoutvalue"] floatValue];
    float val2 = [data[@"contractpayableoutvalue"] floatValue];
    
    float percent1,percent2;
    if ( total == 0 ) {
        percent1 = 0;
        percent2 = 0;
    } else {
        percent1 = val1 / total * 100.0;
        percent2 = val2 / total * 100.0;
    }
    
    [self setLabel2:@(percent1)
               name:@"累计实际产值 / 总金额 = "
           forLabel:self.percentLabel1
              color:AWColorFromRGB(74, 144, 226)];
    [self setLabel2:@(percent2)
               name:@"累计应付产值 / 总金额 = "
           forLabel:self.percentLabel2
              color:AWColorFromRGB(120,120,120)];
}

- (void)setLabel1:(id)value name:(NSString *)name forLabel:(UILabel *)label color:(UIColor *)color
{
    NSString *money = [HNFormatMoney(value, @"万") stringByReplacingOccurrencesOfString:@"万" withString:@""];
    NSString *string = [NSString stringWithFormat:@"%@万\n%@", money, name];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{
                                NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                                NSForegroundColorAttributeName: color
                                } range:[string rangeOfString:money]];
    
    label.attributedText = attrString;
}

- (void)setLabel2:(id)value name:(NSString *)name forLabel:(UILabel *)label color:(UIColor *)color
{
    CGFloat val = [value floatValue];
    NSString *ss = nil;
    if ( val < 100 ) {
        ss = [NSString stringWithFormat:@"%.1f", val];
    } else {
        ss = @"100";
    }
    
    NSString *string = [NSString stringWithFormat:@"%@%@%%", name, ss];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{
                                NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                                NSForegroundColorAttributeName: color
                                } range:[string rangeOfString:ss]];
    
    label.attributedText = attrString;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(15,
                                          0,
                                          self.width - 30,
                                          190);
    
    self.contractNoLabel.frame = CGRectMake(0, 0, self.containerView.width,
                                            30);
    
    self.contractNameLabel.frame = CGRectMake(10,
                                              self.contractNoLabel.bottom + 5,
                                              self.containerView.width - 20,
                                              40);
    
    self.companyLabel.frame = CGRectMake(self.contractNameLabel.left,
                                         self.contractNameLabel.bottom,
                                         self.contractNameLabel.width,
                                         30);
    
    CGFloat width = (self.companyLabel.width - 10) / 3.0;
    
    self.totalLabel.frame =
    self.realLabel.frame  =
    self.yfLabel.frame    = CGRectMake(0, 0, width, 44);
    
    self.totalLabel.position = CGPointMake(self.companyLabel.left, self.companyLabel.bottom);
    self.realLabel.position  = CGPointMake(self.totalLabel.right + 5, self.totalLabel.top);
    self.yfLabel.position    = CGPointMake(self.realLabel.right + 5, self.totalLabel.top);
    
    self.percentLabel1.frame =
    self.percentLabel2.frame = CGRectMake(0, 0, (self.companyLabel.width - 5) / 2.0, 30);
    
    self.percentLabel1.position = CGPointMake(self.totalLabel.left, self.totalLabel.bottom);
    self.percentLabel2.position = CGPointMake(self.percentLabel1.right + 5, self.totalLabel.bottom);
}

- (UIView *)containerView
{
    if ( !_containerView ) {
        _containerView = [[UIView alloc] init];
        [self.contentView addSubview:_containerView];
        
        _containerView.layer.borderColor = AWColorFromRGB(198, 219, 174).CGColor;
        _containerView.layer.borderWidth = 0.6;
        
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

- (UILabel *)contractNoLabel
{
    if ( !_contractNoLabel ) {
        _contractNoLabel = AWCreateLabel(CGRectZero,
                                         nil,
                                         NSTextAlignmentLeft,
                                         AWSystemFontWithSize(12, NO),
                                         [UIColor whiteColor]);
        [self.containerView addSubview:_contractNoLabel];
        
        _contractNoLabel.backgroundColor = AWColorFromRGB(198, 219, 174);
    }
    return _contractNoLabel;
}

- (UILabel *)contractNameLabel
{
    if ( !_contractNameLabel ) {
        _contractNameLabel = AWCreateLabel(CGRectZero,
                                         nil,
                                         NSTextAlignmentLeft,
                                         AWSystemFontWithSize(14, YES),
                                         AWColorFromRGB(74, 74, 74));
        [self.containerView addSubview:_contractNameLabel];
        _contractNameLabel.numberOfLines = 2;
        _contractNameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _contractNameLabel;
}

- (UILabel *)companyLabel
{
    if ( !_companyLabel ) {
        _companyLabel = AWCreateLabel(CGRectZero,
                                         nil,
                                         NSTextAlignmentLeft,
                                         AWSystemFontWithSize(12, NO),
                                         AWColorFromHex(@"#999999"));
        [self.containerView addSubview:_companyLabel];
    }
    return _companyLabel;
}

- (UILabel *)totalLabel
{
    if ( !_totalLabel ) {
        _totalLabel = AWCreateLabel(CGRectZero,
                                      nil,
                                      NSTextAlignmentLeft,
                                      AWSystemFontWithSize(10, NO),
                                      self.companyLabel.textColor);
        [self.containerView addSubview:_totalLabel];
        
        _totalLabel.numberOfLines = 2;
        _totalLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _totalLabel;
}

- (UILabel *)realLabel
{
    if ( !_realLabel ) {
        _realLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(10, NO),
                                    self.companyLabel.textColor);
        [self.containerView addSubview:_realLabel];
        
        _realLabel.numberOfLines = 2;
        
        _realLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _realLabel;
}

- (UILabel *)yfLabel
{
    if ( !_yfLabel ) {
        _yfLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(10, NO),
                                   self.companyLabel.textColor);
        [self.containerView addSubview:_yfLabel];
        
        _yfLabel.numberOfLines = 2;
        _yfLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _yfLabel;
}

- (UILabel *)percentLabel1
{
    if ( !_percentLabel1 ) {
        _percentLabel1 = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(10, NO),
                                       self.companyLabel.textColor);
        [self.containerView addSubview:_percentLabel1];
        
        _percentLabel1.adjustsFontSizeToFitWidth = YES;
    }
    return _percentLabel1;
}

- (UILabel *)percentLabel2
{
    if ( !_percentLabel2 ) {
        _percentLabel2 = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentRight,
                                       AWSystemFontWithSize(10, NO),
                                       self.companyLabel.textColor);
        [self.containerView addSubview:_percentLabel2];
        
        _percentLabel2.adjustsFontSizeToFitWidth = YES;
    }
    return _percentLabel2;
}

@end

@interface CustomProgressView ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation CustomProgressView

- (void)setProgress:(float)progress
{
    if ( _progress != progress ) {
        _progress = progress;
        
        if (_progress > 1.0) {
            _progress = 1.0;
        }
        [self setNeedsLayout];
    }
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    
    self.progressView.backgroundColor = progressColor;
    
    self.layer.borderColor = progressColor.CGColor;
    self.layer.borderWidth = 0.6;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.width * self.progress;
    
    self.progressView.frame = self.bounds;
    self.progressView.width = width;
}

- (UIView *)progressView
{
    if ( !_progressView ) {
        _progressView = [[UIView alloc] init];
        [self addSubview:_progressView];
    }
    return _progressView;
}

@end

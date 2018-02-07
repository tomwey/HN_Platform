//
//  InvestProjectCell.m
//  HN_ERP
//
//  Created by tomwey on 24/11/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "InvestProjectCell.h"
#import "Defines.h"

@interface InvestProjectCell ()

@property (nonatomic, strong) UIView *viewContainer;

@property (nonatomic, strong) UILabel *projLabel;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) AWHairlineView *line;

@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *costLabel;
@property (nonatomic, strong) UILabel *earnLabel;
@property (nonatomic, strong) UILabel *time1Label;
@property (nonatomic, strong) UILabel *time2Label;

@property (nonatomic, strong) id data;

@property (nonatomic, copy) void (^selectBlock)(UIView<AWTableDataConfig> *sender, id selectedData);

@end

@implementation InvestProjectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView  = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.data = data;
    
    self.selectBlock = selectBlock;
    
    self.projLabel.text = [NSString stringWithFormat:@"%@", //data[@"area_name"],
                           data[@"projname"]];
    
    self.stateLabel.text = [data[@"clearstate"] boolValue] ? @"已结算" : @"未结算";
    self.stateLabel.backgroundColor = [data[@"clearstate"] boolValue] ? AWColorFromHex(@"#54ae3b") : MAIN_THEME_COLOR;
    
    [self setAttrText:[data[@"money"] description]
              forName:@"跟投总额"
             forLabel:self.totalLabel];
    
    [self setAttrText:[data[@"capitalmoney"] description]
              forName:@"已退本金"
             forLabel:self.costLabel];
    
//    [self setAttrText:data[@"yearrateplan"]
//              forName:@"计划年化率"
//             forLabel:self.earnLabel];
    
    NSString *money = [HNFormatMoney(data[@"yearrateplan"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    NSString *string = [NSString stringWithFormat:@"%@%%\n%@", money, @"计划年化率"];
    
    NSRange range = [string rangeOfString:money];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttributes:@{
                             NSFontAttributeName: AWCustomFont(@"PingFang SC", 20),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             } range:range];
    
    self.earnLabel.attributedText = attrStr;
    
    
    NSString *prefix1 = @"";
    NSString *prefix2 = @"";
    if (![data[@"clearstate"] boolValue]) {
        prefix1 = @"预计";
        prefix2 = @"预计";
    }
    
    NSString *time1 = ![data[@"clearstate"] boolValue] ? HNDateFromObject(data[@"cashbackdateplan"], @"T") :
    HNDateFromObject(data[@"capitaloutdate"], @"T");
    
    NSString *time2 = ![data[@"clearstate"] boolValue] ? HNDateFromObject(data[@"plandate"], @"T") :
    HNDateFromObject(data[@"realdate"], @"T");
    
    [self setAttrText2:time1
               forName:[NSString stringWithFormat:@"%@返还本金日期", prefix1]
              forLabel:self.time1Label];
    
    [self setAttrText2:time2
               forName:[NSString stringWithFormat:@"%@分红结算日期", prefix2]
              forLabel:self.time2Label];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.viewContainer.frame = CGRectMake(15, 15, self.width - 30,
                                          175);
    
    self.projLabel.frame = CGRectMake(10, 4, self.viewContainer.width - 20 - 45 - 10,
                                      40);
    
    self.stateLabel.frame = CGRectMake(0, 0, 44, 20);
    self.stateLabel.center = CGPointMake(self.viewContainer.width - 10 - self.stateLabel.width / 2,
                                         self.projLabel.midY);
    
    if ( !self.line ) {
        self.line = [AWHairlineView horizontalLineWithWidth:self.viewContainer.width - 20
                                                      color:AWColorFromRGB(216, 216, 216)
                                                     inView:self.viewContainer];
    }
    
    self.line.position = CGPointMake(10, self.projLabel.bottom);
    
    CGFloat width = self.line.width / 3.0;
    
    self.totalLabel.frame = CGRectMake(self.line.left, self.line.bottom,
                                       width,
                                       60);
    self.costLabel.frame  = self.totalLabel.frame;
    self.costLabel.left = self.totalLabel.right;
    
    self.earnLabel.frame  =self.totalLabel.frame;
    self.earnLabel.left = self.costLabel.right;
    
    
    width = self.line.width / 2.0;
    
    self.time1Label.frame = CGRectMake(self.line.left,
                                       self.totalLabel.bottom + 5,
                                       width,
                                       60);
    
    self.time2Label.frame = self.time1Label.frame;
    self.time2Label.left = self.time1Label.right;
}

- (void)setAttrText:(NSString *)val forName:(NSString *)name forLabel:(UILabel *)label
{
    NSString *money = [HNFormatMoney2(val, nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    NSString *string = [NSString stringWithFormat:@"%@元\n%@", money, name];
    
    NSRange range = [string rangeOfString:money];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttributes:@{
                             NSFontAttributeName: AWCustomFont(@"PingFang SC", 20),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             } range:range];
    
    label.attributedText = attrStr;
}

- (void)setAttrText2:(NSString *)val forName:(NSString *)name forLabel:(UILabel *)label
{
    NSString *string = [NSString stringWithFormat:@"%@\n%@", name, val];
    
    NSRange range = [string rangeOfString:@"\n"];
    range.length = string.length - range.location;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttributes:@{
                             NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             } range:range];
    
    label.attributedText = attrStr;
}

- (UIView *)viewContainer
{
    if ( !_viewContainer ) {
        _viewContainer = [[UIView alloc] init];
        [self.contentView addSubview:_viewContainer];
        _viewContainer.cornerRadius = 6;
        _viewContainer.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        [_viewContainer addGestureRecognizer:tap];
    }
    return _viewContainer;
}

- (void)tap:(id)sender
{
    if (self.selectBlock) {
        self.selectBlock(self, self.data);
    }
}

- (UILabel *)projLabel
{
    if ( !_projLabel ) {
        _projLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(16, NO),
                                   AWColorFromRGB(58, 58, 58));
        [self.viewContainer addSubview:_projLabel];
        _projLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _projLabel;
}

- (UILabel *)stateLabel
{
    if ( !_stateLabel ) {
        _stateLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(12, NO),
                                   [UIColor whiteColor]);
        [self.viewContainer addSubview:_stateLabel];
        _stateLabel.cornerRadius = 2;
        
    }
    return _stateLabel;
}

- (UILabel *)totalLabel
{
    if ( !_totalLabel ) {
        _totalLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(168, 168, 168));
        [self.viewContainer addSubview:_totalLabel];
        
        _totalLabel.numberOfLines = 2;
        _totalLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _totalLabel;
}

- (UILabel *)costLabel
{
    if ( !_costLabel ) {
        _costLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(168, 168, 168));
        [self.viewContainer addSubview:_costLabel];
        _costLabel.numberOfLines = 2;
        _costLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _costLabel;
}

- (UILabel *)earnLabel
{
    if ( !_earnLabel ) {
        _earnLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(168, 168, 168));
        [self.viewContainer addSubview:_earnLabel];
        _earnLabel.numberOfLines  = 2;
        _earnLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _earnLabel;
}

- (UILabel *)time1Label
{
    if ( !_time1Label ) {
        _time1Label = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(168, 168, 168));
        [self.viewContainer addSubview:_time1Label];
        _time1Label.numberOfLines  = 2;
    }
    return _time1Label;
}

- (UILabel *)time2Label
{
    if ( !_time2Label ) {
        _time2Label = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(168, 168, 168));
        [self.viewContainer addSubview:_time2Label];
        _time2Label.numberOfLines  = 2;
    }
    return _time2Label;
}

@end

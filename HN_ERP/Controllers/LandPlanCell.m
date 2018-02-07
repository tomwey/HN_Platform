//
//  LandPlanCell.m
//  HN_ERP
//
//  Created by tomwey on 6/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandPlanCell.h"
#import "Defines.h"

@interface LandPlanCell ()

@property (nonatomic, strong) UILabel *planTypeLabel;
@property (nonatomic, strong) UILabel *planNameLabel;

@property (nonatomic, strong) UILabel *manNameLabel;
@property (nonatomic, strong) UILabel *addDaysLabel;

@property (nonatomic, strong) UILabel *planDoneLabel;
@property (nonatomic, strong) UILabel *meetingLabel;

@property (nonatomic, strong) UILabel *memoLabel;

@end

@implementation LandPlanCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.planTypeLabel.text = [NSString stringWithFormat:@"任务阶段：%@",
                               [data[@"buildtypeid"] integerValue] == 1 ? @"新增土地" : @"立项通过"];
    self.planNameLabel.text = [NSString stringWithFormat:@"任务名称：%@",
                               HNStringFromObject(data[@"planname"], @"无")];
    
    self.manNameLabel.text = [NSString stringWithFormat:@"   责任人：%@",
                              HNStringFromObject(data[@"domanname"], @"无")];
    self.addDaysLabel.text = [NSString stringWithFormat:@"延后天数：%@",
                              HNStringFromObject(data[@"adddays"], @"无")];
    
    self.planDoneLabel.text = [NSString stringWithFormat:@"完成时间：%@ ",
                              HNDateFromObject(data[@"planoverdate"], @"T")];
    self.meetingLabel.text = [NSString stringWithFormat:@"会议时间：%@",
                              HNDateFromObject(data[@"meetdate"], @"T")];
    
    self.memoLabel.text = [NSString stringWithFormat:@"备注：%@",
                           HNStringFromObject(data[@"memodesc"], @"无")];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = 15;
    CGFloat width = (self.width - left * 2) / 2.0;
    
    self.planTypeLabel.frame = CGRectMake(15, 5, width, 30);
    self.planNameLabel.frame = self.planTypeLabel.frame;
    self.planNameLabel.left  = self.planTypeLabel.right;
    
    self.manNameLabel.frame  = self.planTypeLabel.frame;
    self.manNameLabel.top    = self.planTypeLabel.bottom;
    
    self.addDaysLabel.frame  = self.manNameLabel.frame;
    self.addDaysLabel.left   = self.manNameLabel.right;
    
    self.planDoneLabel.frame = self.planTypeLabel.frame;
    self.planDoneLabel.top   = self.addDaysLabel.bottom;
    
    self.meetingLabel.frame  = self.planDoneLabel.frame;
    self.meetingLabel.left   = self.planDoneLabel.right;
    
    CGSize size = [self.memoLabel.text boundingRectWithSize:CGSizeMake(width * 2,
                                                                       1000)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:nil
                                                    context:NULL].size;
    self.memoLabel.frame = CGRectMake(left, self.meetingLabel.bottom + 5,
                                      width * 2,
                                      size.height);
}

- (UILabel *)planTypeLabel
{
    if ( !_planTypeLabel ) {
        _planTypeLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_planTypeLabel];
    }
    return _planTypeLabel;
}

- (UILabel *)planNameLabel
{
    if ( !_planNameLabel ) {
        _planNameLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_planNameLabel];
    }
    return _planNameLabel;
}

- (UILabel *)manNameLabel
{
    if ( !_manNameLabel ) {
        _manNameLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_manNameLabel];
    }
    return _manNameLabel;
}

- (UILabel *)addDaysLabel
{
    if ( !_addDaysLabel ) {
        _addDaysLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_addDaysLabel];
    }
    return _addDaysLabel;
}

- (UILabel *)planDoneLabel
{
    if ( !_planDoneLabel ) {
        _planDoneLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_planDoneLabel];
        
        _planDoneLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _planDoneLabel;
}

- (UILabel *)meetingLabel
{
    if ( !_meetingLabel ) {
        _meetingLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_meetingLabel];
        
        _meetingLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _meetingLabel;
}

- (UILabel *)memoLabel
{
    if ( !_memoLabel ) {
        _memoLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(58, 58, 58));
        [self.contentView addSubview:_memoLabel];
        
        _memoLabel.numberOfLines = 0;
    }
    return _memoLabel;
}

@end

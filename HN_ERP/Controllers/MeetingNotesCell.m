//
//  MeetingNotesCell.m
//  HN_ERP
//
//  Created by tomwey on 7/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingNotesCell.h"
#import "Defines.h"

@interface MeetingNotesCell ()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UILabel *traceLabel;
@property (nonatomic, strong) UILabel *planLabel;

@property (nonatomic, copy) void (^itemDidSelectBlock)(UIView<AWTableDataConfig> *sender, id data);

@property (nonatomic, strong) id selectedData;

@end

@implementation MeetingNotesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.backgroundView = nil;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id data))selectBlock
{
    self.itemDidSelectBlock = selectBlock;
    
    self.selectedData = data;
    
    //    id = 341;
    //    igz = NULL;
    //    ijy = NULL;
    //    iplan = NULL;
    //    isstop = 0;
    //    "meet_typename" = "\U5176\U5b83";
    //    orderdate = "2017-05-15";
    //    "spec_name" = "\U5176\U5b83";
    //    title = NULL;
    
    self.titleLabel.text = HNStringFromObject(data[@"title"], @"--");
    
    self.descLabel.text  = [NSString stringWithFormat:@"%@ %@ %@",
                            HNStringFromObject(data[@"spec_name"], @"--"),
                            HNStringFromObject(data[@"orderdate"], @"--"),
                            HNStringFromObject(data[@"meet_typename"], @"--")];
    
    self.traceLabel.text = [NSString stringWithFormat:@"跟踪\n%@",
                            HNStringFromObject(data[@"igz"], @"0 / 0")];
    self.planLabel.text = [NSString stringWithFormat:@"计划\n%@",
                            HNStringFromObject(data[@"iplan"], @"0 / 0")];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(15, 0, self.width - 30, 68);
    
    self.titleLabel.frame = CGRectMake(10, 5, self.containerView.width - 100, 34);
    self.descLabel.frame  = self.titleLabel.frame;
    self.descLabel.top    = self.titleLabel.bottom - 10;
    
    self.planLabel.frame = CGRectMake(0, 0, 50, 40);
    self.traceLabel.frame = self.planLabel.frame;
    
    self.planLabel.center = CGPointMake(self.containerView.width - 5 - self.planLabel.width / 2,
                                        self.containerView.height / 2);
    
    self.traceLabel.center = CGPointMake(self.planLabel.left - self.traceLabel.width / 2 + 10,
                                         self.planLabel.midY);
}

- (void)doTap
{
    if ( self.itemDidSelectBlock ) {
        self.itemDidSelectBlock(self, self.selectedData);
    }
}

- (UIView *)containerView
{
    if ( !_containerView ) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_containerView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(doTap)];
        
        [_containerView addGestureRecognizer:tap];
    }
    return _containerView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, NO),
                                    AWColorFromRGB(58, 58, 58));
        [self.containerView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)descLabel
{
    if ( !_descLabel ) {
        _descLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(158, 158, 158));
        [self.containerView addSubview:_descLabel];
    }
    return _descLabel;
}

- (UILabel *)traceLabel
{
    if ( !_traceLabel ) {
        _traceLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(158, 158, 158));
        [self.containerView addSubview:_traceLabel];
        
        _traceLabel.numberOfLines = 2;
    }
    return _traceLabel;
}

- (UILabel *)planLabel
{
    if ( !_planLabel ) {
        _planLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(158, 158, 158));
        [self.containerView addSubview:_planLabel];
        
        _planLabel.numberOfLines = 2;
    }
    return _planLabel;
}

@end

//
//  OutputDeclareCell.m
//  HN_ERP
//
//  Created by tomwey on 25/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "OutputNodeConfirmCell.h"
#import "Defines.h"

@interface OutputNodeConfirmCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *moneyTypeLabel;

@property (nonatomic, strong) UILabel *outMoneyLabel;
@property (nonatomic, strong) UILabel *payMoneyLabel;

@property (nonatomic, strong) UIImageView *confirmView;

@end

@implementation OutputNodeConfirmCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data
{
    //            annexnum = 0;
    //            appcomplete = 0;
    //            apppaycomplete = NULL;
    //            confirmbase = 50;
    //            contractid = 2222844;
    //            contractpaynodeid = 5596531;
    //            factenddate = NULL;
    //            hasoutvalue = 1;
    //            maxnum = 100;
    //            minnum = 0;
    //            moneytypeid = 20;
    //            moneytypename = "\U8fdb\U5ea6\U6b3e";
    //            nodecompletestatusdesc = "\U5f85\U786e\U8ba4";
    //            nodecompletestatusnum = 1;
    //            nodecurendvalue = NULL;
    //            nodenumberunit = "%";
    //            ordertype = 1;
    //            outnodeid = NULL;
    //            outnodename = "\U5168\U90e8\U8bbe\U5907\U5230\U573a\U540e\U652f\U4ed8\U81f3\U5408\U540c\U603b\U4ef7\U768460%";
    //            outnodeoder = 10000;
    //            planbegindate = "2017-10-30T00:00:00+08:00";
    //            planenddate = "2018-01-30T00:00:00+08:00";
    //            planpaydate = "2018-02-28T00:00:00+08:00";
    //            pricebase = 50;
    //            roomids = 0;
    //            roomname = "\U4e0d\U533a\U5206\U697c\U680b";
    
    self.nameLabel.text = data[@"outnodename"];
    
    AWLabelFormatShow(self.moneyTypeLabel, @"完成进度",
                      [@(HNIntegerFromObject(data[@"nodecurendvalue"], 0)) description],
                      @"%",
                      AWCustomFont(@"PingFang SC", 16),
                      MAIN_THEME_COLOR,
                      NO);
    
    if ( [data[@"nodecompletestatusnum"] integerValue] == 1 ) {
        AWLabelFormatShow(self.outMoneyLabel, @"计划完成时间",
                          HNDateFromObject(data[@"planenddate"], @"T"),
                          @"",
                          AWCustomFont(@"PingFang SC", 18),
                          AWColorFromRGB(74, 144, 226),
                          NO);
    } else {
        AWLabelFormatShow(self.outMoneyLabel, @"实际完成时间",
                          HNDateFromObject(data[@"factenddate"], @"T"),
                          @"",
                          AWCustomFont(@"PingFang SC", 18),
                          AWColorFromRGB(74, 144, 226),
                          NO);
    }
    
    
    AWLabelFormatShow(self.payMoneyLabel, @"已传附件",
                      [@(HNIntegerFromObject(data[@"annexnum"], 0)) description],
                      @"",
                      AWCustomFont(@"PingFang SC", 18),
                      AWColorFromRGB(110, 110, 110),
                      NO);
    
    if ( [data[@"nodecompletestatusnum"] integerValue] == 2 ) {
        self.confirmView.hidden = NO;
        self.confirmView.image = [UIImage imageNamed:@"icon_approving.png"];
    } else if ( [data[@"nodecompletestatusnum"] integerValue] == 3 ) {
        self.confirmView.hidden = NO;
        self.confirmView.image = [UIImage imageNamed:@"icon_approved.png"];
    } else {
        self.confirmView.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(15, 5, self.width - 30, 40);
    
    CGFloat width = (self.nameLabel.width - 10) / 3.0;
    
    self.moneyTypeLabel.frame = CGRectMake(self.nameLabel.left,
                                           self.nameLabel.bottom,
                                           width,
                                           40);
    
    self.outMoneyLabel.frame = CGRectMake(self.moneyTypeLabel.right + 5,
                                          self.moneyTypeLabel.top,
                                          width, 40);
    
    self.payMoneyLabel.frame = CGRectMake(self.outMoneyLabel.right + 5,
                                          self.moneyTypeLabel.top,
                                          width, 40);
    
    self.confirmView.position = CGPointMake(self.width - self.confirmView.width, 0);
}

- (UIImageView *)confirmView
{
    if (!_confirmView) {
        _confirmView = AWCreateImageView(nil);
        [self.contentView addSubview:_confirmView];
        
        _confirmView.frame = CGRectMake(0, 0, 32, 33);
    }
    return _confirmView;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(74, 74, 74));
        [self.contentView addSubview:_nameLabel];
        _nameLabel.numberOfLines = 2;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _nameLabel;
}

- (UILabel *)moneyTypeLabel
{
    if ( !_moneyTypeLabel ) {
        _moneyTypeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_moneyTypeLabel];
        _moneyTypeLabel.numberOfLines = 2;
        _moneyTypeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _moneyTypeLabel;
}

- (UILabel *)outMoneyLabel
{
    if ( !_outMoneyLabel ) {
        _outMoneyLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(12, NO),
                                        AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_outMoneyLabel];
        _outMoneyLabel.numberOfLines = 2;
        _outMoneyLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _outMoneyLabel;
}

- (UILabel *)payMoneyLabel
{
    if ( !_payMoneyLabel ) {
        _payMoneyLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentRight,
                                        AWSystemFontWithSize(12, NO),
                                        AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_payMoneyLabel];
        _payMoneyLabel.numberOfLines = 2;
        _payMoneyLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _payMoneyLabel;
}

@end

//
//  MeetingOrderCell.m
//  HN_ERP
//
//  Created by tomwey on 4/14/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingOrderCell.h"
#import "Defines.h"

@interface MeetingOrderCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *orderLabel;

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) id data;

@end

@implementation MeetingOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.data = data;
    
    self.nameLabel.text = data[@"mr_name"];
    self.orderLabel.text = [self formatOrderTime:data];
}

- (NSString *)formatOrderTime:(id)item
{
    NSString *orderDate = [[item[@"orderdate"] componentsSeparatedByString:@"T"] firstObject];
    NSString *beginTime = [[[item[@"begintime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
    NSString *endTime   =
    [[[item[@"endtime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *prefix = nil;
    NSString *now = [df stringFromDate:[NSDate date]];
    if ( [orderDate isEqualToString:now] ) {
        prefix = @"今天";
    } else if ( [orderDate compare:now options:NSNumericSearch] == NSOrderedDescending ) {
        prefix = @"明天";
    } else {
        prefix = orderDate;
    }
    
    return [NSString stringWithFormat:@"%@ %@-%@",prefix, beginTime, endTime];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cancelButton.center = CGPointMake(self.width - 15 - self.cancelButton.width / 2,
                                           self.height / 2);
    self.editButton.center = self.cancelButton.center;
    self.editButton.left = self.cancelButton.left - 10 - self.editButton.width;
    
    self.nameLabel.frame = CGRectMake(15, 10, self.editButton.left - 10 - 15,
                                      30);
    self.orderLabel.frame = self.nameLabel.frame;
    self.orderLabel.top = self.nameLabel.bottom;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(15, NO),
                                   [UIColor blackColor]);
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)orderLabel
{
    if ( !_orderLabel ) {
        _orderLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(137, 137, 137));
        [self.contentView addSubview:_orderLabel];
    }
    return _orderLabel;
}

- (UIButton *)editButton
{
    if ( !_editButton ) {
        _editButton = AWCreateTextButton(CGRectMake(0, 0, 50, 30),
                                         @"修改",
                                         MAIN_THEME_COLOR,
                                         self,
                                         @selector(gotoEdit));
        [self.contentView addSubview:_editButton];
        
        _editButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
        _editButton.cornerRadius = 6;
        _editButton.layer.borderColor = MAIN_THEME_COLOR.CGColor;
        _editButton.layer.borderWidth = 0.5;
    }
    return _editButton;
}

- (void)gotoEdit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kEditMeetingOrderNotification" object:self.data];
}

- (UIButton *)cancelButton
{
    if ( !_cancelButton ) {
        _cancelButton = AWCreateTextButton(CGRectMake(0, 0, 50, 30),
                                         @"取消",
                                         [UIColor whiteColor],
                                         self,
                                         @selector(cancel));
        [self.contentView addSubview:_cancelButton];
        
        _cancelButton.backgroundColor = MAIN_THEME_COLOR;
        
        _cancelButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
        _cancelButton.cornerRadius = 6;
    }
    return _cancelButton;
}

- (void)cancel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCancelMeetingOrderNotification" object:self.data];
}

@end

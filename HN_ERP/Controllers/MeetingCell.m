//
//  MeetingCell.m
//  HN_ERP
//
//  Created by tomwey on 5/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingCell.h"
#import "Defines.h"

@interface MeetingCell ()

@property (nonatomic, strong) UILabel *meetingTime;
@property (nonatomic, strong) UIView  *bgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *roomLabel;

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *actionView;

//@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) id selectedData;

@end

@implementation MeetingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
//        self.backgroundColor = [UIColor clearColor];
//        self.backgroundView = nil;
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
//        self.layoutMargins = UIEdgeInsetsZero;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    
    self.selectedData = data;
    NSInteger type = [data[@"data_type"] integerValue];
    if ( type == 0 ) {
        // 我参与的
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryView = nil;
    } else {
        // 我预定的
//        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryView  = self.actionView;
    }
    
    self.titleLabel.text = data[@"title"];
    self.roomLabel.text  = data[@"mr_name"];
    
    NSString *beginTime = [[data[@"begintime"] componentsSeparatedByString:@"T"] lastObject];
    if ( beginTime.length > 5 ) {
        beginTime = [beginTime substringToIndex:5];
    }
    
    NSString *endTime = [[data[@"endtime"] componentsSeparatedByString:@"T"] lastObject];
    if ( endTime.length > 5 ) {
        endTime = [endTime substringToIndex:5];
    }
    
    NSString *timeStr = [NSString stringWithFormat:@"%@ - %@",beginTime, endTime];
    self.meetingTime.text = timeStr;
    
    NSString *orderdate = HNDateFromObject(data[@"orderdate"], @"T");
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    if ( [orderdate isEqualToString:[df stringFromDate:now]] ) {
        // 今天
        NSString *orderDatetime = [NSString stringWithFormat:@"%@ %@",
                                   orderdate, endTime];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        if ( [orderDatetime compare:[df stringFromDate:now] options:NSNumericSearch] == NSOrderedDescending ) {
            self.borderView.backgroundColor = MAIN_THEME_COLOR;
        } else {
            self.borderView.backgroundColor = AWColorFromRGB(123, 122, 129);
        }
    } else {
        self.borderView.backgroundColor = AWColorFromRGB(123, 122, 129);
    }
    
    // 根据开始时间设置不同的Bar颜色
    // 此处只标识今天未开的会议
    
//    if ( [beginTime compare:@"12:00" options:NSNumericSearch] == NSOrderedAscending ) {
//        // 早上
//        self.borderView.backgroundColor = AWColorFromRGB(63, 188, 184);
//    } else if ( [beginTime compare:@"18:00" options:NSNumericSearch] == NSOrderedDescending ) {
//        // 晚上
//        self.borderView.backgroundColor = AWColorFromRGB(123, 122, 129);
//    } else {
//        // 下午
//        self.borderView.backgroundColor = MAIN_THEME_COLOR;
//    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.borderView.frame = CGRectMake(15, 13,
                                       2,
                                       self.height - 26);
    self.titleLabel.frame = CGRectMake(self.borderView.right + 10,
                                       8,
                                       self.width - self.borderView.right - 10 - 20,
                                       25);
    
    self.meetingTime.frame = self.titleLabel.frame;
    self.meetingTime.top   = self.titleLabel.bottom;
    self.meetingTime.width = 96;
    
    self.roomLabel.frame = self.meetingTime.frame;
    self.roomLabel.left  = self.meetingTime.right + 5;
    self.roomLabel.width = 160;
}

- (UIView *)actionView
{
    if ( !_actionView ) {
        _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        
        // 编辑按钮
//        FAKFontAwesome
        FAKIonIcons *editIcon = [FAKIonIcons androidCreateIconWithSize:24];
        [editIcon addAttributes:@{
                                    NSForegroundColorAttributeName:
                                        self.titleLabel.textColor
                                    }];
        UIButton *editBtn = [self createButtonWithFAKIcon:editIcon
                                                   inView:_actionView
                                                   action:@selector(edit)];
        
        FAKIonIcons *cancelIcon = [FAKIonIcons androidRemoveCircleIconWithSize:24];
        [cancelIcon addAttributes:@{
                                    NSForegroundColorAttributeName: MAIN_THEME_COLOR
                                    }];
        UIButton *cancelBtn = [self createButtonWithFAKIcon:cancelIcon
                                                     inView:_actionView
                                                     action:@selector(cancel)];
        
        cancelBtn.position = CGPointMake(0, 0);
        editBtn.position = CGPointMake(cancelBtn.right, 0);
    }
    return _actionView;
}

- (UIButton *)createButtonWithFAKIcon:(FAKIcon *)icon
                               inView:(UIView *)view
                               action:(SEL)action
{
    UIImage *image = [icon imageWithSize:CGSizeMake(30, 30)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:button];
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    button.exclusiveTouch = YES;
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)meetingTime
{
    if ( !_meetingTime ) {
        _meetingTime = AWCreateLabel(CGRectZero,
                                     nil,
                                     NSTextAlignmentLeft,
                                     AWSystemFontWithSize(15, NO),
                                     self.roomLabel.textColor
                                     );
        [self.contentView addSubview:_meetingTime];
    }
    return _meetingTime;
}

- (UIView *)bgView
{
    if ( !_bgView ) {
        _bgView = [[UIView alloc] init];
        [self.contentView addSubview:_bgView];
        _bgView.backgroundColor = self.meetingTime.backgroundColor;
    }
    return _bgView;
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
    }
    return _titleLabel;
}

- (UILabel *)roomLabel
{
    if ( !_roomLabel ) {
        _roomLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(133, 133, 133));
        [self.contentView addSubview:_roomLabel];
    }
    return _roomLabel;
}

- (UIView *)borderView
{
    if ( !_borderView ) {
        _borderView = [[UIView alloc] init];
        [self.contentView addSubview:_borderView];
        _borderView.backgroundColor = MAIN_THEME_COLOR;
    }
    return _borderView;
}

- (void)edit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateMeetingOrderNotification" object:self.selectedData];
}

- (void)cancel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCancelMeetingOrderNotification" object:self.selectedData];
}

@end

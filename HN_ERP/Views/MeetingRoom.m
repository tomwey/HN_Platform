//
//  MeetingRoom.m
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingRoom.h"
#import "Defines.h"

@interface MeetingRoom ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *orderCountLabel;

@end

@implementation MeetingRoom

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    }
    return self;
}

- (void)tap {
    if ( self.openBlock ) {
        self.openBlock(self);
    }
}

- (void)setMeetingData:(id)meetingData
{
    if ( meetingData == _meetingData ) {
        return;
    }
    
    _meetingData = meetingData;
    
    self.nameLabel.text = _meetingData[@"mr_name"];
    
//    NSInteger count = [_meetingData[@"count"] integerValue];
//    self.orderCountLabel.text = count <= 0 ? @"没有预定" :
//    [NSString stringWithFormat:@"%d个预定", count];
    
    id data = meetingData[@"data"];
    if ( [data isKindOfClass:[NSArray class]] ) {
        [self addOrderContents];
    } else {
        self.orderCountLabel.text = @"无预定";
    }
    
    UIColor *color = nil;
    /*if ( [self.nameLabel.text isEqualToString:@"多功能会议室"] ) {
        color = @"#4DA312";
    } else */if ( [self.nameLabel.text hasPrefix:@"总裁会议室"] ) {
        color = MAIN_THEME_COLOR; //@"#B62C2A";
    } else {
        color = AWColorFromRGB(241,239,239);//AWColorFromHex(@"#646464");
    }
    
    color = AWColorFromRGB(241,239,239);
    
    self.nameLabel.backgroundColor = color;//AWColorFromHex(color);
    self.nameLabel.textColor = AWColorFromRGB(102, 102, 102);
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.borderColor = self.nameLabel.backgroundColor.CGColor;
    self.layer.borderWidth = 0.5;
    
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
}

- (void)addOrderContents
{
    NSArray *data = self.meetingData[@"data"];
    
    NSMutableString *string = [NSMutableString string];
    NSInteger count = MIN(4, data.count);
    
    for (int i=0; i<count; i++) {
        id dict = data[i];
        [string appendFormat:@"%@\n", [self formatOrderTime:dict]];
    }
    
    if ( data.count > 4 ) {
        [string appendString:@"..."];
    } else {
        [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
    }
    
    self.orderCountLabel.text = string;
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
    
    return [NSString stringWithFormat:@"%@-%@",beginTime, endTime];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(0, 0, self.width, 30);
    
    self.orderCountLabel.frame = CGRectMake(0, 0, self.width, (self.height - self.nameLabel.height) * 0.8 );
    
    self.orderCountLabel.center = CGPointMake(self.width / 2,
                                              self.height / 2 + self.nameLabel.height / 2);
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero, nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(12, NO),
                                   [UIColor whiteColor]);
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)orderCountLabel
{
    if ( !_orderCountLabel ) {
        _orderCountLabel = AWCreateLabel(CGRectZero, nil,
                                   NSTextAlignmentCenter,
                                   AWCustomFont(@"Arial", 13),
                                   AWColorFromRGB(137, 137, 137));
        [self addSubview:_orderCountLabel];
        _orderCountLabel.numberOfLines = 0;
//        _orderCountLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _orderCountLabel;
}

@end

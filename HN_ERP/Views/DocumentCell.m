//
//  DocumentCell.m
//  HN_ERP
//
//  Created by tomwey on 2/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DocumentCell.h"
#import "Defines.h"

@interface DocumentCell ()

@property (nonatomic, strong) UIView  *contentContainer;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *summaryLabel;

//@property (nonatomic, strong) UIView *redDot;

//@property (nonatomic, strong) UILabel *unreadLabel;

//@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIImageView *newIconView;

@property (nonatomic, copy) NSString *currentDocId;

@property (nonatomic, strong) id currentData;

@end

@implementation DocumentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        if ( [self respondsToSelector:@selector(setLayoutMargins:)] ) {
//            self.layoutMargins = UIEdgeInsetsZero;
//        }
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateReadState:) name:@"kDocHasReadedNotification" object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.container.frame = CGRectMake(0, 10, self.width, self.height - 10);
    self.contentContainer.frame = CGRectMake(0, 10, self.width, self.height - 10);
    
    self.newIconView.position = CGPointMake(self.contentContainer.width - self.newIconView.width + 1, -1);
    
    self.titleLabel.frame = CGRectMake(15, 0, self.width - 60, 50);
    
//    self.redDot.center = CGPointMake(8, self.titleLabel.midY);
//    self.unreadLabel.center = CGPointMake(8, self.titleLabel.midY);
    
//    self.timeLabel.frame = self.titleLabel.frame;
//    self.timeLabel.top = self.titleLabel.bottom;
//    self.timeLabel.height = 25;
    
    self.summaryLabel.frame = CGRectMake(15, self.titleLabel.bottom - 5, self.titleLabel.width, 30);
//    self.summaryLabel.top = self.titleLabel.bottom - 3;
//    self.summaryLabel.height = 25;
    
    self.timeLabel.frame = self.summaryLabel.frame;
    self.timeLabel.left = self.width - 15 - self.timeLabel.width;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.currentData = data;
    
    self.titleLabel.text = data[@"title"];
    
    self.timeLabel.text = data[@"time"];
    
    self.currentDocId = [data[@"docid"] description];
    
    // ●
    NSString *area = [data[@"area"] description];
    if ( [area isEqualToString:@"全部"] ) {
        area = @"全部区域";
    }
    
    NSString *scope = [data[@"scope"] description];
    if ( [scope isEqualToString:@"全部"] ) {
        scope = @"全部业态";
    }
    self.summaryLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                              area, scope, data[@"type"]];
    
    if ( [self.currentData[@"is_read"] boolValue] ) {
        self.newIconView.hidden = YES;
    } else {
        self.newIconView.hidden = NO;
    }
    
//    self.newIconView.hidden = NO;
}

- (void)updateReadState:(NSNotification *)noti
{
    NSString *docId = [noti.object description];
    if ( [docId isEqualToString:self.currentDocId] ) {
        self.newIconView.hidden = YES;
        
        self.currentData[@"is_read"] = @"1";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedReloadBadgeNotification object:@"documents"];
    }
}

- (UIView *)contentContainer
{
    if ( !_contentContainer ) {
        _contentContainer = [[UIView alloc] init];
        [self.contentView addSubview:_contentContainer];
        _contentContainer.backgroundColor = [UIColor whiteColor];
    }
    return _contentContainer;
}

- (UIImageView *)newIconView
{
    if ( !_newIconView ) {
        _newIconView = AWCreateImageView(@"icon_unread.png");
        [self.contentContainer addSubview:_newIconView];
        _newIconView.frame = CGRectMake(0, 0, 30, 30);
    }
    return _newIconView;
}

//- (UIView *)redDot
//{
//    if ( !_redDot ) {
//        _redDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
//        [self.contentContainer addSubview:_redDot];
//        _redDot.backgroundColor = AWColorFromRGB(201, 62, 59);
//        _redDot.cornerRadius = _redDot.height / 2;
//    }
//    return _redDot;
//}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    [UIFont systemFontOfSize:14],
                                    [UIColor blackColor]);
        [self.contentContainer addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentRight,
                                    [UIFont systemFontOfSize:14],
                                    AWColorFromRGB(137,137,137));
        [self.contentContainer addSubview:_timeLabel];
    }
    return _timeLabel;
}

//- (UILabel *)unreadLabel
//{
//    if ( !_unreadLabel ) {
//        _unreadLabel = AWCreateLabel(CGRectZero,
//                                   nil,
//                                   NSTextAlignmentRight,
//                                   [UIFont systemFontOfSize:14],
//                                   AWColorFromRGB(201,62,59));
//        [self.contentContainer addSubview:_unreadLabel];
//        _unreadLabel.text = @"●";
//        
//        self.unreadLabel.frame = CGRectMake(0, 0, 8, 10);
//    }
//    return _unreadLabel;
//}

- (UILabel *)summaryLabel
{
    if ( !_summaryLabel ) {
        _summaryLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    [UIFont systemFontOfSize:14],
                                    IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR);
        [self.contentContainer addSubview:_summaryLabel];
    }
    return _summaryLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  MessageCell.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OACell.h"
#import "Defines.h"

@interface OACell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *endView;
@property (nonatomic, strong) UIImageView *readView;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UILabel *badge;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, copy) void (^itemDidSelectBlock)(UIView<AWTableDataConfig> *sender, id selectedData);

@property (nonatomic, strong) id selectedData;

@property (nonatomic) dispatch_queue_t loadImageQueue;

@property (nonatomic) NSOperationQueue *loadImageOperationQueue;

@end

@implementation OACell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
//        self.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)reformerData:(id)data
{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
//    temp[@"icon"] = @"work_icon_meeting.png";
    
//    "create_date" = "2017-01-11T14:34:36+08:00";
//    "create_id" = 1691909;
//    "create_name" = "\U5434\U601d\U9759";
//    did = 1567;
//    "flow_desc" = "\U5185\U5ba1\U6d4b\U8bd55";
//    "flow_grade_desc" = "\U6b63\U5e38";
//    flowstate = 0;
//    mid = 1190;
//    "workflow_showname" = "\U5de5\U7a0b\U6b3e\U4ed8\U6b3e\U6d41\U7a0b-\U8d28\U4fdd\U91d1";
    
    temp[@"is_notice"] = [data[@"flow_grade_desc"] isEqualToString:@"重要"] ?
        @"1" : @"0";
    temp[@"title"] = [data[@"flow_desc"] description];
    temp[@"proj_name"] = [data[@"project_aliasname"] description];
    temp[@"creator"] = [data[@"create_name"] description];
    temp[@"is_end"] = @"0";
    
    // 处理日期
    NSString *time = [data[@"flowdate"] description];
    time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *specialTimeStr = @"+08:00";
    NSRange range = [time rangeOfString:specialTimeStr];
    if ( range.location != NSNotFound ) {
        time = [time substringToIndex:range.location];
    }
    
    temp[@"time"] = time;
    temp[@"icon"] = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=48&d=identicon&r=PG", [[temp[@"creator"] description] md5Hash]];
    
    return [temp copy];
}

- (dispatch_queue_t)loadImageQueue
{
    if ( !_loadImageQueue ) {
        _loadImageQueue = dispatch_queue_create("cn.heneng.load-image-queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _loadImageQueue;
}

- (NSOperationQueue *)loadImageOperationQueue
{
    if ( !_loadImageOperationQueue ) {
        _loadImageOperationQueue = [[NSOperationQueue alloc] init];
        _loadImageOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        _loadImageOperationQueue.name = @"cn.heneng.load-icon-queue";
    }
    return _loadImageOperationQueue;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.selectedData = data;
    
    int stateType = [data[@"state_type"] intValue];
    
//    NSLog(@"state_type: %@", data[@"state_type"]);
    data = [self reformerData:data];
    
    self.itemDidSelectBlock = selectBlock;
    
//    self.iconView.image = [UIImage imageNamed:data[@"icon"]];
//    [self.iconView setImageWithURL:[NSURL URLWithString:data[@"icon"]]
//                  placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    self.iconView.image = [UIImage imageNamed:@"default_avatar.png"];

    // 异步生成icon
    __weak typeof(self) weakSelf = self;
    [self.loadImageOperationQueue addOperationWithBlock:^{
        UIImage *image =
            [HNImageHelper imageForName:self.selectedData[@"create_name"]
                                  manID:[self.selectedData[@"create_id"] integerValue]
                                   size:CGSizeMake(48, 48)];
        if ( image ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong OACell *strongSelf = weakSelf;
                if ( strongSelf ) {
                    strongSelf.iconView.image = image;
                }
//                self.iconView.image = image;
            });
        }
    }];
//    dispatch_async(self.loadImageQueue, ^{
//        UIImage *image = [HNImageHelper imageForName:self.selectedData[@"create_name"]
//                                               manID:[self.selectedData[@"create_id"] integerValue]
//                                                size:CGSizeMake(48, 48)];
//        if ( image ) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.iconView.image = image;
//            });
//        }
//        
//    });

    if ([data[@"is_notice"] integerValue] == 1) {
        NSString *text = [NSString stringWithFormat:@"*【%@】%@", data[@"proj_name"], data[@"title"]];
        NSMutableAttributedString *string =
        [[NSMutableAttributedString alloc] initWithString:text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
        self.titleLabel.attributedText = string;
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"【%@】%@",data[@"proj_name"],data[@"title"]];
    }
    
    self.bodyLabel.text = data[@"creator"];
    self.timeLabel.text = data[@"time"];
    
//    if ([data[@"is_end"] boolValue]) {
//        self.endView.hidden = NO;
//    } else {
//        self.endView.hidden = YES;
//    }
    
    if (self.selectedData[@"state_num"]) {
//        self.endView.hidden = NO;
        self.stateLabel.hidden = NO;
        
        NSString *imageName = nil;
        NSString *stateName = nil;
        UIColor  *stateColor = nil;
        NSInteger sNum = [self.selectedData[@"state_num"] integerValue];
        switch (sNum) {
            case 10:
                imageName = @"icon_flowing.png";
                stateName = @"流转中";
                stateColor = AWColorFromHex(@"#E8A02A");
                break;
            case 40:
                imageName = @"icon_done.png";
                stateName = @"已归档";
                stateColor = AWColorFromHex(@"#54ae3b");
                break;
            case 80:
                imageName = @"icon_force_done.png";
                stateName = @"强制归档";
                stateColor = AWColorFromRGB(171, 22, 34);
                break;
                
            default:
                break;
        }
//        self.endView.image = [UIImage imageNamed:imageName];
        
        self.stateLabel.text = stateName;
        self.stateLabel.backgroundColor = stateColor;
    } else {
//        self.endView.hidden = YES;
        self.stateLabel.hidden = YES;
    }
    
    if ( stateType == 1 ) {
//        self.endView.hidden = YES;
        self.stateLabel.hidden = YES;
    } else {
        
    }
    
    NSInteger flowState = [self.selectedData[@"flowstate"] integerValue];
    NSString *imageName = nil;
    if ( flowState == -1 ) {
        imageName = @"icon_read_nop.png";
    } else if ( flowState == 0 ) {
        imageName = @"icon_unread.png";
    } else if ( flowState == 1 ) {
        imageName = @"icon_read.png";
    }
    
    self.readView.image = [UIImage imageNamed:imageName];
    
    if ( flowState == -1 ) {
        self.readView.hidden = YES;
    } else {
        self.readView.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.container.frame = CGRectMake(0, 10, self.width, self.height - 10);
    
    self.iconView.center = CGPointMake(15 + self.iconView.width / 2,
                                       self.container.height / 2);
    self.titleLabel.frame = CGRectMake(self.iconView.right + 15,
                                       0,
                                       self.width - self.iconView.right - 15 - 15 - 30, 60);
    
    self.bodyLabel.frame = CGRectMake(self.titleLabel.left,
                                      self.titleLabel.bottom - 10,
                                      40, 20);
//    CGSize size = [self.bodyLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.bodyLabel.font }];
//    self.bodyLabel.width = size.width;
    
    self.timeLabel.frame = CGRectMake(self.bodyLabel.right,
                                      self.bodyLabel.top,
                                      140, 20);
    
    [self.stateLabel sizeToFit];
    self.stateLabel.width += 4;
    self.stateLabel.height += 4;
    
    self.stateLabel.position = CGPointMake(self.timeLabel.right + 5,
                                           self.timeLabel.midY - self.stateLabel.height / 2);
    
//    self.endView.center = CGPointMake(self.container.width - 8 - self.endView.width / 2,
//                                        self.timeLabel.midY);
    
    self.readView.position = CGPointMake(self.container.width - self.readView.width + 1, -1);
//    self.readView.position = CGPointMake(self.container.width - self.readView.width, 8);
}

- (void)doTap
{
    if ( self.itemDidSelectBlock ) {
        self.itemDidSelectBlock(self, self.selectedData);
    }
}

- (UIView *)container
{
    if ( !_container ) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_container];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(doTap)];
        [_container addGestureRecognizer:tap];
    }
    return _container;
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        _iconView.frame = CGRectMake(0, 0, 48, 48);
        _iconView.cornerRadius = _iconView.height / 2;
        [self.container addSubview:_iconView];
    }
    return _iconView;
}

- (UIImageView *)endView
{
    if ( !_endView ) {
        _endView = AWCreateImageView(@"icon_force_done.png");
        [self.container addSubview:_endView];
        _endView.frame = CGRectMake(0, 0, 18, 18);
    }
    return _endView;
}

- (UIImageView *)readView
{
    if ( !_readView ) {
        _readView = AWCreateImageView(@"icon_read.png");
        [self.container addSubview:_readView];
        _readView.frame = CGRectMake(0, 0, 30, 30);
//        _readView.frame = CGRectMake(0, 0, 40, 15);
    }
    return _readView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    [UIColor blackColor]);
        [self.container addSubview:_titleLabel];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)bodyLabel
{
    if ( !_bodyLabel ) {
        _bodyLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(13, NO),
                                    AWColorFromRGB(181,181,181));
        [self.container addSubview:_bodyLabel];
    }
    return _bodyLabel;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(13, NO),
                                   AWColorFromRGB(181,181,181));
        [self.container addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)stateLabel
{
    if ( !_stateLabel ) {
        _stateLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(8, NO),
                                   [UIColor whiteColor]);
        [self.container addSubview:_stateLabel];
        
        _stateLabel.layer.cornerRadius = 2;
        _stateLabel.clipsToBounds      = YES;
    }
    return _stateLabel;
}

@end

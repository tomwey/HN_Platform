//
//  MessageCell.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OACell2.h"
#import "Defines.h"

@interface OACell2 ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *projNameLabel;
@property (nonatomic, strong) UILabel     *timeLabel;
@property (nonatomic, strong) UILabel     *creatorLabel;
@property (nonatomic, strong) UILabel     *stateLabel;

@property (nonatomic, strong) UIImageView *flowReadView;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, copy) void (^itemDidSelectBlock)(UIView<AWTableDataConfig> *sender, id selectedData);

@property (nonatomic, strong) id selectedData;

@property (nonatomic) dispatch_queue_t loadImageQueue;

@property (nonatomic) NSOperationQueue *loadImageOperationQueue;

@end

@implementation OACell2

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(markFlowReaded:) name:@"kMarkFlowReadNotification" object:nil];
    }
    return self;
}

- (void)markFlowReaded:(NSNotification *)noti
{
    id data = noti.object;
    if ( data == self.selectedData ) {
        NSInteger state = [self.selectedData[@"flowstate"] integerValue];
        if ( state == 0 ) {
            // 处理未读的待办，本地客户端标记为已读，隐藏小圆点
            self.flowReadView.hidden = YES;
            self.selectedData[@"flowstate"] = @"-1";
        }
    }
}

- (id)reformerData:(id)data
{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    
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
    self.itemDidSelectBlock = selectBlock;
    
//    int stateType = [data[@"state_type"] intValue];
    
    // reformer data
    data = [self reformerData:data];
    
    // 设置头像
    self.iconView.image = [UIImage imageNamed:@"default_avatar.png"];

    [self.iconView setImageWithManInfo:HNManInfoCreate([self.selectedData[@"create_id"] integerValue],
                                                       self.selectedData[@"create_name"])];
    // 异步生成icon
//    __weak typeof(self) weakSelf = self;
    
//    [self fetchAvatar:^(UIImage *anImage, NSError *error) {
//        if ( anImage ) {
//            __strong OACell2 *strongSelf = weakSelf;
//            strongSelf.iconView.image = anImage;
//        }
//    }];
    
    // 流程是否已阅
    NSInteger flowState = [self.selectedData[@"flowstate"] integerValue];
    if ( flowState == 0 ) {
        // 未读
        self.flowReadView.hidden = NO;
        
        self.flowReadView.backgroundColor = MAIN_THEME_COLOR;
    } else if ( flowState == 1 ) {
        // 已读，并且有新意见
        
        self.flowReadView.hidden = NO;
        
        self.flowReadView.backgroundColor = AWColorFromRGB(138, 138, 138);
        
    } else {
        self.flowReadView.hidden = YES;
    }
    
    // 设置流程说明
    NSString *notice = @"";
    if ( [data[@"is_notice"] integerValue] == 1 ) {
        notice = @"! ";
    }
    
    NSString *text = [NSString stringWithFormat:@"%@%@", notice, data[@"title"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    
    if ( notice.length > 0 ) {
        [string addAttributes:@{
                                NSForegroundColorAttributeName: [UIColor redColor],
                                //NSFontAttributeName: AWSystemFontWithSize(20, NO)
                                }
                        range:NSMakeRange(0, 1)];
    }
    
    self.titleLabel.attributedText = string;
    
    // 设置项目名称
    self.projNameLabel.text = HNStringFromObject(data[@"proj_name"], @"");
    
    // 设置流程创建人
    self.creatorLabel.text  = data[@"creator"];
    
    // 设置时间
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat       = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [df dateFromString:data[@"time"]];
    
    self.timeLabel.text = [date timeAgo];
    
    // 设置流程状态
    int stateType = [self.selectedData[@"state_type"] intValue];
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
                stateName = @"审批中";
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
        
        self.stateLabel.text = stateName;
        self.stateLabel.backgroundColor = stateColor;
    } else {
        self.stateLabel.hidden = YES;
    }
    
    if ( stateType == 1 ) {
        self.stateLabel.hidden = YES;
    } else {
//        self.stateLabel.hidden = NO;
    }
}

- (void)dealloc
{
    [self.loadImageOperationQueue cancelAllOperations];
    self.loadImageOperationQueue = nil;
}

+ (NSString *)cachedFileDirForDir:(NSString *)dir
{
    NSString *cachedDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cachedDir = [cachedDir stringByAppendingPathComponent:@"hn-files"];
    if ( dir ) {
        cachedDir = [cachedDir stringByAppendingPathComponent:dir];
    }
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:cachedDir] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachedDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachedDir;
}

- (void)fetchAvatar:(void (^)(UIImage *anImage, NSError *error))callback
{
    NSString *cachedAvatarDir = [[self class] cachedFileDirForDir:@"avatars"];
    
    NSString *avatarFileName = [NSString stringWithFormat:@"%@_%@.png",
                            self.selectedData[@"create_name"], self.selectedData[@"create_id"]];
    
    NSString *avatarFile = [cachedAvatarDir stringByAppendingPathComponent:avatarFileName];
    
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:avatarFile];
    if ( cachedImage ) {
        if ( callback ) {
            callback(cachedImage, nil);
        }
    } else {
        [self.loadImageOperationQueue addOperationWithBlock:^{
            UIImage *image =
            [HNImageHelper imageForName:self.selectedData[@"create_name"]
                                  manID:[self.selectedData[@"create_id"] integerValue]
                                   size:CGSizeMake(48, 48)];
            
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if ( image ) {
                        [UIImagePNGRepresentation(image) writeToFile:avatarFile atomically:YES];
                        
                        if ( callback ) {
                            callback(image, nil);
                        }
                    } else {
                        if ( callback ) {
                            callback(nil, nil); // 简单处理
                        }
                    }
                    
                }];
        }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // ios 10.3.1 有问题, 获取cell的高度有问题，所以此处写死高度为80
    self.container.frame = CGRectMake(0, 10, self.width, 80);
    
    self.iconView.center = CGPointMake(18 + self.iconView.width / 2,
                                       self.container.height / 2);
    
    self.titleLabel.frame = CGRectMake(0, 0, self.width - self.iconView.right - 15 - 15 - 60, 40);
    
    self.titleLabel.position = CGPointMake(self.iconView.right + 10,
                                           self.iconView.top - 5);
    
    self.flowReadView.center = CGPointMake(10, self.container.height / 2);
    // 设置时间坐标
    self.timeLabel.frame = CGRectMake(0, 0, 60, 20);
    self.timeLabel.center = CGPointMake(self.width - 15 - self.timeLabel.width / 2,self.iconView.top + self.timeLabel.height / 2 );
    
    // 设置项目名坐标
    self.projNameLabel.frame = self.titleLabel.frame;
    self.projNameLabel.top   = self.titleLabel.bottom;
    [self.projNameLabel sizeToFit];
    
    // 设置创建人坐标
    self.creatorLabel.frame = self.timeLabel.frame;
    self.creatorLabel.top  = self.iconView.bottom - self.creatorLabel.height;//self.projNameLabel.midY - self.creatorLabel.height / 2;
    
    // 设置流程状态坐标
    [self.stateLabel sizeToFit];
    
    self.stateLabel.width  += 6;
    self.stateLabel.height += 4;
    
    self.stateLabel.position = CGPointMake(self.titleLabel.left,
                                           80 - 14 - self.stateLabel.height);
    
    if ( self.stateLabel.hidden ) {
        self.projNameLabel.left = self.titleLabel.left;
    } else {
        self.projNameLabel.left = self.stateLabel.right + 10;
    }
    
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
        _timeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UILabel *)projNameLabel
{
    if ( !_projNameLabel ) {
        _projNameLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(13, NO),
                                    AWColorFromRGB(138,138,138));
        [self.container addSubview:_projNameLabel];
    }
    return _projNameLabel;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   self.projNameLabel.font,
                                   self.projNameLabel.textColor);
        [self.container addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)creatorLabel
{
    if ( !_creatorLabel ) {
        _creatorLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   self.projNameLabel.font,
                                   self.projNameLabel.textColor);
        [self.container addSubview:_creatorLabel];
    }
    return _creatorLabel;
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

- (UIImageView *)flowReadView
{
//    return nil;
    if ( !_flowReadView ) {
        _flowReadView = AWCreateImageView(nil);
        _flowReadView.frame = CGRectMake(0, 0, 8, 8);
        _flowReadView.cornerRadius = _flowReadView.height / 2;
        [self.container addSubview:_flowReadView];
    }
    return _flowReadView;
}

@end

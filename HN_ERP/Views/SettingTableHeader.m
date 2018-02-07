//
//  SettingTableHeader.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "SettingTableHeader.h"
#import "Defines.h"

@interface SettingTableHeader ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *nickname;
@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, weak, readwrite) UIView *scrollZoomableView;

@end

@implementation SettingTableHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        UIImageView *bgView = AWCreateImageView(nil);
        [self addSubview:bgView];
        bgView.image = AWImageNoCached(@"setting-header.png");
        bgView.backgroundColor = MAIN_THEME_COLOR;
        self.frame = bgView.frame = CGRectMake(0, 0, AWFullScreenWidth(), 192);
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        bgView.clipsToBounds = YES;
        
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.scrollZoomableView = bgView;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self];
    if ( CGRectContainsPoint(self.avatarView.frame, location) ||
        CGRectContainsPoint(self.nickname.frame, location)) {
        if ( self.didSelectCallback ) {
            self.didSelectCallback(self);
        }
    }
}

- (void)setCurrentUser:(id)currentUser
{
    _currentUser = currentUser;
    
//    NSURL *url = !!currentUser.avatar ? [NSURL URLWithString:currentUser.avatar] : nil;
//    [self.avatarView setImageWithURL:currentUser[@"avatar"] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    
//    [HNImageHelper imageForName:currentUser[@"man_name"]
//                          manID:[currentUser[@"man_id"] integerValue]
//                           size:CGSizeMake(60, 60)
//                completionBlock:^(UIImage *anImage, NSError *error) {
//                    if ( anImage ) {
//                        self.avatarView.image = anImage;
//                    }
//                }];
    [self.avatarView setImageWithManInfo:HNManInfoCreate([currentUser[@"man_id"] integerValue], currentUser[@"man_name"])];
    
    
    self.nickname.text = currentUser[@"man_name"];
    //currentUser ? [currentUser formatUsername] : @"唐伟";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.center = CGPointMake(self.width / 2, self.height / 2 - 20);
    
//    self.arrowView.center  = CGPointMake(self.width - 15 - self.arrowView.width / 2, self.avatarView.midY);
    
    self.nickname.frame    = CGRectMake(0, 0, 80, 34);
    self.nickname.center   = CGPointMake(self.width / 2, self.avatarView.bottom + 10 + self.nickname.height / 2);
}

- (UIImageView *)avatarView
{
    if ( !_avatarView ) {
        _avatarView = AWCreateImageView(@"default_avatar.png");
        [self addSubview:_avatarView];
        _avatarView.frame = CGRectMake(0, 0, 60, 60);
        _avatarView.cornerRadius = _avatarView.height / 2;
    }
    return _avatarView;
}

- (UILabel *)nickname
{
    if ( !_nickname ) {
        _nickname = AWCreateLabel(CGRectZero, @"请登录",
                                  NSTextAlignmentCenter,
                                  AWSystemFontWithSize(14, NO),
                                  /*AWColorFromRGB(131, 131, 131)*/[UIColor whiteColor]);
        [self addSubview:_nickname];
        _nickname.backgroundColor = [UIColor blackColor];
        _nickname.alpha = 0.7;
        
        _nickname.cornerRadius = 6;
    }
    return _nickname;
}

@end

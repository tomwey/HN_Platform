//
//  AWButton.m
//  RTA
//
//  Created by tangwei1 on 16/10/24.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "AWButton.h"

@interface AWButton ()

@property (nonatomic, weak)   id  target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView  *disableView;

// 下面的属性用于禁用按钮功能
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, copy) void (^countdownCompletionBlock)(AWButton *sender);
@property (nonatomic, copy) NSString *originTitle;

@end

@implementation AWButton

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)bgColor
{
    if ( self = [super init] ) {
        self.title = title;
        self.bgColor = bgColor;
        
        _enabled = YES;
        _outline = NO;
        _cornerRadius = 6.0;
        
        self.clipsToBounds = YES;
        
        self.backgroundColor = self.bgColor;
        self.titleLabel.text = self.title;
        
        self.titleLabel.textColor = self.bgColor;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        [self updateUI];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ( !_enabled ) {
                return;
            }
            
            if ( self.outline ) {
                self.backgroundColor = self.bgColor;
                self.titleLabel.textColor = [UIColor whiteColor];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if ( !_enabled ) {
                return;
            }
            
            if ( self.outline ) {
                self.backgroundColor = [UIColor whiteColor];
                self.titleLabel.textColor = self.bgColor;
            }
            
            if ( [self.target respondsToSelector:self.action] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if ( !_enabled ) {
                return;
            }
            
            if ( self.outline ) {
                self.backgroundColor = [UIColor whiteColor];
                self.titleLabel.textColor = self.bgColor;
            }
        }
            break;
            
        default:
            break;
    }
}

/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ( !_enabled ) {
        return;
    }
    
    if ( self.outline ) {
        self.backgroundColor = self.bgColor;
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ( !_enabled ) {
        return;
    }
    
    if ( self.outline ) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = self.bgColor;
    }
    
    if ( [self.target respondsToSelector:self.action] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ( !_enabled ) {
        return;
    }
    
    if ( self.outline ) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = self.bgColor;
    }
}
*/
- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    [self updateUI];
}

- (void)setOutline:(BOOL)outline
{
    _outline = outline;
    
    [self updateUI];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    
    [self updateUI];
}

+ (instancetype)buttonWithTitle:(NSString *)title color:(UIColor *)bgColor
{
    return [[self alloc] initWithTitle:title color:bgColor];
}

- (void)addTarget:(id)target forAction:(SEL)action
{
    self.target = target;
    self.action = action;
}

- (void)updateUI
{
    self.layer.cornerRadius = _cornerRadius;
    
    if ( self.outline ) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [self.bgColor CGColor];
        self.titleLabel.textColor = self.bgColor;
        self.backgroundColor = [UIColor whiteColor];
        
        self.disableView.hidden = YES;
        
    } else {
        self.layer.borderWidth = 0.0;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = self.bgColor;
        
        if ( _enabled == NO ) {
            self.disableView.hidden = NO;
        } else {
            self.disableView.hidden = YES;
        }
    }
    
    self.userInteractionEnabled = _enabled;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)setTitleAttributes:(NSDictionary *)titleAttributes
{
    _titleAttributes = titleAttributes;
    
    if ( titleAttributes[NSFontAttributeName] ) {
        self.titleLabel.font = titleAttributes[NSFontAttributeName];
    }
    
    if ( titleAttributes[NSForegroundColorAttributeName] ) {
        self.titleLabel.textColor = titleAttributes[NSForegroundColorAttributeName];
    }
}

- (void)disableDuration:(NSUInteger)duration completionBlock:(void (^)(AWButton *sender))completionBlock
{
    if ( duration == 0 ) {
        return;
    }
    
    self.counter = duration;
    self.countdownCompletionBlock = completionBlock;
    self.enabled = NO;
    
    self.originTitle = self.title;
    
    [self.countdownTimer setFireDate:[NSDate date]];
}

- (void)countdown
{
    self.title = [@(--self.counter) description];
    if ( self.counter <= 0 ) {
        
        [self.countdownTimer invalidate];
        _countdownTimer = nil;
        
        self.title = self.originTitle;
        self.enabled = YES;
        
        if ( self.countdownCompletionBlock ) {
            self.countdownCompletionBlock(self);
            self.countdownCompletionBlock = nil;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectInset(self.bounds, 10, 10);
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_titleLabel];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)disableView
{
    if ( !_disableView ) {
        _disableView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_disableView];
        _disableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _disableView.backgroundColor = [UIColor lightGrayColor];
        _disableView.alpha = 0.6;
    }
    
    [self bringSubviewToFront:_disableView];
    
    return _disableView;
}

- (NSTimer *)countdownTimer
{
    if ( !_countdownTimer ) {
        _countdownTimer = [NSTimer timerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(countdown)
                                                userInfo:nil
                                                 repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_countdownTimer forMode:NSRunLoopCommonModes];
        [_countdownTimer setFireDate:[NSDate distantFuture]];
    }
    return _countdownTimer;
}

@end

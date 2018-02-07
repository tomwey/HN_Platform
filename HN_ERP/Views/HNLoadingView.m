//
//  HNLoadingView.m
//  HN_ERP
//
//  Created by tomwey on 2/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNLoadingView.h"
#import "Defines.h"

#define INDICATOR_DEFAULT_OFFSET 30

@interface HNLoadingView ()

// 加载失败或者数据加载为空时显示
@property (nonatomic, strong, readwrite) HNErrorOrEmptyView *resultView;

@property (nonatomic, strong) DGActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *logoLabel;

@property (nonatomic, assign) HNLoadingState state;

@property (nonatomic, copy) void (^reloadCallback)(void);

@end

@implementation HNLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder: aDecoder] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.state = HNLoadingStateDefault;
    
    _indicatorPosition = HNLoadingIndicatorPositionMiddle;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap)]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateIndicatorPosition];
    
    self.resultView.frame = self.bounds;
}

- (void)doTap
{
    if ( self.state == HNLoadingStateFail ||
        self.state == HNLoadingStateEmptyResult) {
        if ( self.reloadCallback ) {
            self.reloadCallback();
//            self.reloadCallback = nil;
        }
    }
}

- (void)updateIndicatorPosition
{
    switch (self.indicatorPosition) {
        case HNLoadingIndicatorPositionTop:
            self.indicatorView.center = CGPointMake(self.width/2, INDICATOR_DEFAULT_OFFSET + self.indicatorView.height / 2);
            break;
        case HNLoadingIndicatorPositionMiddle:
            self.indicatorView.center = CGPointMake(self.width/2, self.height / 2);
            break;
            
        case HNLoadingIndicatorPositionBottom:
            self.indicatorView.center = CGPointMake(self.width/2, self.height - INDICATOR_DEFAULT_OFFSET - self.indicatorView.height / 2);
            break;
            
        default:
            break;
    }
}

- (void)setIndicatorPosition:(HNLoadingIndicatorPosition)indicatorPosition
{
    if ( _indicatorPosition != indicatorPosition ) {
        _indicatorPosition = indicatorPosition;
        
        [self updateIndicatorPosition];
    }
}

- (void)startLoading
{
    self.hidden = NO;
    
    if ( self.state == HNLoadingStateLoading ) {
        return;
    }
    
    if ( self.state == HNLoadingStateFail ||
         self.state == HNLoadingStateEmptyResult ) {
        self.resultView.hidden = YES;
    }
    
    self.state = HNLoadingStateLoading;
    
    self.indicatorView.hidden = NO;
    
    if ( !self.indicatorView.animating ) {
        [self.indicatorView startAnimating];
    }
}

- (void)stopLoading:(HNLoadingState)state
     reloadCallback:(void (^)(void))reloadCallback
{
    self.reloadCallback = reloadCallback;
    
    if ( self.state == HNLoadingStateLoading ) {
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = YES;
    }
    
    if ( state == LoadingStateSuccessResult || state == LoadingStateDefault ) {
        self.resultView.hidden = YES;
        self.hidden = YES;
    } else {
        self.hidden = NO;
        self.resultView.hidden = NO;
        [self.resultView setNeedsLayout];
    }
    
    self.state = state;
}

- (DGActivityIndicatorView *)indicatorView
{
    if ( !_indicatorView ) {
        _indicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:MAIN_THEME_COLOR];
        [self addSubview:_indicatorView];
//        [_indicatorView startAnimating];
//        _indicatorView.layer.speed = 0.0f;
    }
    return _indicatorView;
}

- (HNErrorOrEmptyView *)resultView
{
    if ( !_resultView ) {
        _resultView = [[HNErrorOrEmptyView alloc] init];
        _resultView.backgroundColor = self.backgroundColor;
        [self addSubview:_resultView];
    }
    return _resultView;
}

@end

////////////////////////////////////////////////////////////////
@interface HNErrorOrEmptyView ()

@property (nonatomic, strong) UILabel     *textLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HNErrorOrEmptyView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( self.imageView.image ) {
        self.imageView.frame = CGRectMake(0, 0,
                                          self.imageView.image.size.width,
                                          self.imageView.image.size.height);
        self.imageView.center = CGPointMake(self.width / 2, self.height / 2);
    } else {
        self.imageView.frame = CGRectZero;
    }
    
    if ( self.textLabel.text ) {
        self.textLabel.frame = CGRectMake(0, 0, self.width * 0.9, 168);
        [self.textLabel sizeToFit];
        self.textLabel.center = CGPointMake(self.width / 2, self.height / 2);
    } else {
        self.textLabel.frame = CGRectZero;
    }
    
    if ( self.imageView.image && [self.textLabel.text trim].length == 0 ) {
        self.imageView.center = CGPointMake(self.width / 2, self.height / 2);
    } else if ( !self.imageView.image && self.textLabel.text ) {
        self.textLabel.center = CGPointMake(self.width / 2, self.height / 2);
    } else {
        self.imageView.center = CGPointMake(self.width / 2, self.height / 2 - self.textLabel.height / 2);
        self.textLabel.top = self.imageView.bottom;
    }
}

- (void)setText:(NSString *)text
{
    if ( _text != text ) {
        _text = text;
        
        self.textLabel.text = _text;
    }
}

- (void)setImage:(UIImage *)image
{
    if ( _image != image ) {
        _image = image;
        
        self.imageView.image = _image;
    }
}

- (void)setTextAttributes:(NSDictionary *)textAttributes
{
    if ( _textAttributes != textAttributes ) {
        _textAttributes = textAttributes;
        
        if ( _textAttributes[NSFontAttributeName] ) {
            self.textLabel.font = _textAttributes[NSFontAttributeName];
        }
        
        if ( _textAttributes[NSForegroundColorAttributeName] ) {
            self.textLabel.textColor = _textAttributes[NSForegroundColorAttributeName];
        }
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    
    if ( tintColor ) {
        self.textLabel.textColor = tintColor;
        self.imageView.tintColor = tintColor;
    }
}

- (UILabel *)textLabel
{
    if ( !_textLabel ) {
        _textLabel = AWCreateLabel(CGRectZero, nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(201, 201, 201));
        _textLabel.numberOfLines             = 3;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIImageView *)imageView
{
    if ( !_imageView ) {
        _imageView = AWCreateImageView(nil);
        [self addSubview:_imageView];
    }
    return _imageView;
}

@end

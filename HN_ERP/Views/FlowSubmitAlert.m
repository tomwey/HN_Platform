//
//  FlowSubmitAlert.m
//  HN_ERP
//
//  Created by tomwey on 4/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowSubmitAlert.h"
#import "Defines.h"

@interface NamesView : UIView

@property (nonatomic, copy) NSString *text;

- (void)showInView:(UIView *)aView frame:(CGRect)frame;

@end

@interface FlowSubmitAlert ()

@property (nonatomic, strong) UIView  *maskView;
@property (nonatomic, strong) UIView  *alertView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIButton *receiptsBtn;
@property (nonatomic, strong) UIButton *ccBtn;

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *cancelButton;

//@property (nonatomic, strong) UITextView *namesView;

@property (nonatomic, copy) void (^doneCallback)(FlowSubmitAlert *sender);

@end

@implementation FlowSubmitAlert

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.alertView.center = CGPointMake(self.width / 2, self.height / 2);
    
    self.titleLabel.frame = CGRectMake(0, 5, self.alertView.width, 34);
    
    self.messageLabel.frame = self.titleLabel.frame;
    
    self.messageLabel.top = self.titleLabel.bottom + 5;
    
    self.receiptsBtn.frame = CGRectMake(15, self.messageLabel.bottom + 10,
                                        self.alertView.width - 30,
                                        30);
    
    CGFloat width = (self.alertView.width - 30 - 10) / 2.0;
    self.okButton.frame = CGRectMake(0, 0, width, 44);
    self.okButton.position = CGPointMake(15, self.alertView.height - 10 - self.okButton.height);
    
    self.cancelButton.frame = self.okButton.frame;
    self.cancelButton.left = self.okButton.right + 10;
    
    if ( self.ccNames.length > 0 ) {
        self.ccBtn.frame = self.receiptsBtn.frame;
        self.ccBtn.top = self.okButton.top - 15 - 30;
    }
}

- (void)showInView:(UIView *)aView doneCallback:(void (^)(FlowSubmitAlert *))callback
{
    if ( !self.superview ) {
        [aView addSubview:self];
    }
    
    self.doneCallback = callback;
    
    self.titleLabel.text = @"提交流程";
    self.messageLabel.text = @"确定要提交此流程吗？";
    
    self.frame = AWFullScreenBounds();
    
    self.maskView.alpha = 0.0;
    [self bringSubviewToFront:self.alertView];
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.5;
    }];
    
    self.alertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:.3 delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)setReceipts:(NSString *)receipts
{
    _receipts = receipts;
    
    NSString *title = [NSString stringWithFormat:@"下一节点接收人：%@", receipts];
    [self.receiptsBtn setTitle:title forState:UIControlStateNormal];
    
//    NSLog(@"%@", NSStringFromCGSize([title sizeWithAttributes:@{ NSFontAttributeName: self.receiptsBtn.titleLabel.font }]));
}

- (void)setCcNames:(NSString *)ccNames
{
    _ccNames = ccNames;
    
    NSString *title = [NSString stringWithFormat:@"下一节点抄送人：%@", ccNames];
    [self.ccBtn setTitle:title forState:UIControlStateNormal];
    
//    NSLog(@"%@", NSStringFromCGSize([title sizeWithAttributes:@{ NSFontAttributeName: self.receiptsBtn.titleLabel.font }]));
    
    if ( ccNames.length > 0 ) {
        self.alertView.height = 220;
        [self setNeedsLayout];
    } else {
        self.alertView.height = 200;
    }
}

- (void)done
{
    if ( self.doneCallback ) {
        self.doneCallback(self);
        self.doneCallback = nil;
        
        [self cancel];
    }
}

- (void)cancel
{
//    self.alertView.center = CGPointMake(self.width / 2, self.height / 2);
    [UIView animateWithDuration:.2 animations:^{
        self.alertView.alpha = 0.0;
        self.maskView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UIButton *)okButton
{
    if ( !_okButton ) {
        _okButton = AWCreateTextButton(CGRectZero,
                                       @"确定",
                                       [UIColor whiteColor],
                                       self,
                                       @selector(done));
        [self.alertView addSubview:_okButton];
        
        _okButton.backgroundColor = MAIN_THEME_COLOR;
        _okButton.cornerRadius = 4;
    }
    return _okButton;
}

- (UIButton *)cancelButton
{
    if ( !_cancelButton ) {
        _cancelButton = AWCreateTextButton(CGRectZero,
                                          @"取消",
                                          [UIColor whiteColor],
                                          self,
                                          @selector(cancel));
        [self.alertView addSubview:_cancelButton];
        
        _cancelButton.backgroundColor = AWColorFromRGB(181, 180, 179);
        _cancelButton.cornerRadius = 4;
        
    }
    return _cancelButton;
}

- (UIButton *)receiptsBtn
{
    if ( !_receiptsBtn ) {
        _receiptsBtn = AWCreateTextButton(CGRectZero,
                                          nil,
                                          [UIColor blackColor],
                                          self,
                                          @selector(showReceipts));
        [self.alertView addSubview:_receiptsBtn];
        
        _receiptsBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
        _receiptsBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _receiptsBtn;
}

- (UIButton *)ccBtn
{
    if ( !_ccBtn ) {
        _ccBtn = AWCreateTextButton(CGRectZero,
                                          nil,
                                          [UIColor blackColor],
                                          self,
                                          @selector(showCC));
        [self.alertView addSubview:_ccBtn];
        
        _ccBtn.titleLabel.font = self.receiptsBtn.titleLabel.font;
        _ccBtn.titleLabel.lineBreakMode = self.receiptsBtn.titleLabel.lineBreakMode;
    }
    return _ccBtn;
}

- (void)showReceipts
{
    NSString *title = [NSString stringWithFormat:@"下一节点接收人：%@", self.receipts];
    CGSize size = [title sizeWithAttributes:@{ NSFontAttributeName:
                                                   self.receiptsBtn.titleLabel.font }];
    if ( size.width > self.receiptsBtn.width ) {
        // 显示所有的接收人
        [self showNamesView:self.receipts];
    }
}

- (void)showCC
{
    NSString *title = [NSString stringWithFormat:@"下一节点抄送人：%@", self.ccNames];
    CGSize size = [title sizeWithAttributes:@{ NSFontAttributeName:
                                                   self.ccBtn.titleLabel.font }];
    if ( size.width > self.ccBtn.width ) {
        // 显示所有的抄送人
        [self showNamesView:self.ccNames];
    }
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(18, YES),
                                    [UIColor blackColor]);
        [self.alertView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if ( !_messageLabel ) {
        _messageLabel = AWCreateLabel(CGRectZero,
                                      nil,
                                      NSTextAlignmentCenter,
                                      nil,
                                      [UIColor blackColor]);
        [self.alertView addSubview:_messageLabel];
    }
    return _messageLabel;
}

- (UIView *)alertView
{
    if ( !_alertView ) {
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
        [self addSubview:_alertView];
        _alertView.backgroundColor = [UIColor whiteColor];
    }
    return _alertView;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_maskView];
        _maskView.backgroundColor = [UIColor blackColor];
        
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
    }
    return _maskView;
}

- (void)showNamesView:(NSString *)names
{
    NamesView *view = [[NamesView alloc] init];
    view.text = names;
    [view showInView:self frame:self.alertView.frame];
}

@end


@interface NamesView ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation NamesView

- (void)showInView:(UIView *)aView frame:(CGRect)frame
{
    [aView addSubview:self];
    
    self.frame = AWFullScreenBounds();
    
    self.contentView.frame = frame;
    
    self.textView.frame = CGRectMake(15, 50, self.contentView.width - 30,
                                     self.contentView.height - 60);
    self.closeBtn.position = CGPointMake(self.contentView.width - self.closeBtn.width - 5, 5);
    
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    self.textView.text = text;
}

- (UITextView *)textView
{
    if ( !_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textView];
        _textView.editable = NO;
        
        _textView.font = AWSystemFontWithSize(14, NO);
    }
    return _textView;
}

- (UIView *)contentView
{
    if ( !_contentView ) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIButton *)closeBtn
{
    if ( !_closeBtn ) {
        FAKIonIcons *closeIcon = [FAKIonIcons iosCloseEmptyIconWithSize:30];
        [closeIcon addAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] }];
        UIImage  *closeImage = [closeIcon imageWithSize:CGSizeMake(37, 37)];
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //    closeBtn.backgroundColor = [UIColor redColor];
        [_closeBtn setImage:closeImage forState:UIControlStateNormal];
        [_closeBtn sizeToFit];
        [_closeBtn addTarget:self
                     action:@selector(close)
           forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_closeBtn];
//        _closeBtn.frame = CGRectMake(0, 0, 40, 40);
    }
    return _closeBtn;
}

- (void)close
{
    [UIView animateWithDuration:.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

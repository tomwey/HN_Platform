//
//  DatePicker.m
//  HN_ERP
//
//  Created by tomwey on 1/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DatePicker.h"
#import "Defines.h"

@interface DatePicker ()

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView       *maskView;
@property (nonatomic, strong) UIToolbar    *toolbar;
@property (nonatomic, strong) UIView       *containerView;

@end

@implementation DatePicker

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        
    }
    return self;
}

- (void)showPickerInView:(UIView *)superView
{
    if ( !superView ) {
        superView = AWAppWindow();
    }
    
    if ( !self.superview ) {
        [superView addSubview:self];
    }
    
    [superView bringSubviewToFront:self];
    
    self.maskView.alpha = 0.0;
    
    [self bringSubviewToFront:self.containerView];
    
    self.containerView.frame = CGRectMake(0, self.height,
                                          self.width,
                                          260);
    self.toolbar.frame = CGRectMake(0, 0, self.containerView.width, 44);
    self.datePicker.frame = CGRectMake(0, self.toolbar.bottom,
                                       self.containerView.width, 216);
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.containerView.top = self.height - self.containerView.height;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)dismiss
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.containerView.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)cancel
{
    [self dismiss];
}

- (void)done
{
    if ( self.didSelectDateBlock ) {
        self.didSelectDateBlock(self, self.datePicker.date);
    }
    
    [self dismiss];
}

- (void)setCurrentSelectedDate:(NSDate *)currentSelectedDate
{
    _currentSelectedDate = currentSelectedDate;
    
    if ( currentSelectedDate ) {
        [self.datePicker setDate:currentSelectedDate animated:YES];
    }
}

- (void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
    
    self.datePicker.minimumDate = minimumDate;
}

- (void)setMaximumDate:(NSDate *)maximumDate
{
    _maximumDate = maximumDate;
    
    self.datePicker.maximumDate = maximumDate;
}

- (void)setPickerMode:(DatePickerMode)pickerMode
{
    _pickerMode = pickerMode;
    
    if ( pickerMode == DatePickerModeDate ) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    } else if ( pickerMode == DatePickerModeTime ) {
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    } else if ( pickerMode == DatePickerModeDateTime ) {
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
}

- (void)setMinuteInterval:(NSInteger)minuteInterval
{
//    _minimumDate = minimumDate;
    minuteInterval = _minuteInterval;
    self.datePicker.minuteInterval = minuteInterval;
}

- (UIDatePicker *)datePicker
{
    if ( !_datePicker ) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth(), 216)];
        [self.containerView addSubview:_datePicker];
        _datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return _datePicker;
}

- (UIToolbar *)toolbar
{
    if ( !_toolbar ) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        [self.containerView addSubview:_toolbar];
        
        //        UIBarButtonItem *cancelItem =
        //        [[UIBarButtonItem alloc] initWithTitle:@"取消"
        //                                         style:UIBarButtonItemStylePlain
        //                                        target:self action:@selector(cancel)];
        UIBarButtonItem *cancelItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        UIBarButtonItem *spaceItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        
        
        _toolbar.items = @[cancelItem, spaceItem, doneItem];
    }
    return _toolbar;
}

- (UIView *)containerView
{
    if ( !_containerView ) {
        _containerView = [[UIView alloc] init];
        [self addSubview:_containerView];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        _maskView.frame = self.bounds;
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.6;
        [self addSubview:_maskView];
        
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)]];
    }
    return _maskView;
}

@end

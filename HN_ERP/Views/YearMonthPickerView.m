//
//  YearMonthPickerView.m
//  HN_ERP
//
//  Created by tomwey on 5/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "YearMonthPickerView.h"
#import "Defines.h"
#import "NTMonthYearPicker.h"

@interface YearMonthPickerView ()

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *pickerContainer;

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NTMonthYearPicker *datePicker;

@end

@implementation YearMonthPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(cancel)]];
    }
    return self;
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    if ( _currentDate == currentDate ) {
        return;
    }
    
    _currentDate = currentDate;
    
    self.datePicker.maximumDate = [NSDate date];
    self.datePicker.date = currentDate;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.0;
    }
    return _maskView;
}

- (UIView *)pickerContainer
{
    if ( !_pickerContainer ) {
        _pickerContainer = [[UIView alloc] init];
        [self addSubview:_pickerContainer];
        _pickerContainer.frame = CGRectMake(0, 0, 0, 260);
        _pickerContainer.backgroundColor = [UIColor whiteColor];
    }
    return _pickerContainer;
}

- (void)showInView:(UIView *)superView
{
    if ( !self.superview ) {
        [superView addSubview:self];
    }
    
    [superView bringSubviewToFront:self];
    
    self.frame = superView.bounds;
    
    self.maskView.frame = self.bounds;
    
    self.pickerContainer.frame = CGRectMake(0, 0, self.width, 260);
    
    self.toolbar.frame = CGRectMake(0, 0, self.pickerContainer.width,
                                    44);
    self.datePicker.frame = CGRectMake(0, self.toolbar.bottom,
                                       self.pickerContainer.width,
                                       self.pickerContainer.height - self.toolbar.height);
    
//    self.top = superView.height;
    
    [self bringSubviewToFront:self.pickerContainer];
    
    self.pickerContainer.top = self.height;
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.pickerContainer.top = self.height - self.pickerContainer.height;
    }];
}

- (void)cancel
{
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.pickerContainer.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)done
{
    self.currentDate = self.datePicker.date;
    if ( self.doneCallback ) {
        self.doneCallback(self);
    }
    [self cancel];
}

- (UIToolbar *)toolbar
{
    if ( !_toolbar ) {
        _toolbar = [[UIToolbar alloc] init];
        [self.pickerContainer addSubview:_toolbar];
        
        UIBarButtonItem *cancel =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
        
        UIBarButtonItem *space =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        
        UIBarButtonItem *done =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
        
        _toolbar.items = @[cancel, space, done];
    }
    return _toolbar;
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

- (NTMonthYearPicker *)datePicker
{
    if ( !_datePicker ) {
        _datePicker = [[NTMonthYearPicker alloc] init];
        _datePicker.maximumDate = [NSDate date];
        [self.pickerContainer addSubview:_datePicker];
    }
    
    return _datePicker;
}

@end

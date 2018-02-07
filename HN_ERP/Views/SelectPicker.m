//
//  SelectPicker.m
//  HN_ERP
//
//  Created by tomwey on 1/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SelectPicker.h"
#import "Defines.h"

@interface SelectPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView       *maskView;
@property (nonatomic, strong) UIToolbar    *toolbar;
@property (nonatomic, strong) UIView       *containerView;

@end
@implementation SelectPicker

- (instancetype)initWithOptions:(NSArray *)options
{
    if ( self = [super init] ) {
//        self.frame = AWFullScreenBounds();
        self.options = options;
    }
    return self;
}

- (void)setOptions:(NSArray *)options
{
    _options = options;
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate   = self;
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
    self.pickerView.frame = CGRectMake(0, self.toolbar.bottom,
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

- (void)setCurrentSelectedOption:(id)currentSelectedOption
{
    _currentSelectedOption = currentSelectedOption;
    
    if ( !currentSelectedOption ) {
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
    } else {
//        NSInteger index = [self.options indexOfObject:currentSelectedOption];
        
        [self.options enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj isEqualToDictionary:currentSelectedOption] ) {
                [self.pickerView selectRow:idx inComponent:0 animated:YES];
                
                *stop = YES;
            }
        }];
        
//        if ( index != NSNotFound ) {
//            [self.pickerView selectRow:index inComponent:0 animated:YES];
//        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.options.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.options[row][@"name"];
}

- (void)cancel
{
    [self dismiss];
}

- (void)done
{
    if ( self.didSelectOptionBlock ) {
        NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
        if ( selectedRow != -1 ) {
            if (![self.currentSelectedOption isEqualToDictionary:self.options[selectedRow]]) {
                self.currentSelectedOption = self.options[selectedRow];
                
                self.didSelectOptionBlock(self, self.options[selectedRow], selectedRow);
            }
        }
    }
    
    [self dismiss];
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

- (UIPickerView *)pickerView
{
    if ( !_pickerView ) {
        _pickerView = [[UIPickerView alloc] init];
        [self.containerView addSubview:_pickerView];
    }
    return _pickerView;
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

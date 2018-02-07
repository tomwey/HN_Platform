//
//  HNCityAreaSelect.m
//  HN_ERP
//
//  Created by tomwey on 21/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNCityAreaSelect.h"
#import "SelectButton.h"
#import "Defines.h"

@interface HNCityAreaSelect ()

@property (nonatomic, strong) SelectButton *cityButton;
@property (nonatomic, strong) SelectButton *platButton;

@property (nonatomic, strong) NSMutableArray *cityData;
@property (nonatomic, strong) NSMutableArray *platData;

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSInteger loadType;

@end

@implementation HNCityAreaSelect

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = 5;
    CGFloat width  = ( self.width - padding ) / 2.0;
    
    self.cityButton.frame =
    self.platButton.frame = CGRectMake(0, 0, width, self.height);
    
    self.platButton.left = self.cityButton.right + padding;
    
    
}

- (void)prepareData
{
    [self.cityData removeAllObjects];
    
    [self loadDataForType:1 cityID:nil];
}

- (void)loadDataForType:(NSInteger)type cityID:(NSString *)cityID
{
    if ( self.loading ) return;
    
    self.loading = YES;
    
    self.loadType = type;
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"城市地图字典APP",
              @"param1": [@(type) description],
              @"param2": [cityID ?: @"" description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.loading = NO;
    
    if ( error ) {
        
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            if ( self.loadType == 1 ) {
                [self.cityData removeAllObjects];
            } else if (self.loadType == 2) {
                [self.platData removeAllObjects];
            }
            
            for (id dict in result[@"data"]) {
                if ( self.loadType == 1 ) {
                    [self.cityData addObject:@{ @"id": [dict[@"id"] ?: @"" description],
                                                @"name": dict[@"name"] ?: @""
                                                }];
                } else if ( self.loadType == 2 ) {
                    [self.platData addObject:@{ @"id": [dict[@"id"] ?: @"" description],
                                                @"name": dict[@"name"] ?: @""
                                                }];
                }
            }
        }
    }
}

- (void)setCityID:(NSString *)cityID
{
    if ( _cityID != cityID ) {
        _cityID = cityID;
        
        [self loadDataForType:2 cityID:cityID];
    }
}

- (void)openPickerForData:(NSArray *)data sender:(SelectButton *)sender
{
    if ( data.count == 0 ) {
        return;
    }
    
    UIView *superView = self.containerView ?: self.superview;
    
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = superView.bounds;
    
    id currentOption = sender.userData;
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        NSString *name = dict[@"name"];
        id value = dict[@"id"];
        id pair = @{ @"name": name,
                     @"value": [value description]
                     };
        [temp addObject:pair];
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:superView];
    
    //    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *inSender, id selectedOption, NSInteger index) {
        
        if ( sender == self.cityButton ) {
            NSString *cityID = [selectedOption[@"value"] description];
            if ( self.cityID != cityID ) {
                
                self.platButton.title = @"";
                self.platButton.userData = nil;
                self.platID = nil;
                
                [self.platData removeAllObjects];
                
                self.cityID = cityID;
                
                [self didUpdateSelect];
            }
            
        } else if ( sender == self.platButton ) {
            NSString *platID = [selectedOption[@"value"] description];
            if ( self.platID != platID ) {
                self.platID = platID;
                
                [self didUpdateSelect];
            }
        }
        
        sender.userData = selectedOption;
        sender.title = selectedOption[@"name"];
        
    };
}

- (void)didUpdateSelect
{
    if ( self.selectBlock ) {
        self.selectBlock(self);
    }
}

- (SelectButton *)cityButton
{
    if ( !_cityButton ) {
        _cityButton = [[SelectButton alloc] init];
        [self addSubview:_cityButton];
        
        __weak typeof(self) me = self;
        
        _cityButton.clickBlock = ^(SelectButton *sender) {
            [me openPickerForData: me.cityData sender: sender];
        };
    }
    return _cityButton;
}

- (SelectButton *)platButton
{
    if ( !_platButton ) {
        _platButton = [[SelectButton alloc] init];
        [self addSubview:_platButton];
        
        __weak typeof(self) me = self;
        
        _platButton.clickBlock = ^(SelectButton *sender) {
            [me openPickerForData: me.platData sender:sender];
        };
    }
    return _platButton;
}

- (NSMutableArray *)cityData
{
    if ( !_cityData ) {
        _cityData = [[NSMutableArray alloc] init];
    }
    return _cityData;
}

- (NSMutableArray *)platData
{
    if ( !_platData ) {
        _platData = [[NSMutableArray alloc] init];
    }
    return _platData;
}

@end

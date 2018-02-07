//
//  ConFeeView.m
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ConFeeView.h"
#import "Defines.h"
#import "BIChartView.h"
#import "SelectButton.h"
#import "HNTimeSelect.h"

@interface ConFeeView ()

@property (nonatomic, strong) SelectButton *areaButton;
@property (nonatomic, strong) HNTimeSelect *timeSelect;

@property (nonatomic, strong) UIScrollView *chartScrollView;
@property (nonatomic, strong) BIChartView  *conChartView;
@property (nonatomic, strong) BIChartView  *feeChartView;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, weak) SelectPicker *picker;

@end

@implementation ConFeeView

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion
{
    NSLog(@"loading...");
    
    [self.picker dismiss];
    
    self.areaButton.title = [self.userDefaultArea[@"area_name"] description];
    
    self.areaButton.userData = @{
                                  @"name": self.userDefaultArea[@"area_name"],
                                  @"value": self.userDefaultArea[@"area_id"]
                                };
    
    if ( self.loading ) {
        return;
    }
    
    self.loading = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    NSString *areaId = [self.userDefaultArea[@"area_id"] description];
    NSString *quarterId = [@(self.timeSelect.quarter) description];
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"BI签约回款多条件查询APP",
                       @"param1": [@(self.timeSelect.year) description],//areaId ?: @"-1",
                       @"param2": quarterId,
                       @"param3": [@(self.timeSelect.month) description],
                       @"param4": [@(self.timeSelect.weekOfMonth) description],
                       @"param5": areaId ?: @"0",
                       } completion:^(id result, NSError *error) {
                           __strong ConFeeView *strongSelf = weakSelf;
                           if ( strongSelf ) {
                               [strongSelf handleResult2:result error2:error];
                           }
                       }];
}

- (void)handleResult2:(id)result error2:(NSError *)error
{
    self.loading = NO;
    
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    if ( error ) {
        [self showHUDWithText:@"获取数据失败" succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            id data = [result[@"data"] firstObject];
            
            NSDictionary *conData = @{
                                      @"plan": [data[@"conplan"] description],
                                      @"real": [data[@"conreal"] description],
                                      @"flag": self.userDefaultArea[@"can_view_real"] ?: @(0),
                                      @"type": @(1),
                                      };
            NSDictionary *feeData = @{
                                      @"plan": [data[@"feeplan"] description],
                                      @"real": [data[@"feereal"] description],
                                      @"flag": self.userDefaultArea[@"can_view_real"] ?: @(0),
                                      @"type": @(2),
                                      };
            
            self.conChartView.chartData = conData;
            self.feeChartView.chartData = feeData;
            
        }
    }
}

- (void)selectArea
{
    [self openPickerForData:self.areaData];
}

- (void)openPickerForData:(NSArray *)data
{
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = self.navController.view.bounds;
    
    id currentOption = self.areaButton.userData;
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        NSString *name = dict[@"name"] ?: dict[@"area_name"];
        id value = dict[@"id"] ?: dict[@"area_id"];
        id pair = @{ @"name": name,
                     @"value": value
                     };
        [temp addObject:pair];
        
//        if ( data == self.areaData ) {
//            if ( dict == self.areaButton.userData ) {
//                currentOption = pair;
//            }
//        }
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:self.navController.view];
    
    self.picker = picker;
    
    picker.didSelectOptionBlock = ^(SelectPicker *sender, id selectedOption, NSInteger index) {
        if ( data == self.areaData ) {
            self.userDefaultArea = data[index];
            
            self.areaButton.userData = selectedOption;
            
            self.areaButton.title = selectedOption[@"name"];
        }
        
        [self startLoadData];
    };
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.areaButton.frame    = CGRectMake(0, 0, 66, 34);
    self.areaButton.position = CGPointMake(self.width - 10 - self.areaButton.width, 10);
    
    self.timeSelect.frame = CGRectMake(0, 0, self.width - 20 - self.areaButton.width - 10, 34);
    self.timeSelect.position = CGPointMake(10, 10);
    
    self.chartScrollView.frame = CGRectMake(0, self.areaButton.bottom + 10,
                                            self.width,
                                            self.height - self.areaButton.bottom - 10);
    
    self.conChartView.width = self.width;
    
    self.conChartView.center = CGPointMake(self.width / 2,
                                           40 + self.conChartView.height / 2);
    self.feeChartView.center = self.conChartView.center;
    self.feeChartView.top = self.conChartView.bottom + 20;
    
    self.chartScrollView.contentSize = CGSizeMake(self.width,
                                                  self.feeChartView.bottom + 20);
    
}

- (SelectButton *)areaButton
{
    if (!_areaButton) {
        _areaButton = [[SelectButton alloc] init];
        [self addSubview:_areaButton];
        
        __weak typeof(self) me = self;
        _areaButton.clickBlock = ^(SelectButton *sender) {
            [me selectArea];
        };
    }
    return _areaButton;
}

- (HNTimeSelect *)timeSelect
{
    if ( !_timeSelect ) {
        _timeSelect = [[HNTimeSelect alloc] init];
        
        [self addSubview:_timeSelect];
        
        _timeSelect.needUpdateWeekOfMonth = YES;
        
        [_timeSelect prepareInitData];
        
        __weak typeof(self) me = self;
        _timeSelect.timeSelectDidChange = ^(HNTimeSelect *sender) {
            [me startLoadData];
        };
    }
    return _timeSelect;
}

- (void)startLoadData
{
    [self startLoadingData:nil];
}

- (UIScrollView *)chartScrollView
{
    if ( !_chartScrollView ) {
        _chartScrollView = [[UIScrollView alloc] init];
        [self addSubview:_chartScrollView];
    }
    return _chartScrollView;
}

- (BIChartView *)conChartView
{
    if ( !_conChartView ) {
        _conChartView = [[BIChartView alloc] initWithFrame:CGRectMake(0, 0, 0, 340)];
        [self.chartScrollView addSubview:_conChartView];
        
        __weak typeof(self) weakSelf = self;
        _conChartView.didClickChartBlock = ^(BIChartView *sender) {
            
            NSDictionary *params = @{ @"timeData": @{
                                              @"year": [@(weakSelf.timeSelect.year) description],
                                              @"quarter": [@(weakSelf.timeSelect.quarter) description],
                                              @"month": [@(weakSelf.timeSelect.month) description],
                                              @"week": [@(weakSelf.timeSelect.weekOfMonth) description],
                                              },
                                      @"area": @{
                                              @"id": [weakSelf.userDefaultArea[@"area_id"] description] ?: @"0",
                                              @"name": weakSelf.userDefaultArea[@"area_name"] ?: @"全集团"
                                              },
                                      @"industry": @{
                                              @"id": @"0",
                                              @"name": @"",
                                              },
                                      @"action": @"签约"};
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"BIBarDetailVC" params:params];
            [weakSelf.navController pushViewController:vc animated:YES];
        };
    }
    return _conChartView;
}

- (BIChartView *)feeChartView
{
    if ( !_feeChartView ) {
        _feeChartView = [[BIChartView alloc] initWithFrame:self.conChartView.bounds];
        [self.chartScrollView addSubview:_feeChartView];
        
        __weak typeof(self) weakSelf = self;
        _feeChartView.didClickChartBlock = ^(BIChartView *sender) {
            
            NSDictionary *params = @{ @"timeData": @{
                                              @"year": [@(weakSelf.timeSelect.year) description],
                                              @"quarter": [@(weakSelf.timeSelect.quarter) description],
                                              @"month": [@(weakSelf.timeSelect.month) description],
                                              @"week": [@(weakSelf.timeSelect.weekOfMonth) description],
                                              },
                                      @"area": @{
                                              @"id": [weakSelf.userDefaultArea[@"area_id"] description],
                                              @"name": weakSelf.userDefaultArea[@"area_name"]
                                              },
                                      @"industry": @{
                                              @"id": @"0",
                                              @"name": @"",
                                              },
                                      @"action": @"回款"};
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"BIBarDetailVC" params:params];
            [weakSelf.navController pushViewController:vc animated:YES];
        };
    }
    return _feeChartView;
}


@end

//
//  BIVC.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BIVC.h"
#import "Defines.h"
#import "BIChartView.h"
#import "SelectButton.h"
#import "HNTimeSelect.h"

@interface BIVC ()

@property (nonatomic, strong) SelectButton *areaButton;
@property (nonatomic, strong) HNTimeSelect *timeSelect;

@property (nonatomic, strong) NSArray *areaData;

@property (nonatomic, strong) UIScrollView *chartScrollView;
@property (nonatomic, strong) BIChartView  *conChartView;
@property (nonatomic, strong) BIChartView  *feeChartView;

@property (nonatomic, assign) BOOL loading;

@end

#define CARET_SYMBOL @""//◢ ▿

@implementation BIVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"经营分析";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.timeSelect = [[HNTimeSelect alloc] init];
    [self.contentView addSubview:self.timeSelect];
    
    self.timeSelect.needUpdateWeekOfMonth = YES;
    
    [self.timeSelect prepareInitData];
    
    __weak typeof(self) me = self;
    self.timeSelect.timeSelectDidChange = ^(HNTimeSelect *sender) {
        [me startLoadData];
    };
    
    self.areaButton.position = CGPointMake(self.contentView.width - 10 - self.areaButton.width, 10);
    
    self.timeSelect.frame = CGRectMake(0, 0, self.contentView.width - 20 - self.areaButton.width - 10, 34);
    self.timeSelect.position = CGPointMake(10, 10);
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:self.contentView];
    line.position = CGPointMake(0, self.timeSelect.bottom + 10);
    
    // 图表滚动视图
    self.chartScrollView.frame = CGRectMake(0, line.bottom,
                                            self.contentView.width,
                                            self.contentView.height - line.bottom);
    
    [self loadData];
}

- (NSInteger)currentQuaterIndexForData:(NSArray *)yearData
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *df = [calendar components:NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger month = df.month;
    
    for (int i=1; i<yearData.count; i++) { // 第一个数据是全年，不用查询
        id dict = yearData[i];
        NSArray *months = dict[@"months"];
        if ( [months containsObject:@(month)] ) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (NSDateComponents *)dateComponents
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:NSCalendarUnitMonth | NSCalendarUnitWeekOfMonth fromDate:[NSDate date]];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI区域权限查询APP",
              @"param1": manID,
//              @"param2": @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
        [self.contentView showHUDWithText:@"获取区域失败" succeed:NO];
    } else {
        [self prepareAreaData:result];
    }
    
}

- (void)prepareAreaData:(id)result
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
        self.areaData = result[@"data"];
    } else {
        self.areaData = nil;
        
        [self.contentView showHUDWithText:@"没有查看权限" succeed:NO];
        
        self.chartScrollView.hidden = YES;
        
        return;
    }
    
    id area = [self fetchUserDefaultArea:self.areaData];
    NSString *title = [NSString stringWithFormat:@"%@%@", area[@"area_name"], CARET_SYMBOL];
    if ( !area ) {
        title = @"选择区域";
    }
//    [self.areaButton setTitle:title forState:UIControlStateNormal];
    self.areaButton.title = title;
    
    self.areaButton.userData = area;
    
    [self startLoadData];
}

- (void)startLoadData
{
    if (self.loading) return;
    
    self.loading = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSString *areaId = [self.areaButton.userData[@"area_id"] description];
    NSString *quarterId = [@(self.timeSelect.quarter) description];
    __weak typeof(self) me = self;
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
                           [me handleResult2:result error2:error];
                       }];
}

- (void)handleResult2:(id)result error2:(NSError *)error
{
    self.loading = NO;
    
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
        [self.contentView showHUDWithText:@"获取数据失败" succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            id data = [result[@"data"] firstObject];
            
            NSDictionary *conData = @{
                                      @"plan": [data[@"conplan"] description],
                                      @"real": [data[@"conreal"] description],
                                      @"flag": self.areaButton.userData[@"can_view_real"] ?: @(0),
                                      @"type": @(1),
                                      };
            NSDictionary *feeData = @{
                                      @"plan": [data[@"feeplan"] description],
                                      @"real": [data[@"feereal"] description],
                                      @"flag": self.areaButton.userData[@"can_view_real"] ?: @(0),
                                      @"type": @(2),
                                      };
            
            self.conChartView.chartData = conData;
            self.feeChartView.chartData = feeData;
            
            self.conChartView.center = CGPointMake(self.contentView.width / 2,
                                                   40 + self.conChartView.height / 2);
            self.feeChartView.center = self.conChartView.center;
            self.feeChartView.top = self.conChartView.bottom + 20;
            
            self.chartScrollView.contentSize = CGSizeMake(self.contentView.width,
                                                          self.feeChartView.bottom + 20);
        }
    }
}

- (id)fetchUserDefaultArea:(NSArray *)areaData
{
    if ( areaData.count == 0 ) {
        return nil;
    }
    
    id user = [[UserService sharedInstance] currentUser];
    
    // 如果有默认区域，返回默认区域
    for (id area in areaData) {
        if ( [area[@"area_id"] integerValue] == [user[@"area_id"] integerValue] ) {
            return area;
        }
    }
    
    // 否则返回第一个区域，注：第一个数据默认后台返回的是全集团
    return [areaData firstObject];
}

- (void)selectArea
{
    [self openPickerForData:self.areaData];
}

- (void)openPickerForData:(NSArray *)data
{
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = self.contentView.bounds;
    
    id currentOption;
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        NSString *name = dict[@"name"] ?: dict[@"area_name"];
        id value = dict[@"id"] ?: dict[@"area_id"];
        id pair = @{ @"name": name,
                     @"value": value
                     };
        [temp addObject:pair];
        
        if ( data == self.areaData ) {
            if ( dict == self.areaButton.userData ) {
                currentOption = pair;
            }
        }
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:self.contentView];
    
//    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *sender, id selectedOption, NSInteger index) {
        if ( data == self.areaData ) {
            self.areaButton.userData = data[index];
//            [self.areaButton setTitle:[NSString stringWithFormat:@"%@%@", self.areaButton.userData[@"area_name"], CARET_SYMBOL] forState:UIControlStateNormal];
            self.areaButton.title = [NSString stringWithFormat:@"%@%@", self.areaButton.userData[@"area_name"], CARET_SYMBOL];
        }
        
        [self startLoadData];
    };
}

- (SelectButton *)areaButton
{
    if (!_areaButton) {
        _areaButton = [[SelectButton alloc] init];
        [self.contentView addSubview:_areaButton];
        
        __weak typeof(self) me = self;
        _areaButton.clickBlock = ^(SelectButton *sender) {
            [me selectArea];
        };
    }
    return _areaButton;
//    if ( !_areaButton ) {
//        _areaButton = AWCreateTextButton(CGRectZero,
//                                            nil,
//                                            AWColorFromRGB(58, 58, 58),
//                                            self,
//                                            @selector(selectArea));
//        [self.contentView addSubview:_areaButton];
//        
//        _areaButton.backgroundColor = _quarterButton.backgroundColor;
//        
//        UIImage *image = [UIImage imageNamed:@"icon_caret.png"];
//        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        [_areaButton setImage:image forState:UIControlStateNormal];
//        _areaButton.tintColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR;
//        _areaButton.imageEdgeInsets = UIEdgeInsetsMake(8, self.contentView.width / 2 - 30, 0, 0);
//    }
//    return _areaButton;
}

- (UIScrollView *)chartScrollView
{
    if ( !_chartScrollView ) {
        _chartScrollView = [[UIScrollView alloc] init];
        [self.contentView addSubview:_chartScrollView];
    }
    return _chartScrollView;
}

- (BIChartView *)conChartView
{
    if ( !_conChartView ) {
        _conChartView = [[BIChartView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 340)];
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
                                              @"id": [weakSelf.areaButton.userData[@"area_id"] description] ?: @"0",
                                                @"name": weakSelf.areaButton.userData[@"area_name"] ?: @"全集团"
                                              },
                                      @"industry": @{
                                              @"id": @"0",
                                              @"name": @"",
                                              },
                                      @"action": @"签约"};
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"BIBarDetailVC" params:params];
            [weakSelf.navigationController pushViewController:vc animated:YES];
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
//                                              @"year": @"2017",
//                                              @"value": @"",
//                                              @"name": @"",
                                              },
                                      @"area": @{
                                              @"id": [weakSelf.areaButton.userData[@"area_id"] description],
                                              @"name": weakSelf.areaButton.userData[@"area_name"]
                                              },
                                      @"industry": @{
                                              @"id": @"0",
                                              @"name": @"",
                                              },
                                      @"action": @"回款"};
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"BIBarDetailVC" params:params];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
    }
    return _feeChartView;
}

@end

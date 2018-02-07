//
//  DealOverflowView.m
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DealOverflowView.h"
#import "Defines.h"
#import "SelectButton.h"
#import "YearMonthPickerView.h"
#import "HN_ERP-Bridging-Header.h"

@interface DealOverflowView () <IChartAxisValueFormatter, IChartValueFormatter, ChartViewDelegate>

@property (nonatomic, strong) SelectButton *areaButton;

@property (nonatomic, strong) SelectButton *beginDateButton;

@property (nonatomic, strong) SelectButton *endDateButton;

@property (nonatomic, weak) SelectPicker *picker;

@property (nonatomic, strong) YearMonthPickerView *monthYearPicker;

@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) UILabel *spliterLabel;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) CombinedChartView *chartView;

@property (nonatomic, strong) NSArray *chartData;

@end

@implementation DealOverflowView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        CombinedChartView *chartView =
        [[CombinedChartView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth() - 20,
                                                            AWFullScreenWidth() - 20)];
        [self addSubview:chartView];
        
        self.chartView = chartView;
        
        chartView.chartDescription.enabled = NO;
        
        chartView.drawGridBackgroundEnabled = NO;
        chartView.drawBarShadowEnabled = NO;
        chartView.highlightFullBarEnabled = NO;
        chartView.highlightPerTapEnabled = YES;
        
        chartView.highlightPerDragEnabled = NO;
        
        chartView.delegate = self;
        chartView.doubleTapToZoomEnabled = NO;
        //    chartView.drawMarkers = YES;
        //    chartView.pinchZoomEnabled = NO;
        
        chartView.drawOrder = @[
                                @(CombinedChartDrawOrderBar),
                                @(CombinedChartDrawOrderLine),
                                ];
        
        ChartLegend *l = chartView.legend;
        l.wordWrapEnabled = YES;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.orientation = ChartLegendOrientationHorizontal;
        l.drawInside = NO;
        
        //    leftAxis.granularity = 0.5;
        
        ChartXAxis *xAxis = chartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.drawGridLinesEnabled = NO;
        xAxis.centerAxisLabelsEnabled = YES;
        xAxis.avoidFirstLastClippingEnabled = YES;
        
        xAxis.axisMinimum = 0.0;
        xAxis.granularity = 1.0;
        xAxis.valueFormatter = self;
        
        xAxis.labelRotationAngle = 45;
        
        self.chartView.hidden = YES;
    }
    return self;
}

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion
{
    [self.picker dismiss];
    
    self.areaButton.title = [self.userDefaultArea[@"area_name"] description];
    
    self.areaButton.userData = @{
                                 @"name": self.userDefaultArea[@"area_name"],
                                 @"value": self.userDefaultArea[@"area_id"]
                                 };
    
    self.endDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    self.beginDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                          value:-11
                                         toDate:[NSDate date]
                                        options:0];
    NSLog(@"deal overflow loading....");
    
    [self startLoadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.areaButton.frame    = CGRectMake(0, 0, 66, 34);
    self.areaButton.position = CGPointMake(10, 10);
    
    self.beginDateButton.frame = CGRectMake(0, 0, 90, 34);
    self.endDateButton.frame   = self.beginDateButton.frame;
    
    self.endDateButton.position = CGPointMake(self.width - 10 - self.endDateButton.width,
                                              self.areaButton.top);
    
    self.spliterLabel.position = CGPointMake(self.endDateButton.left - self.spliterLabel.width,
                                             self.areaButton.midY - self.spliterLabel.height / 2);
    
    self.beginDateButton.top = self.endDateButton.top;
    self.beginDateButton.left = self.spliterLabel.left - self.beginDateButton.width;
    
    
//    self.chartView.frame = CGRectMake(10, self.areaButton.bottom + 10,
//                                      self.width - 20,
//                                      self.width - 20);
    self.chartView.position = CGPointMake(10, self.areaButton.bottom + 15);
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

- (void)startLoadData
{
    if (self.loading) return;
    
    self.loading = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dc1 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                       fromDate:self.beginDate];
    NSDateComponents *dc2 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                        fromDate:self.endDate];
    
    NSString *beginYear  = [@(dc1.year) description];
    NSString *beginMonth = [@(dc1.month) description];
    NSString *endYear    = [@(dc2.year) description];
    NSString *endMonth   = [@(dc2.month) description];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI成交溢价查询APP",
              @"param1": [self.userDefaultArea[@"area_id"] description],
              @"param2": beginYear,
              @"param3": beginMonth,
              @"param4": endYear,
              @"param5": endMonth,
              @"param6": @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.loading = NO;
    
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    
    if ( error ) {
        [self showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0) {
            [self showHUDWithText:@"没有查询到数据" offset:CGPointMake(0,20)];
        } else {
            [self showCharts:result[@"data"]];
        }
    }
}

- (void)showCharts:(NSArray *)data
{
    self.chartData = data;
    
    self.chartView.hidden = NO;
    
    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
//    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
//    rightAxis.axisMaximum = [maxDoneRate integerValue] + 20;
    rightAxis.drawLabelsEnabled = NO;
    //    rightAxis.granularity = 10;
    
//    float dtVal = [[self.areaID description] isEqualToString:@"0"] ? 1.0 : 10000;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
//    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
//    leftAxis.axisMaximum = [maxVal floatValue] + dtVal;
    
    //    leftAxis.axisLineWidth = 0.5;
    //    leftAxis.axisLineColor = AWColorFromRGB(235, 235, 235);
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
    leftAxis.gridColor = AWColorFromRGB(201, 201, 201);//网格线颜色
    leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
    
    CombinedChartData *combData = [[CombinedChartData alloc] init];
    
    combData.lineData = [self generateLineData:data];
    combData.barData  = [self generateBarData:data];
    
    self.chartView.data = combData;
    
    self.chartView.xAxis.axisMaximum = combData.xMax + 0.5;
    
    [self.chartView animateWithYAxisDuration:.5];
}

- (LineChartData *)generateLineData:(NSArray *)data
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < data.count; index++)
    {
        id item = data[index];
        ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:index + 0.5
                                                                y:[item[@"premiummoney"] floatValue]];
        [entries addObject:entry];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entries label:@"溢价额"];
    [set setColor:AWColorFromRGB(139, 177, 72)];
    set.lineWidth = 2.5;
    [set setCircleColor:AWColorFromRGB(188, 188, 188)];
    set.circleRadius = 5.0;
    set.circleHoleRadius = 2.5;
    set.fillColor = AWColorFromRGB(188, 188, 188);//[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    set.mode = LineChartModeLinear;
    set.drawValuesEnabled = YES;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    set.valueTextColor = [UIColor blackColor];
    
    set.axisDependency = AxisDependencyRight;
    
    [d addDataSet:set];
    
    set.highlightEnabled = NO;
    
    set.valueFormatter = self;
    
    return d;
}

- (BarChartData *)generateBarData:(NSArray *)data
{
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    NSMutableArray<BarChartDataEntry *> *entries2 = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < data.count; index++)
    {
        id item = data[index];
        
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:[item[@"investmoney"] doubleValue]
                                                            data:item]];
        [entries2 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:
                             [item[@"conmoney"] doubleValue]
                                                            data:item]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithValues:entries1 label:@"投资额"];
    [set1 setColor:AWColorFromRGB(250, 215, 183)];
    set1.valueTextColor = AWColorFromRGB(250, 215, 183);//MAIN_THEME_COLOR;//AWColorFromRGB(58, 58, 58);
    //[UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.axisDependency = AxisDependencyLeft;
    
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithValues:entries2 label:@"销售额"];
    [set2 setColor:MAIN_THEME_COLOR];
    set2.valueTextColor = MAIN_THEME_COLOR;//set1.valueTextColor;
    //[UIColor colorWithRed:61/255.f green:165/255.f blue:255/255.f alpha:1.f];
    set2.valueFont = [UIFont systemFontOfSize:10.f];
    set2.axisDependency = AxisDependencyLeft;
    
    set1.valueFormatter = self;
    set2.valueFormatter = self;
    
    float groupSpace = 0.5;//0.06f;
    float barSpace = 0.01f; // x2 dataset
    float barWidth = 0.24f; // x2 dataset
    //    // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
    //
    BarChartData *d = [[BarChartData alloc] initWithDataSets:@[set1, set2]];
    d.barWidth = barWidth;
    
    // make this BarData object grouped
    [d groupBarsFromX:0.0 groupSpace:groupSpace barSpace:barSpace];
    
    return d;
}

- (void)chartValueSelected:(ChartViewBase *)chartView
                     entry:(ChartDataEntry *)entry
                 highlight:(ChartHighlight *)highlight
{
//    NSLog(@"data: %@", [entry.data name]);
    
    [self.chartView highlightValues:nil];
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    NSInteger index = (int)value % self.chartData.count;
    id item = self.chartData[index];
    return item[@"project_name"];
}

- (NSString * _Nonnull)stringForValue:(double)value entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler * _Nullable)viewPortHandler
{
    //    NSInteger index = (int)value % self.chartData.count;
    //    ChartItem *item = self.chartData[index];
    
//    if ( [entry isKindOfClass:[BarChartDataEntry class]] ) {
        return [NSString stringWithFormat:@"%.2f", entry.y];
//    }
    
//    return [NSString stringWithFormat:@"%d%%", (int)entry.y];
}

- (void)openDatePickerForType:(NSInteger)type
{
    YearMonthPickerView *pickerView = [[YearMonthPickerView alloc] init];
    pickerView.currentDate = type == 0 ? self.beginDate : self.endDate;
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    dc.year = 2003;
    dc.month = 1;
    dc.day = 1;
    
    pickerView.minimumDate = [currentCalendar dateFromComponents:dc];
    
    pickerView.doneCallback = ^(YearMonthPickerView *sender) {
        if ( type == 0 ) {
            self.beginDate = sender.currentDate;
//            [self updateButtonTitle:self.beginDateButton];
        } else {
            self.endDate   = sender.currentDate;
//            [self updateButtonTitle:self.endDateButton];
        }
//        self.currentDate = sender.currentDate;
//        self.dateSelectControl.currentDate = sender.currentDate;
        
        [self startLoadData];
    };
    [pickerView showInView:self.superview.superview.superview];
}

- (NSString *)titleFromDate:(NSDate *)date
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    
    return [NSString stringWithFormat:@"%d年%d月", dc.year, dc.month];
}

- (void)setBeginDate:(NSDate *)beginDate
{
    if (_beginDate != beginDate) {
        _beginDate = beginDate;
        
        self.beginDateButton.title = [self titleFromDate:beginDate];
    }
}

- (void)setEndDate:(NSDate *)endDate
{
    if ( _endDate != endDate ) {
        _endDate = endDate;
        
        self.endDateButton.title = [self titleFromDate:endDate];
    }
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

- (SelectButton *)beginDateButton
{
    if ( !_beginDateButton ) {
        _beginDateButton = [[SelectButton alloc] init];
        [self addSubview:_beginDateButton];
        
        __weak typeof(self) me = self;
        _beginDateButton.clickBlock = ^(SelectButton *sender) {
//            [me select];
            [me openDatePickerForType:0];
        };
    }
    return _beginDateButton;
}

- (SelectButton *)endDateButton
{
    if ( !_endDateButton ) {
        _endDateButton = [[SelectButton alloc] init];
        [self addSubview:_endDateButton];
        
        __weak typeof(self) me = self;
        _endDateButton.clickBlock = ^(SelectButton *sender) {
            //            [me select];
            [me openDatePickerForType:1];
        };
    }
    return _endDateButton;
}

- (UILabel *)spliterLabel
{
    if ( !_spliterLabel ) {
        _spliterLabel = AWCreateLabel(CGRectMake(0, 0, 34, 34),
                                      @"至",
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(14, NO),
                                      AWColorFromRGB(58, 58, 58));
        [self addSubview:_spliterLabel];
    }
    return _spliterLabel;
}

//- (CombinedChartView *)chartView
//{
//    if ( !_chartView ) {
//        _chartView = [[CombinedChartView alloc] init];
//        [self addSubview:_chartView];
//        
//        
//    }
//    return _chartView;
//}

@end

//
//  HotSaleRankView.m
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HotSaleRankView.h"
#import "Defines.h"
#import "SelectButton.h"
#import "YearMonthPickerView.h"
#import "HN_ERP-Bridging-Header.h"

@interface HotSaleRankView () <IChartAxisValueFormatter>

@property (nonatomic, strong) SelectButton *areaButton;

@property (nonatomic, strong) SelectButton *beginDateButton;

@property (nonatomic, strong) SelectButton *endDateButton;

@property (nonatomic, weak) SelectPicker *picker;

@property (nonatomic, strong) YearMonthPickerView *monthYearPicker;

@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) UILabel *spliterLabel;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) BarChartView *chartView;

@property (nonatomic, strong) UISegmentedControl *priceControl;
@property (nonatomic, strong) UISegmentedControl *parkingControl;

@property (nonatomic, strong) NSArray *chartData;

@end
@implementation HotSaleRankView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        BarChartView *chartView =
        [[BarChartView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth() - 20,
                                                            AWFullScreenWidth() - 20)];
        [self addSubview:chartView];
        
        self.chartView = chartView;
        
        chartView.drawBarShadowEnabled = NO;
        chartView.drawValueAboveBarEnabled = YES;
        
        chartView.maxVisibleCount = 60;
        
        ChartXAxis *xAxis = chartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:10.f];
        xAxis.drawGridLinesEnabled = NO;
        xAxis.granularity = 1.0; // only intervals of 1 day
        xAxis.labelCount = 7;
        xAxis.valueFormatter = self;
        
        NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
        leftAxisFormatter.minimumFractionDigits = 0;
        leftAxisFormatter.maximumFractionDigits = 1;
        leftAxisFormatter.negativeSuffix = @" 万";
        leftAxisFormatter.positiveSuffix = @" 万";
        
        ChartYAxis *leftAxis = chartView.leftAxis;
        leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
        leftAxis.labelCount = 8;
        leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
        leftAxis.spaceTop = 0.15;
        leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
        ChartYAxis *rightAxis = chartView.rightAxis;
        rightAxis.enabled = YES;
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
        rightAxis.labelCount = 8;
        rightAxis.valueFormatter = leftAxis.valueFormatter;
        rightAxis.spaceTop = 0.15;
        rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
        ChartLegend *l = chartView.legend;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.orientation = ChartLegendOrientationHorizontal;
        l.drawInside = NO;
        l.form = ChartLegendFormSquare;
        l.formSize = 9.0;
        l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
        l.xEntrySpace = 4.0;
        
        xAxis.labelRotationAngle = 45;
        
        chartView.chartDescription.enabled = NO;
        
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
    
    self.chartView.position = CGPointMake(10, self.areaButton.bottom + 15);
    
    self.priceControl.position = CGPointMake(self.areaButton.left,
                                             self.chartView.bottom);
    self.parkingControl.left = self.width - 10 - self.parkingControl.width;
    self.parkingControl.top  = self.priceControl.top;
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
              @"funname": @"BI热销排名查询APP",
              @"param1": [self.userDefaultArea[@"area_id"] description],
              @"param2": beginYear,
              @"param3": beginMonth,
              @"param4": endYear,
              @"param5": endMonth,
              @"param6": [@(self.priceControl.selectedSegmentIndex) description],
              @"param7": [@(self.parkingControl.selectedSegmentIndex) description]
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
    self.priceControl.hidden = NO;
    self.parkingControl.hidden = NO;
    self.chartView.hidden = NO;
    
    self.chartData = data;
    
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
    
    NSMutableArray *entries = [@[] mutableCopy];
    
    for (int i=0; i<data.count; i++) {
        id item = data[i];
        
        CGFloat val = [item[@"total"] floatValue] / 10000.00;
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:i y:val];
        [entries addObject:entry];
    }
    
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithValues:entries label:@"热销排名"];
//    set.colors = 
    [set setColors:ChartColorTemplates.material];
    set.drawIconsEnabled = NO;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set];
    
    BarChartData *chartData = [[BarChartData alloc] initWithDataSets:dataSets];
    [chartData setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    chartData.barWidth = 0.9f;
    
    self.chartView.data = chartData;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    NSInteger index = (int)value % self.chartData.count;
    id item = self.chartData[index];
    return item[@"project_name"];
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

- (UISegmentedControl *)priceControl
{
    if ( !_priceControl ) {
        _priceControl = [[UISegmentedControl alloc] initWithItems:@[@"按成交总价",@"按成交均价"]];
        
        [self addSubview:_priceControl];
        _priceControl.frame = CGRectMake(0, 0, 160, 34);
        _priceControl.selectedSegmentIndex = 0;
        _priceControl.tintColor = MAIN_THEME_COLOR;
        
        _priceControl.hidden = YES;
        
        [_priceControl addTarget:self
                        action:@selector(segChanged:)
              forControlEvents:UIControlEventValueChanged];
    }
    return _priceControl;
}

- (UISegmentedControl *)parkingControl
{
    if ( !_parkingControl ) {
        _parkingControl = [[UISegmentedControl alloc] initWithItems:@[@"非车位",@"车位"]];
        
        [self addSubview:_parkingControl];
        _parkingControl.frame = CGRectMake(0, 0, 120, 34);
        _parkingControl.selectedSegmentIndex = 0;
        _parkingControl.tintColor = MAIN_THEME_COLOR;
        
        _parkingControl.hidden = YES;
        
        [_parkingControl addTarget:self
                          action:@selector(segChanged:)
                forControlEvents:UIControlEventValueChanged];
    }
    return _parkingControl;
}

- (void)segChanged:(UISegmentedControl *)sender
{
    [self startLoadData];
}

@end

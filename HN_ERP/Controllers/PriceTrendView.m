//
//  PriceTrendView.m
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PriceTrendView.h"
#import "Defines.h"
#import "YearMonthPickerView.h"
#import "HN_ERP-Bridging-Header.h"
#import "SelectButton.h"

@interface PriceTrendView () <ChartViewDelegate>

@property (nonatomic, strong) UISegmentedControl *parkingControl;
@property (nonatomic, strong) UISegmentedControl *segControl;

@property (nonatomic, strong) SelectButton *beginDateButton;
@property (nonatomic, strong) SelectButton *endDateButton;

@property (nonatomic, strong) YearMonthPickerView *monthYearPicker;

@property (nonatomic, strong) LineChartView *chartView;

@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) UILabel *spliterLabel;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) NSArray *chartData;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation PriceTrendView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.chartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth() - 20,
                                                                         AWFullScreenWidth() - 20)];
        
        
//        self.chartView.drawBarShadowEnabled = NO;
//        self.chartView.drawValueAboveBarEnabled = YES;
        [self addSubview:self.chartView];
        
//        self.chartView.maxVisibleCount = 60;
        
        ChartXAxis *xAxis = self.chartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:10.f];
        xAxis.drawGridLinesEnabled = NO;
        xAxis.granularity = 1.0; // only intervals of 1 day
        xAxis.labelCount = 7;
//        xAxis.valueFormatter = self;
        
        NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
        leftAxisFormatter.minimumFractionDigits = 0;
        leftAxisFormatter.maximumFractionDigits = 1;
        leftAxisFormatter.negativeSuffix = @" 元";
        leftAxisFormatter.positiveSuffix = @" 元";
        
        ChartYAxis *leftAxis = self.chartView.leftAxis;
        leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
        leftAxis.labelCount = 8;
        leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
        leftAxis.spaceTop = 0.15;
        leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
        ChartYAxis *rightAxis = self.chartView.rightAxis;
        rightAxis.enabled = YES;
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
        rightAxis.labelCount = 8;
        rightAxis.valueFormatter = leftAxis.valueFormatter;
        rightAxis.spaceTop = 0.15;
        rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        
        ChartLegend *l = self.chartView.legend;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.orientation = ChartLegendOrientationHorizontal;
        l.drawInside = NO;
        l.form = ChartLegendFormSquare;
        l.formSize = 9.0;
        l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
        l.xEntrySpace = 4.0;
        
        xAxis.labelRotationAngle = 45;
        
        self.chartView.chartDescription.enabled = NO;
        self.chartView.delegate = self;
        
        self.chartView.hidden = YES;
    }
    return self;
}

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion
{
    NSLog(@"price trend loading....");
    
    if ( [self.areaID isEqualToString:@"0"] ) {
        [self.segControl setTitle:@"按区域" forSegmentAtIndex:0];
    } else {
        [self.segControl setTitle:@"按项目" forSegmentAtIndex:0];
    }
    
    if ( ![self.industryID isEqualToString:@"0"] ) {
        self.segControl.enabled = NO;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@价格趋势",
                            self.areaName, self.industryName];
    
    self.endDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    self.beginDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                          value:-11
                                         toDate:[NSDate date]
                                        options:0];
    
    [self startLoadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.spliterLabel.center = CGPointMake(self.width / 2,
                                           self.spliterLabel.height / 2 + 10);
    
    self.beginDateButton.frame = CGRectMake(0, 0, 90, 34);
    self.endDateButton.frame   = self.beginDateButton.frame;
    
    self.beginDateButton.center = CGPointMake(self.spliterLabel.left - self.beginDateButton.width / 2,
                                              self.spliterLabel.midY);
    
    self.endDateButton.center = CGPointMake(self.spliterLabel.right + self.endDateButton.width / 2,
                                            self.spliterLabel.midY);

    self.titleLabel.frame = CGRectMake(10, self.endDateButton.bottom + 5, self.width - 20, 34);
    
    
    self.chartView.position = CGPointMake(10, self.titleLabel.bottom + 5);
    
    self.segControl.position = CGPointMake(10, self.chartView.bottom + 5);
    self.parkingControl.position = CGPointMake(self.width - 10 - self.parkingControl.width,
                                               self.chartView.bottom + 5);
}

- (NSString *)areaID
{
    if ( !_areaID ) {
        _areaID = [self.userDefaultArea[@"area_id"] description];
    }
    return _areaID;
}

- (NSString *)areaName
{
    if ( !_areaName ) {
        _areaName = [self.userDefaultArea[@"area_name"] description];
    }
    return _areaName;
}

- (NSString *)industryName
{
    if ( !_industryName ) {
        _industryName = @"";
    }
    return _industryName;
}

- (NSString *)industryID
{
    if ( !_industryID ) {
        _industryID = @"0";
    }
    return _industryID;
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
              @"funname": @"BI价格趋势查询APP",
              @"param1": [@(self.segControl.selectedSegmentIndex) description],
              @"param2": [@(self.parkingControl.selectedSegmentIndex) description],
              @"param3": self.areaID,
              @"param4": self.industryID,
              @"param5": beginYear,
              @"param6": beginMonth,
              @"param7": endYear,
              @"param8": endMonth,
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
    self.segControl.hidden = NO;
    self.parkingControl.hidden = NO;
    self.chartView.hidden = NO;
    
//    self.chartData = data;
    
//    id = 1679352;
//    month = 10;
//    name = "\U6210\U90fd";
//    price = "7752.3119";
//    type = 0;
//    year = 2016;
    
    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    //    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    //    rightAxis.axisMaximum = [maxDoneRate integerValue] + 20;
    rightAxis.drawLabelsEnabled = NO;
    //    rightAxis.granularity = 10;
    
    //    float dtVal = [[self.areaID description] isEqualToString:@"0"] ? 1.0 : 10000;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
    leftAxis.gridColor = AWColorFromRGB(201, 201, 201);//网格线颜色
    leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
    
    NSMutableDictionary *outerDict = [@{} mutableCopy];
    for (id dict in data) {
        NSString *name = [dict[@"name"] description];
        NSMutableArray *obj = outerDict[name];
        if ( !obj ) {
            obj = [[NSMutableArray alloc] init];
            outerDict[name] = obj;
            [obj addObject:dict];
        } else {
            [obj addObject:dict];
        }
    }
    
    NSMutableDictionary *finalDict = [@{} mutableCopy];
    for (id key in outerDict) {
        NSArray *obj = outerDict[key];
        NSLog(@"key:%@", key);
        NSArray *newObj = [obj sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *val1 = [NSString stringWithFormat:@"%@-%@", obj1[@"year"], obj1[@"month"]];
            NSString *val2 = [NSString stringWithFormat:@"%@-%@", obj2[@"year"], obj2[@"month"]];
            return [val1 compare:val2 options:NSNumericSearch] == NSOrderedDescending;
        }];
        [finalDict setObject:newObj forKey:key];
    }
    
    NSMutableArray *labels = [@[] mutableCopy];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    
    NSInteger index1 = 188;
    NSInteger index2 = 88;
    NSInteger index3 = 8;
    for (id key in finalDict) {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        NSArray *obj = finalDict[key];
        
        for (int i = 0; i < obj.count; i++)
        {
//            double val = (double) (arc4random_uniform(range) + 3);
            [values addObject:[[ChartDataEntry alloc] initWithX:i
                                                              y:[obj[i][@"price"] floatValue]
                                                           data:obj[i]]];
        }
        
        LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:values label:key];
//        [set setColor:AWColorFromRGB(139, 177, 72)];
        set.lineWidth = 2.5;
        [set setCircleColor:AWColorFromRGB(188, 188, 188)];
        set.circleRadius = 5.0;
        set.circleHoleRadius = 2.5;
        set.fillColor = AWColorFromRGB(188, 188, 188);//[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
        set.mode = LineChartModeLinear;
        set.drawValuesEnabled = YES;
        set.valueFont = [UIFont systemFontOfSize:10.f];
        set.valueTextColor = [UIColor blackColor];
//        NSArray *colors = ChartColorTemplates.material;
        UIColor *color = AWColorFromRGB( index1 % 255, index2 % 255, index3 % 255);
        index1 *= 8;
        index2 += 20;
        index3 *= 18;
        set.colors = @[color];
        set.axisDependency = AxisDependencyLeft;
        
        [dataSets addObject:set];
        
    }
    
    self.chartData = [[finalDict allValues] firstObject];
    
    LineChartData *chartData = [[LineChartData alloc] initWithDataSets:dataSets];
//    [chartData setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:0.0]];
    
    for (id item in self.chartData) {
        [labels addObject:[NSString stringWithFormat:@"%@年%@月", item[@"year"], item[@"month"]]];
    }
    
    self.chartView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:labels];
  
    [chartData setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    self.chartView.data = chartData;
    [self.chartView animateWithXAxisDuration:.5 yAxisDuration:.5];
}

- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight
{
    [self.chartView highlightValues:nil];
    
    if ( ![self.areaID isEqualToString:@"0"] ) {
        // 具体某个区域下面对应的是项目，那么项目这一级暂时不处理了
        return;
    }
    
    id data = entry.data;
    NSString *areaID = self.areaID;
    NSString *industryID = self.industryID;
    NSString *areaName = self.areaName;
    NSString *industryName = self.industryName;
    
    if ( self.segControl.selectedSegmentIndex == 0 ) {
        // 区域或项目
        areaID = [data[@"id"] description];
        areaName = [data[@"name"] description];
    } else {
        // 业态
        industryID = [data[@"id"] description];
        industryName = [data[@"name"] description];
    }
    
    NSDictionary *params = @{
                             @"default_area": self.userDefaultArea ?: @{},
                             @"area_data": self.areaData ?: @[],
                             @"navController": self.navController,
                             @"area_id": areaID,
                             @"area_name": areaName,
                             @"industry_name": industryName,
                             @"industry_id": industryID,
                             };
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PriceTrendVC" params:params];
    
    [self.navController pushViewController:vc animated:YES];
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

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(16, YES),
                                    MAIN_THEME_COLOR);
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UISegmentedControl *)segControl
{
    if ( !_segControl ) {
        _segControl = [[UISegmentedControl alloc] initWithItems:@[@"按区域",@"按业态"]];
        
        [self addSubview:_segControl];
        _segControl.frame = CGRectMake(0, 0, 120, 34);
        _segControl.selectedSegmentIndex = 0;
        _segControl.tintColor = MAIN_THEME_COLOR;
        
        _segControl.hidden = YES;
        
        [_segControl addTarget:self
                          action:@selector(segChanged:)
                forControlEvents:UIControlEventValueChanged];
    }
    return _segControl;
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

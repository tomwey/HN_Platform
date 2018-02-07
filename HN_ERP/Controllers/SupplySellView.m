//
//  SupplySellView.m
//  HN_ERP
//
//  Created by tomwey on 21/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SupplySellView.h"
#import "Defines.h"
#import "HN_ERP-Bridging-Header.h"

@interface SupplySellView () <IChartValueFormatter>

@property (nonatomic, strong) UISegmentedControl *segControl1;
@property (nonatomic, strong) UISegmentedControl *segControl2;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) CombinedChartView *chartView;

@property (nonatomic, strong) NSArray *chartData;

@end

@implementation SupplySellView

- (void)startLoadingData:(void (^)(BOOL, NSError *))completion
{
    [self loadingData];
}

- (void)loadingData
{
    
    if ([self.userData[@"cityID"] description].length == 0 ||
        [[self.userData[@"cityID"] description] isEqualToString:@"0"]) {
        [self showHUDWithText:@"选择城市板块查看数据" offset:CGPointMake(0,20)];
        return;
    }
    
    if (self.loading) {
        return;
    }
    
    self.loading = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"城市地图BI供销价走势APP",
              @"param1": self.userData[@"cityID"] ?: @"0",
              @"param2": self.userData[@"platID"] ?: @"0",
              @"param3": self.userData[@"bYear"] ?: @"0",
              @"param4": self.userData[@"bMonth"] ?: @"0",
              @"param5": self.userData[@"eYear"] ?: @"0",
              @"param6": self.userData[@"eMonth"] ?: @"0",
              @"param7": [@(self.segControl1.selectedSegmentIndex) description],
              @"param8": [@(self.segControl2.selectedSegmentIndex) description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    self.loading = NO;
    
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
    
    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    //    rightAxis.axisMaximum = [maxDoneRate integerValue] + 20;
    rightAxis.drawLabelsEnabled = YES;
    
    
    id maxItem = data[0];
    CGFloat max = MAX(HNFloatFromObject(maxItem[@"dealarea"], 0.0), HNFloatFromObject(maxItem[@"supplyarea"], 0.0));
    CGFloat maxPrice = HNFloatFromObject(maxItem[@"dealprice"], 0.0);
    
    for (id dict in data) {
        CGFloat currentMax = MAX(HNFloatFromObject(dict[@"dealarea"], 0.0),HNFloatFromObject(dict[@"supplyarea"], 0.0));
        if ( currentMax > max ) {
            max = currentMax;
        }
        
        CGFloat currentPrice = HNFloatFromObject(dict[@"dealprice"], 0.0);
        if ( currentPrice > maxPrice ) {
            maxPrice = currentPrice;
        }
    }
    
    rightAxis.axisMaximum = maxPrice + 2000;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    leftAxis.axisMaximum = max + max / 10;
    
    //    leftAxis.axisLineWidth = 0.5;
    //    leftAxis.axisLineColor = AWColorFromRGB(235, 235, 235);
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
    leftAxis.gridColor = AWColorFromRGB(201, 201, 201);//网格线颜色
    leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
    
    ChartXAxis *xAxis = self.chartView.xAxis;
    
    CombinedChartData *combData = [[CombinedChartData alloc] init];
    combData.barData = [self generateBarData];
    combData.lineData = [self generateLineData];
    self.chartView.data = combData;
    
    xAxis.axisMaximum = combData.xMax + 0.5;
    
    self.chartView.hidden = NO;
    
    [self.chartView highlightValue:nil];
    
    [self.chartView animateWithYAxisDuration:.5];
}

- (LineChartData *)generateLineData
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    //    NSLog(@"%@", self.chartData);
    
    for (int index = 0; index < self.chartData.count; index++)
    {
        id item = self.chartData[index];
        ChartDataEntry *entry =
        [[ChartDataEntry alloc] initWithX:index + 0.5
                                        y:HNFloatFromObject(item[@"dealprice"], 0.0)];
        [entries addObject:entry];
    }
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entries label:@"成交均价(元/㎡)"];
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
    
//    set.valueFormatter = self;
    
    return d;
}

- (BarChartData *)generateBarData
{
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    NSMutableArray<BarChartDataEntry *> *entries2 = [[NSMutableArray alloc] init];
    
    NSMutableArray *labels = [@[] mutableCopy];
    
    for (int index = 0; index < self.chartData.count; index++)
    {
        id item = self.chartData[index];
        
        CGFloat supplyVal = HNFloatFromObject(item[@"supplyarea"], 0.0);
        CGFloat sellVal = HNFloatFromObject(item[@"dealarea"], 0.0);
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:supplyVal
                                                            data:item]];
        
        [entries2 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:sellVal
                                                            data:item]];
        
        if ( item[@"fmonth"] ) {
            [labels addObject:[NSString stringWithFormat:@"%@年%@月", item[@"fyear"], item[@"fmonth"] ]];
        } else if ( item[@"fquarter"] ) {
            [labels addObject:[NSString stringWithFormat:@"%@年%@季度", item[@"fyear"], item[@"fquarter"] ]];
        } else {
            [labels addObject:[NSString stringWithFormat:@"%@年", item[@"fyear"] ]];
        }
    }
    
    self.chartView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:labels];
    
    NSString *unit = self.segControl2.selectedSegmentIndex == 0 ? @"万㎡" : @"套";
    NSString *suffix = self.segControl2.selectedSegmentIndex == 0 ? @"面积" : @"套数";
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithValues:entries1 label:[NSString stringWithFormat:@"供应%@(%@)", suffix, unit]];
    [set1 setColor:AWColorFromRGB(250, 215, 183)];
    set1.valueTextColor = AWColorFromRGB(240, 205, 153);
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.axisDependency = AxisDependencyLeft;
    
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithValues:entries2 label:[NSString stringWithFormat:@"成交%@(%@)", suffix, unit]];
    [set2 setColor:MAIN_THEME_COLOR];
    set2.valueTextColor = MAIN_THEME_COLOR;
    set2.valueFont = [UIFont systemFontOfSize:10.f];
    set2.axisDependency = AxisDependencyLeft;
    
    set1.valueFormatter = self;
    set2.valueFormatter = self;
    
    float groupSpace = 0.3f;//0.06f;
    float barSpace = 0.02f; // x2 dataset
    float barWidth = 0.33f; // x2 dataset
    //    // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
    //
    BarChartData *d =
    [[BarChartData alloc] initWithDataSets:@[set1, set2]];
    d.barWidth = barWidth;
    
    // make this BarData object grouped
    [d groupBarsFromX:0.0 groupSpace:groupSpace barSpace:barSpace];
    
    return d;
}

- (NSString * _Nonnull)stringForValue:(double)value entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler * _Nullable)viewPortHandler
{
    //    NSInteger index = (int)value % self.chartData.count;
    //    ChartItem *item = self.chartData[index];
    
    if ( [entry isKindOfClass:[BarChartDataEntry class]] ) {
        return self.segControl2.selectedSegmentIndex == 0 ?
            [NSString stringWithFormat:@"%.1f", entry.y] :
            [NSString stringWithFormat:@"%d", (NSInteger)entry.y];
    }
    
    return [NSString stringWithFormat:@"%f", entry.y];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.segControl1.frame = CGRectMake(0, 0, 160, 34);
    self.segControl2.frame = CGRectMake(0, 0, 120, 34);
    
    self.segControl1.position = CGPointMake(15, self.height - 10 - self.segControl1.height);
    self.segControl2.position = self.segControl1.position;
    self.segControl2.left = self.width - 15 - self.segControl2.width;
    
    self.chartView.position = CGPointMake(10, self.segControl1.top - 10 - self.chartView.height);
}

- (CombinedChartView *)chartView
{
    if ( !_chartView ) {
        _chartView = [[CombinedChartView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth() - 20,
                                                                         AWFullScreenWidth() - 20)];
        [self addSubview:_chartView];
        
        _chartView.chartDescription.enabled = NO;
        
        _chartView.drawGridBackgroundEnabled = NO;
        _chartView.drawBarShadowEnabled = NO;
        _chartView.highlightFullBarEnabled = NO;
        _chartView.highlightPerTapEnabled = YES;
        
        _chartView.highlightPerDragEnabled = NO;
        
//        _chartView.delegate = self;
        _chartView.doubleTapToZoomEnabled = NO;
        
        _chartView.drawOrder = @[
                                 @(CombinedChartDrawOrderBar),
                                 @(CombinedChartDrawOrderLine),
                                 ];
        
        ChartLegend *l = _chartView.legend;
        l.wordWrapEnabled = YES;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.orientation = ChartLegendOrientationHorizontal;
        l.drawInside = NO;
        
        //    leftAxis.granularity = 0.5;
        
        ChartXAxis *xAxis = _chartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.drawGridLinesEnabled = NO;
        xAxis.centerAxisLabelsEnabled = YES;
        xAxis.avoidFirstLastClippingEnabled = YES;
        
        xAxis.axisMinimum = 0.0;
        xAxis.granularity = 1.0;
        //        xAxis.valueFormatter = self;
        
        xAxis.labelRotationAngle = 45;
        
        _chartView.hidden = YES;
        
    }
    return _chartView;
}

- (UISegmentedControl *)segControl1
{
    if (!_segControl1) {
        _segControl1 = [[UISegmentedControl alloc] initWithItems:@[@"按月",@"按季",@"按年"]];
        [self addSubview:_segControl1];
        
        [_segControl1 addTarget:self
                         action:@selector(loadingData)
               forControlEvents:UIControlEventValueChanged];
        
        _segControl1.tintColor = MAIN_THEME_COLOR;
        _segControl1.selectedSegmentIndex = 0;
    }
    return _segControl1;
}

- (UISegmentedControl *)segControl2
{
    if (!_segControl2) {
        _segControl2 = [[UISegmentedControl alloc] initWithItems:@[@"按面积",@"按套数"]];
        [self addSubview:_segControl2];
        
        [_segControl2 addTarget:self
                         action:@selector(loadingData)
               forControlEvents:UIControlEventValueChanged];
        
        _segControl2.tintColor = MAIN_THEME_COLOR;
        _segControl2.selectedSegmentIndex = 0;
    }
    return _segControl2;
}

@end

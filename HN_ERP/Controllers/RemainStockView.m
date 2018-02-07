//
//  RemainStockView.m
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "RemainStockView.h"
#import "Defines.h"
#import "HN_ERP-Bridging-Header.h"

@interface RemainStockView () <IChartAxisValueFormatter, IChartValueFormatter, ChartViewDelegate>

@property (nonatomic, strong) UISegmentedControl *segControl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) CombinedChartView *chartView;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) NSArray *chartData;

@end

@implementation RemainStockView

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion
{
    NSLog(@"remain stock loading....");
    
    if (self.loading) return;
    
    self.loading = YES;
    
    if ( [self.areaID isEqualToString:@"0"] ) {
        [self.segControl setTitle:@"按区域" forSegmentAtIndex:0];
    } else {
        [self.segControl setTitle:@"按项目" forSegmentAtIndex:0];
    }
    
    if ( ![self.industryID isEqualToString:@"0"] ) {
        self.segControl.enabled = NO;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@剩余存货",
                            self.areaName, self.industryName];
    
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
//    self.areaID = self.userDefaultArea[@"area_id"];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI剩余货值查询APP",
              @"param1": [@(self.segControl.selectedSegmentIndex) description],
              @"param2": self.areaID,
              @"param3": self.industryID ?: @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
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

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    
    self.loading = NO;
    
//    NSLog(@"result: %@", result);
    
    if ( error ) {
        [self showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0) {
            [self showHUDWithText:@"没有查询到数据" offset:CGPointMake(0,20)];
        } else {
            self.chartData = result[@"data"];
            
            [self populateChartData:result[@"data"]];
        }
    }
    
}

- (void)populateChartData:(NSArray *)data
{
    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
//    rightAxis.axisMaximum = [maxDoneRate integerValue] + 20;
    rightAxis.drawLabelsEnabled = NO;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
//    leftAxis.axisMaximum = [maxVal floatValue] + dtVal;
    
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
                                        y:[item[@"total"] floatValue]];
        [entries addObject:entry];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entries label:@"合计"];
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
    
    set.axisDependency = AxisDependencyLeft;
    
    [d addDataSet:set];
    
    set.highlightEnabled = NO;
    
    set.valueFormatter = self;
    
    return d;
}

- (BarChartData *)generateBarData
{
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    NSMutableArray<BarChartDataEntry *> *entries2 = [[NSMutableArray alloc] init];
    
    NSMutableArray *labels = [@[] mutableCopy];
    
    CGFloat total = 0;
    CGFloat totalGet = 0;
    CGFloat totalUnget = 0;
    
    for (int index = 0; index < self.chartData.count; index++)
    {
        id item = self.chartData[index];
        
        CGFloat getVal = [item[@"get"] floatValue];
        CGFloat ungetVal = [item[@"unget"] floatValue];
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:ungetVal
                                                            data:item]];
        
        [entries2 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:getVal
                                                            data:item]];
        [labels addObject:item[@"name"]];
        
        total += [item[@"total"] floatValue];
        totalGet += [item[@"get"] floatValue];
        totalUnget += [item[@"unget"] floatValue];
    }
    
    NSString *unit = [self.areaID isEqualToString:@"0"] ? @"亿" : @"万";
    self.subtitleLabel.text = [NSString stringWithFormat:@"剩余总货值%.2f%@,其中已拿证%.2f%@,未拿证%.2f%@", total, unit, totalGet, unit, totalUnget, unit];
    
//    [self.chartView.xAxis setXOffset:30];
    self.chartView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:labels];
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithValues:entries1 label:@"未拿证"];
    [set1 setColor:AWColorFromRGB(250, 215, 183)];
    set1.valueTextColor = AWColorFromRGB(250, 215, 183);
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.axisDependency = AxisDependencyLeft;
    
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithValues:entries2 label:@"已拿证"];
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

- (void)chartValueSelected:(ChartViewBase *)chartView
                     entry:(ChartDataEntry *)entry
                 highlight:(ChartHighlight *)highlight
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
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"RemainStockVC" params:params];
    
    [self.navController pushViewController:vc animated:YES];
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    NSLog(@"value: %f", value);
    
    NSInteger index = (int)value % self.chartData.count;
    id item = self.chartData[index];
//    NSLog(@"name: %@", item[@"name"]);
    return item[@"name"];
}

- (NSString * _Nonnull)stringForValue:(double)value entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler * _Nullable)viewPortHandler
{
    //    NSInteger index = (int)value % self.chartData.count;
    //    ChartItem *item = self.chartData[index];
    
    if ( [entry isKindOfClass:[BarChartDataEntry class]] ) {
        return [NSString stringWithFormat:@"%.2f", entry.y];
    }
    
    return [NSString stringWithFormat:@"%.2f", entry.y];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.segControl.position = CGPointMake(self.width / 2 - self.segControl.width / 2, 15);
    
    self.titleLabel.frame = CGRectMake(0, self.segControl.bottom + 6,
                                       self.width, 27);
    self.subtitleLabel.frame = CGRectMake(10, self.titleLabel.bottom,
                                          self.width - 20,
                                          27);
    
//    self.chartView.frame = CGRectMake(10, self.subtitleLabel.bottom + 5,
//                                      self.width - 20,
//                                      self.width - 20);
    self.chartView.position = CGPointMake(10, self.subtitleLabel.bottom + 5);
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
        
//        if ( [self.areaID integerValue] != 0 &&
//            [self.showType integerValue] == 0 ) {
//            self.chartView.highlightPerTapEnabled = NO;
//        }
        
        _chartView.highlightPerDragEnabled = NO;
        
        _chartView.delegate = self;
        _chartView.doubleTapToZoomEnabled = NO;
        //    chartView.drawMarkers = YES;
        //    chartView.pinchZoomEnabled = NO;
        
        _chartView.drawOrder = @[
                                @(CombinedChartDrawOrderBar),
                                @(CombinedChartDrawOrderLine),
                                ];
        
        ChartLegend *l = _chartView.legend;
        l.wordWrapEnabled = YES;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
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

- (UILabel *)subtitleLabel
{
    if ( !_subtitleLabel ) {
        _subtitleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    MAIN_THEME_COLOR);
        [self addSubview:_subtitleLabel];
        
        _subtitleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _subtitleLabel;
}

- (UISegmentedControl *)segControl
{
    if ( !_segControl ) {
        _segControl = [[UISegmentedControl alloc] initWithItems:@[@"按区域",@"按业态"]];
        
        [self addSubview:_segControl];
        _segControl.frame = CGRectMake(0, 0, 150, 34);
        _segControl.selectedSegmentIndex = 0;
        _segControl.tintColor = MAIN_THEME_COLOR;
        
        [_segControl addTarget:self
                action:@selector(segChanged:)
      forControlEvents:UIControlEventValueChanged];
    }
    return _segControl;
}

- (void)segChanged:(UISegmentedControl *)sender
{
    [self startLoadingData:nil];
}

@end

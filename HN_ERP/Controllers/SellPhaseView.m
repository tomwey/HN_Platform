//
//  SellPhaseView.m
//  HN_ERP
//
//  Created by tomwey on 21/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SellPhaseView.h"
#import "Defines.h"
#import "HN_ERP-Bridging-Header.h"

@interface SellPhaseView () <ChartViewDelegate>

@property (nonatomic, strong) UISegmentedControl *segControl1;
@property (nonatomic, strong) UISegmentedControl *segControl2;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) NSArray *chartData;

@property (nonatomic, strong) PieChartView *chartView;

@property (nonatomic, strong) UILabel *showResultLabel;

@end

@implementation SellPhaseView

- (void)startLoadingData:(void (^)(BOOL, NSError *))completion
{
    [self loadingData];
}

- (void)loadingData
{
    self.showResultLabel.text = nil;
    
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
              @"funname": @"城市地图BI成交分段占比APP",
              @"param1": self.userData[@"cityID"] ?: @"0",
              @"param2": self.userData[@"platID"] ?: @"0",
              @"param3": self.userData[@"bYear"] ?: @"0",
              @"param4": self.userData[@"bMonth"] ?: @"0",
              @"param5": self.userData[@"eYear"] ?: @"0",
              @"param6": self.userData[@"eMonth"] ?: @"0",
              @"param7": [@(self.segControl1.selectedSegmentIndex) description],
              @"param8": @"",
              @"param9": [@(self.segControl2.selectedSegmentIndex) description],
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
    [self updateChartViewCenterText];
    
    self.chartData = data;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    CGFloat totalRate = 0.0;
    for (int i = 0; i < data.count; i++)
    {
        id item = data[i];
//        NSString *label = [NSString stringWithFormat:@"%@ %", item[@"partname"], item[@"rate"]];
        CGFloat rate = HNFloatFromObject(item[@"rate"], 0.0);
        totalRate += rate;
        [values addObject:[[PieChartDataEntry alloc] initWithValue:rate
                                                             label:item[@"partname"]
                                                              data:item]];
    }
    
    self.chartView.hidden = NO;
    
    if ( totalRate == 0.0 ) {
        self.chartView.hidden = YES;
        [self showHUDWithText:@"分段占比数据为0" offset:CGPointMake(0,20)];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values label:@"成交分段占比"];
    
    dataSet.drawIconsEnabled = NO;
    
    dataSet.sliceSpace = 2.0;
    dataSet.iconsOffset = CGPointMake(0, 40);
    
    // add a lot of colors
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    
    dataSet.colors = colors;
    
    dataSet.sliceSpace = 0;//相邻区块之间的间距
    dataSet.selectionShift = 8;//选中区块时, 放大的半径
    dataSet.xValuePosition = PieChartValuePositionInsideSlice;//名称位置
    dataSet.yValuePosition = PieChartValuePositionOutsideSlice;//数据位置
    //数据与区块之间的用于指示的折线样式
    dataSet.valueLinePart1OffsetPercentage = 0.85;//折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
    dataSet.valueLinePart1Length = 0.5;//折线中第一段长度占比
    dataSet.valueLinePart2Length = 0.4;//折线中第二段长度最大占比
    dataSet.valueLineWidth = 1;//折线的粗细
    dataSet.valueLineColor = [UIColor brownColor];//折线颜色
    
    PieChartData *chartData = [[PieChartData alloc] initWithDataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [chartData setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [chartData setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [chartData setValueTextColor:UIColor.blackColor];
    
    if ( totalRate > 0.0 ) {
        self.chartView.data = chartData;
    }
    
    _chartView.legend.maxSizePercent = 1;//图例在饼状图中的大小占比, 这会影响图例的宽高
    _chartView.legend.formToTextSpace = 5;//文本间隔
    _chartView.legend.font = [UIFont systemFontOfSize:10];//字体大小
    _chartView.legend.textColor = [UIColor grayColor];//字体颜色
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;//图例在饼状图中的位置
    _chartView.legend.form = ChartLegendFormCircle;//图示样式: 方形、线条、圆形
    _chartView.legend.formSize = 6;//图示大小
    
    [self.chartView highlightValue:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.showResultLabel.frame = CGRectMake(15, 5, self.width - 30,34);
    
    CGFloat width = (self.width - 30 - 10) / 2.0;
    self.segControl1.frame = CGRectMake(0, 0, width, 34);
    self.segControl2.frame = CGRectMake(0, 0, width, 34);
    
    self.segControl1.position = CGPointMake(15, self.height - 10 - self.segControl1.height);
    self.segControl2.position = self.segControl1.position;
    self.segControl2.left = self.width - 15 - self.segControl2.width;
    
//    self.chartView.height -= 14;
    
    self.chartView.position = CGPointMake(10, self.segControl1.top - 10 - self.chartView.height);
    
    
}

- (PieChartView *)chartView
{
    if ( !_chartView ) {
        _chartView = [[PieChartView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth() - 20,
                                                                    AWFullScreenWidth() - 20)];
        [self addSubview:_chartView];
        
        [_chartView setExtraOffsetsWithLeft:30 top:0 right:30 bottom:0];
        _chartView.usePercentValuesEnabled = YES;
        _chartView.dragDecelerationEnabled = YES;
        _chartView.drawSliceTextEnabled = NO;

        _chartView.delegate = self;
        
        _chartView.noDataText = @"无数据显示";
        
        _chartView.drawHoleEnabled = YES;//饼状图是否是空心
        _chartView.holeRadiusPercent = 0.6;//空心半径占比
        _chartView.holeColor = [UIColor clearColor];//空心颜色
        _chartView.transparentCircleRadiusPercent = 0.5;//半透明空心半径占比
        _chartView.transparentCircleColor = [UIColor colorWithRed:210/255.0 green:145/255.0 blue:165/255.0 alpha:0.3];//半透明空心的颜色
        
//        _chartView.centerText = @"面积段占比";
        
        _chartView.descriptionText = @"";
        
//        _chartView.legend.maxSizePercent = 1;//图例在饼状图中的大小占比, 这会影响图例的宽高
//        _chartView.legend.formToTextSpace = 5;//文本间隔
//        _chartView.legend.font = [UIFont systemFontOfSize:10];//字体大小
//        _chartView.legend.textColor = [UIColor grayColor];//字体颜色
//        _chartView.legend.position = ChartLegendPositionBelowChartLeft;//图例在饼状图中的位置
//        _chartView.legend.form = ChartLegendFormCircle;//图示样式: 方形、线条、圆形
//        _chartView.legend.formSize = 6;//图示大小
        
        _chartView.hidden = YES;
    }
    return _chartView;
}

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight
{
    NSLog(@"%@", entry.data);
    id item = entry.data;
    NSArray *units = @[@"套",@"万㎡",@"万元"];
    NSString *unit = units[self.segControl2.selectedSegmentIndex];
    id val = item[@"value"];
    if ( self.segControl2.selectedSegmentIndex > 0 ) {
        val = [NSString stringWithFormat:@"%.1f", [val floatValue] / 10000.0];
    }
    self.showResultLabel.text = [NSString stringWithFormat:@"%@ 成交%@%@", item[@"partname"], val ,unit];
}

- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView
{
    self.showResultLabel.text = nil;
}

- (UISegmentedControl *)segControl1
{
    if (!_segControl1) {
        _segControl1 = [[UISegmentedControl alloc] initWithItems:@[@"面积",@"单价",@"总价"]];
        [self addSubview:_segControl1];
        
        [_segControl1 addTarget:self
                         action:@selector(valueChanged)
               forControlEvents:UIControlEventValueChanged];
        
        _segControl1.tintColor = MAIN_THEME_COLOR;
        _segControl1.selectedSegmentIndex = 0;
    }
    return _segControl1;
}

- (void)valueChanged
{
//    [self updateChartViewCenterText];
    
    [self loadingData];
}

- (void)updateChartViewCenterText
{
    NSString *title = [self.segControl1 titleForSegmentAtIndex:self.segControl1.selectedSegmentIndex];
    NSString *title2 = [self.segControl2 titleForSegmentAtIndex:self.segControl2.selectedSegmentIndex];
    self.chartView.centerText = [NSString stringWithFormat:@"%@段%@占比", title,title2];
}

- (UISegmentedControl *)segControl2
{
    if (!_segControl2) {
        _segControl2 = [[UISegmentedControl alloc] initWithItems:@[@"套数",@"面积", @"金额"]];
        [self addSubview:_segControl2];
        
        [_segControl2 addTarget:self
                         action:@selector(loadingData)
               forControlEvents:UIControlEventValueChanged];
        
        _segControl2.tintColor = MAIN_THEME_COLOR;
        _segControl2.selectedSegmentIndex = 0;
    }
    return _segControl2;
}

- (UILabel *)showResultLabel
{
    if ( !_showResultLabel ) {
        _showResultLabel = AWCreateLabel(CGRectZero,
                                         nil,
                                         NSTextAlignmentCenter,
                                         AWSystemFontWithSize(15, NO),
                                         MAIN_THEME_COLOR);
        [self addSubview:_showResultLabel];
        _showResultLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return _showResultLabel;
}

@end

//
//  BIBarDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 5/31/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BIBarDetailVC.h"
#import "Defines.h"
#import "HN_ERP-Bridging-Header.h"
#import "SelectButton.h"
#import "TYAttributedLabel.h"
#import "BubbleView.h"
#import "HNTimeSelect.h"

@interface ChartItem : NSObject

@property (nonatomic, copy) NSString *id_;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *plan;
@property (nonatomic, copy) NSNumber *real;

@property (nonatomic, copy) NSNumber *rate;
@property (nonatomic, copy, readonly) NSNumber *maxVal;

- (instancetype)initWithName:(NSString *)name
                        plan:(NSNumber *)plan
                        real:(NSNumber *)real
                        rate:(NSNumber *)rate;

@end

@implementation ChartItem

- (instancetype)initWithName:(NSString *)name
                        plan:(NSNumber *)plan
                        real:(NSNumber *)real
                        rate:(NSNumber *)rate
{
    if ( self = [super init] ) {
        self.name = name;
        self.plan = plan;
        self.real = real;
        self.rate = rate;
    }
    return self;
}

- (NSNumber *)maxVal
{
    float plan = [self.plan floatValue];
    float real = [self.real floatValue];
    
    float max = MAX(plan, real);
    return @(max);
}

@end

@interface BIBarDetailVC () <UITableViewDataSource, UITableViewDelegate,IChartAxisValueFormatter, IChartValueFormatter, ChartViewDelegate>

@property (nonatomic, strong) NSArray *chartData;

@property (nonatomic, strong) CombinedChartView *chartView;

@property (nonatomic, weak) ChartXAxis *xaxis;
@property (nonatomic, weak) ChartYAxis *rightYAxis;

@property (nonatomic, weak)   UIView *toolView;

//@property (nonatomic, strong) SelectButton *monthButton;
//@property (nonatomic, strong) id currentMonthOption;
//@property (nonatomic, strong) NSArray *monthData;
//
//@property (nonatomic, strong) SelectButton *yearButton;
//@property (nonatomic, strong) id currentYearOption;
//@property (nonatomic, strong) NSArray *yearData;

@property (nonatomic, strong) HNTimeSelect *timeSelect;

@property (nonatomic, copy) NSString *showType;

@property (nonatomic, copy) NSString *areaID;
@property (nonatomic, copy) NSString *industryID;

@property (nonatomic, strong) TYAttributedLabel *titleLabel;

@property (nonatomic, strong) NSDictionary *totalSummary;
@property (nonatomic, weak) UIButton *detailButton;

@property (nonatomic, strong) BubbleView *bubbleView;
@property (nonatomic, strong) NSArray *bubbleData;

@end

@implementation BIBarDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = [NSString stringWithFormat:@"%@%@%@图表",
                         self.params[@"area"][@"name"],
                         self.params[@"industry"][@"name"],
                         self.params[@"action"]];
    
    self.areaID = [self.params[@"area"][@"id"] description];
    self.industryID = [self.params[@"industry"][@"id"] description];
    //self.params[@"commData"][@"value"] ?: @"0";
    
    __weak typeof(self) me = self;
    self.detailButton = (UIButton *)[self addRightItemWithTitle:@"明细"
                titleAttributes: @{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(60, 40) rightMargin:5
                       callback:^{
                           [me gotoDataDetail];
                       }];
    
    self.detailButton.enabled = NO;
    
//    self.detailButton.backgroundColor = [UIColor greenColor];
    
    // 添加显示隐藏数值
//    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    FAKIonIcons *icon = [FAKIonIcons iosEyeOutlineIconWithSize:30];
//    [icon addAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
//    UIImage *image = [icon imageWithSize:CGSizeMake(34, 40)];
//    [showBtn setImage:image forState:UIControlStateNormal];
//    [showBtn sizeToFit];
//    
//    [showBtn addTarget:self
//                action:@selector(openShowTips)
//      forControlEvents:UIControlEventTouchUpInside];
////    self.navBar.rightMarginOfRightItem = 5;
////    showBtn.backgroundColor = [UIColor redColor];
//    
//    [self.navBar addFluidBarItem:showBtn atPosition:FluidBarItemPositionTitleRight];
    
    // 添加工具条
    [self initToolView];
    
    // 标题
    self.titleLabel = [[TYAttributedLabel alloc] init];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.frame = CGRectMake(15, self.toolView.bottom + 15,
                                  self.contentView.width - 30,
                                  40);
//    [self updateTitleLabelText];
    
    // 图表
    CombinedChartView *chartView =
        [[CombinedChartView alloc] initWithFrame:
         CGRectMake(10, self.titleLabel.bottom + 15, self.contentView.width - 20, self.contentView.width - 20)];
    [self.contentView addSubview:chartView];
    
    self.chartView = chartView;
    
    chartView.chartDescription.enabled = NO;
    
    chartView.drawGridBackgroundEnabled = NO;
    chartView.drawBarShadowEnabled = NO;
    chartView.highlightFullBarEnabled = NO;
    chartView.highlightPerTapEnabled = YES;
    
    if ( [self.areaID integerValue] != 0 &&
        [self.showType integerValue] == 0 ) {
        self.chartView.highlightPerTapEnabled = NO;
    }
    
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
    
//    [self initToolbar];
}

- (void)openShowTips
{
    self.bubbleData = @[@{
                            @"label": @"显示计划数值",
                            @"value": @(YES),
                            },
                        @{
                            @"label": @"显示实际数值",
                            @"value": @(YES),
                            },
                        @{
                            @"label": @"显示完成率数值",
                            @"value": @(YES),
                            },
                        ];
    [self.bubbleView showInView:AWAppWindow()];
    
    UITableView *tableView = (UITableView *)[self.bubbleView viewWithTag:1011];
    [tableView reloadData];
}

- (BubbleView *)bubbleView
{
    if ( !_bubbleView ) {
        _bubbleView = [[BubbleView alloc] init];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                              style:UITableViewStylePlain];
        [_bubbleView addSubview:tableView];
        
        tableView.tag = 1011;
        
        tableView.dataSource = self;
        
        tableView.backgroundColor = [UIColor clearColor];
        
        [tableView removeCompatibility];
        
        [tableView removeBlankCells];
        
        tableView.frame = CGRectMake(10, 15, 160, 160);
    }
    return _bubbleView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bubbleData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id item = self.bubbleData[indexPath.row];
    
    cell.textLabel.text = item[@"label"];
    cell.textLabel.textColor = AWColorFromRGB(247, 247, 247);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)gotoDataDetail
{
    NSMutableDictionary *params = [self.params mutableCopy];
    params[@"total_summary"] = self.totalSummary ?: @{};
    params[@"timeData"] = @{
                            @"year": [@(self.timeSelect.year) description],
                            @"quarter": [@(self.timeSelect.quarter) description],
                            @"month": [@(self.timeSelect.month) description],
                            @"week": [@(self.timeSelect.weekOfMonth) description],
                            };
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"BIDataDetailVC" params:params];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateTitleLabelText
{
    float totalPlan = 0;
    float totalReal = 0;
    
    for (ChartItem *item in self.chartData) {
        totalPlan += [item.plan floatValue];
        totalReal += [item.real floatValue];
    }
    
    self.titleLabel.text = nil;
    self.titleLabel.attributedText = nil;
    
    NSString *unit = [[self.areaID description] isEqualToString:@"0"] ? @"亿" : @"万";
    
    NSString *string = [NSString stringWithFormat:@"计划%@",
//                        self.params[@"area"][@"name"],
//                        self.params[@"industry"][@"name"],
//                        self.currentMonthOption[@"name"],
                        self.params[@"action"]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttributeFont:AWSystemFontWithSize(15, NO)];
    [attrString addAttributeTextColor:AWColorFromRGB(58, 58, 58)];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    if ([unit isEqualToString:@"万"]) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)ceilf(totalPlan)]];
    } else {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", totalPlan]];
    }
    
    [attrString addAttributeFont:AWSystemFontWithSize(18, NO)];
    [attrString addAttributeTextColor:MAIN_THEME_COLOR];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    attrString = [[NSMutableAttributedString alloc] initWithString:
                  [NSString stringWithFormat:@"%@，实际%@", unit, self.params[@"action"]]];
    [attrString addAttributeFont:AWSystemFontWithSize(15, NO)];
    [attrString addAttributeTextColor:AWColorFromRGB(58, 58, 58)];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
//    attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)ceilf(totalReal)]];
    
    if ([unit isEqualToString:@"万"]) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)ceilf(totalReal)]];
    } else {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", totalReal]];
    }
    
    [attrString addAttributeFont:AWSystemFontWithSize(18, NO)];
    [attrString addAttributeTextColor:MAIN_THEME_COLOR];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    attrString = [[NSMutableAttributedString alloc] initWithString:unit];
    [attrString addAttributeFont:AWSystemFontWithSize(15, NO)];
    [attrString addAttributeTextColor:AWColorFromRGB(58, 58, 58)];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    [self.titleLabel sizeToFit];
    
    self.chartView.top = self.titleLabel.bottom + 15;
    
    self.totalSummary = @{
                          @"plan": @(totalPlan),
                          @"real": @(totalReal),
                          @"unit": unit,
                          };
    self.detailButton.enabled = YES;
}

- (void)loadData
{
    self.titleLabel.hidden = YES;
    self.chartView.hidden  = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSString *taskType = @"0";
    NSString *quarter  = [@(self.timeSelect.quarter) description];
    NSString *month    = [@(self.timeSelect.month) description];;
    NSString *year     = [@(self.timeSelect.year) description];;
    NSString *week     = [@(self.timeSelect.weekOfMonth) description];;
    
//    if ( self.timeSelect.quarter == 0 ) {
//        taskType = @"0";
//    } else if ( self.timeSelect.month == 0 ) {
//        taskType = @"1";
//    } else {
//        taskType = @"2";
//    }
    
    if ( self.timeSelect.quarter == 0 ) {
        taskType = @"0";
    } else {
        if ( self.timeSelect.month == 0 ) {
            taskType = @"1";
        } else {
            taskType = @"2";
        }
    }
    
//    NSInteger monthVal = [self.currentMonthOption[@"value"] integerValue];
//    if ( monthVal == 0 ) { // 年度
//        taskType = @"0";
//    } else if ( monthVal >= 5 ) { // 月度
//        taskType = @"2";
//        month = [@(monthVal - 4) description]; // 所有的月度值加了4
//    } else { // 季度
//        taskType = @"1";
//        quarter = [@(monthVal) description];
//    }
    
//    NSString *year     = self.currentYearOption[@"value"];
//    NSString *userTypeID = @"0";
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI签约回款报表周查询APP",
              @"param1": self.showType,
              @"param2": self.areaID,
              @"param3": self.industryID,
              @"param4": taskType,
              @"param5": year,
              @"param6": quarter,
              @"param7": month,
              @"param8": week,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult: result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
//        conplan = 61766;
//        conrate = 0;
//        conreal = "2.89";
//        feeplan = 0;
//        feerate = 0;
//        feereal = "32233.86";
//        id = 1679353;
//        myguid = "AAE4AD4D-6089-4897-9691-C976D6082F03";
//        name = "\U897f\U5b89";
//        type = 0;
        if ( [result[@"rowcount"] integerValue] == 0) {
            [self.contentView showHUDWithText:@"没有查询到数据" offset:CGPointMake(0,20)];
        } else {
            NSArray *data = result[@"data"];
            
            NSMutableArray *temp = [NSMutableArray array];
            
            NSString *prefix = [self.params[@"action"] isEqualToString:@"签约"] ? @"con": @"fee";
            
            for (id dict in data) {
                
                NSString *planKey = [NSString stringWithFormat:@"%@plan",
                                     prefix];
                NSString *realKey = [NSString stringWithFormat:@"%@real",
                                     prefix];
                NSString *rateKey = [NSString stringWithFormat:@"%@rate",
                                     prefix];
                
                NSNumber *planVal = @(0.00);
                NSNumber *realVal = @(0.00);
                NSNumber *rateVal = @(0.00);
                if ( ![[dict[planKey] description] isEqualToString:@"NULL"] ) {
                    planVal = dict[planKey];
                }
                
                if ( ![[dict[realKey] description] isEqualToString:@"NULL"] ) {
                    realVal = dict[realKey];
                }
                
                if ( ![[dict[rateKey] description] isEqualToString:@"NULL"] ) {
                    rateVal = dict[rateKey];
                }
                
                ChartItem *item = [[ChartItem alloc] initWithName:dict[@"name"]
                                                             plan:planVal
                                                             real:realVal
                                                             rate:rateVal];
                item.id_ = [dict[@"id"] description];
                
                [temp addObject:item];
            }
            
            self.chartData = temp;
            
            self.titleLabel.hidden = NO;
            [self updateTitleLabelText];
            
            self.chartView.hidden  = NO;
            [self updateChartView];
        }
    }
}

- (void)updateChartView
{
    // 获取指标最大值
    __block NSNumber *maxVal = [[self.chartData firstObject] maxVal];
    __block NSNumber *maxDoneRate = [[self.chartData firstObject] rate];
    [self.chartData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChartItem *item = (ChartItem *)obj;
        if ( ![[item.maxVal description] isEqualToString:@"NULL"] &&
            [maxVal compare:item.maxVal] == NSOrderedAscending ) {
            maxVal = item.maxVal;
        }

        if (![[item.rate description] isEqualToString:@"NULL"] &&
            [maxDoneRate compare:item.rate] == NSOrderedAscending ) {
            maxDoneRate = item.rate;
        }
    }];
    
    ChartYAxis *rightAxis = self.chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    rightAxis.axisMaximum = [maxDoneRate integerValue] + 20;
    rightAxis.drawLabelsEnabled = NO;
    //    rightAxis.granularity = 10;
    
    float dtVal = [[self.areaID description] isEqualToString:@"0"] ? 1.0 : 10000;
    
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    leftAxis.axisMaximum = [maxVal floatValue] + dtVal;
    
//    leftAxis.axisLineWidth = 0.5;
//    leftAxis.axisLineColor = AWColorFromRGB(235, 235, 235);
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
    leftAxis.gridColor = AWColorFromRGB(201, 201, 201);//网格线颜色
    leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
    
    CombinedChartData *combData = [[CombinedChartData alloc] init];
    
    combData.lineData = [self generateLineData];
    combData.barData  = [self generateBarData];
    
    self.chartView.data = combData;
    
    self.chartView.xAxis.axisMaximum = combData.xMax + 0.5;
    
    [self.chartView animateWithYAxisDuration:.5];
}

- (void)initToolView
{
    UIView *toolView = [[UIView alloc] init];
    [self.contentView addSubview:toolView];
    toolView.frame = CGRectMake(0, 0, self.contentView.width, 60);
    toolView.backgroundColor = [UIColor whiteColor];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // 设置工具条
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:toolView.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:toolView];
    line.position = CGPointMake(0, toolView.height - 0.5);
    
    NSString *name = [[self.areaID description] isEqualToString:@"0"] ? @"区域" : @"项目";
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[name, @"业态"]];
    [toolView addSubview:seg];
    seg.frame = CGRectMake(15, 13, 90, 34);
    seg.selectedSegmentIndex = 0;
    seg.tintColor = MAIN_THEME_COLOR;
    
    [seg addTarget:self
            action:@selector(segChanged:)
  forControlEvents:UIControlEventValueChanged];
    
    if ( ![self.industryID isEqualToString:@"0"] ) {
        seg.enabled = NO;
    }
    
    self.showType = [@(seg.selectedSegmentIndex) description];
    
    self.toolView = toolView;
    
    self.timeSelect = [[HNTimeSelect alloc] init];
    [toolView addSubview:self.timeSelect];
    
    self.timeSelect.needUpdateWeekOfMonth = NO;
    
    [self.timeSelect prepareInitData];
    
    self.timeSelect.frame = CGRectMake(0, 0, self.contentView.width - 30 - seg.width - 15, 34);
    
    self.timeSelect.containerView = self.contentView;
    
    self.timeSelect.year = [self.params[@"timeData"][@"year"] integerValue];
    self.timeSelect.quarter = [self.params[@"timeData"][@"quarter"] integerValue];
    self.timeSelect.month = [self.params[@"timeData"][@"month"] integerValue];
    self.timeSelect.weekOfMonth = [self.params[@"timeData"][@"week"] integerValue];
    
    __weak typeof(self) me = self;
    self.timeSelect.timeSelectDidChange = ^(HNTimeSelect *sender) {
        [me updateMonthButton];
    };
    
    self.timeSelect.center = CGPointMake(toolView.width - 15 - self.timeSelect.width / 2,
                                         seg.midY);
    
    [self updateMonthButton];
}

- (void)segChanged:(UISegmentedControl *)sender
{
    self.showType = [@(sender.selectedSegmentIndex) description];
    
    if ( [self.areaID integerValue] != 0 &&
        [self.showType integerValue] == 0 ) {
        self.chartView.highlightPerTapEnabled = NO;
    } else {
        self.chartView.highlightPerTapEnabled = YES;
    }
    
    [self loadData];
}

- (void)updateMonthButton
{
    [self loadData];
}

- (void)openPickerForData:(NSArray *)data
{
}

- (LineChartData *)generateLineData
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < self.chartData.count; index++)
    {
        ChartItem *item = self.chartData[index];
        
        [entries addObject:[[ChartDataEntry alloc] initWithX:index + 0.625
                                                           y:[item.rate integerValue]]];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entries label:@"完成率"];
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

- (BarChartData *)generateBarData
{
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    NSMutableArray<BarChartDataEntry *> *entries2 = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < self.chartData.count; index++)
    {
        ChartItem *item = self.chartData[index];
        
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:[item.plan doubleValue]
                                                            data:item]];
        [entries2 addObject:[[BarChartDataEntry alloc] initWithX:0
                                                               y:
                             [item.real doubleValue]
                                                            data:item]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithValues:entries1 label:@"计划签约"];
    [set1 setColor:AWColorFromRGB(250, 215, 183)];
    set1.valueTextColor = AWColorFromRGB(250, 215, 183);//MAIN_THEME_COLOR;//AWColorFromRGB(58, 58, 58);
    //[UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.axisDependency = AxisDependencyLeft;

    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithValues:entries2 label:@"实际签约"];
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
    NSLog(@"data: %@", [entry.data name]);
    
    if ( [entry.data isKindOfClass:[ChartItem class]] ) {
        ChartItem *item = (ChartItem *)entry.data;
        
        NSMutableDictionary *params = [@{} mutableCopy];
        params[@"timeData"] = @{
                                @"year": [@(self.timeSelect.year) description],
                                @"quarter": [@(self.timeSelect.quarter) description],
                                @"month": [@(self.timeSelect.month) description],
                                @"week": [@(self.timeSelect.weekOfMonth) description],
                                //                                              @"year": @"2017",
                                //                                              @"value": @"",
                                //                                              @"name": @"",
                                };
        /*@{
                                @"year": [self.currentYearOption[@"value"] description],
                                @"value": [self.currentMonthOption[@"value"] description],
                                @"name": [self.currentMonthOption[@"name"] description],
                                }*/;
        params[@"action"] = self.params[@"action"] ?: @"";
        
        NSString *pageName = nil;
        if ( [self.areaID integerValue] == 0 ) {
            // 全集团
            if ( [self.showType integerValue] == 0 ) {
                // 区域
                pageName = @"BIBarDetailVC";
                params[@"area"] = @{
                                    @"id": item.id_,
                                    @"name": item.name,
                                    };
                params[@"industry"] = self.params[@"industry"] ?: @{};
            } else {
                // 业态
                pageName = @"BIBarDetailVC";
                params[@"area"] = self.params[@"area"] ?: @{};
                params[@"industry"] = @{
                                        @"id": item.id_,
                                        @"name": item.name
                                        };
            }
        } else {
            // 具体某个区域
            if ( [self.showType integerValue] == 0 ) {
                // 项目
//                pageName = @"BIProjDetailVC";
                params[@"area"] = self.params[@"area"] ?: @{};
                params[@"industry"] = self.params[@"industry"] ?: @{};
                params[@"proj"] = @{
                                    @"id": item.id_,
                                    @"name": item.name,
                                    };
            } else {
                // 业态
                pageName = @"BIBarDetailVC";
                params[@"area"] = self.params[@"area"] ?: @{};
                params[@"industry"] = @{
                                        @"id": item.id_,
                                        @"name": item.name,
                                        };
            }
        }
        
        if ( pageName ) {
            UIViewController *vc =
            [[AWMediator sharedInstance] openVCWithName:pageName params:params];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    [self.chartView highlightValues:nil];
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    NSInteger index = (int)value % self.chartData.count;
    ChartItem *item = self.chartData[index];
    return item.name;
}

- (NSString * _Nonnull)stringForValue:(double)value entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler * _Nullable)viewPortHandler
{
//    NSInteger index = (int)value % self.chartData.count;
//    ChartItem *item = self.chartData[index];
    
    if ( [entry isKindOfClass:[BarChartDataEntry class]] ) {
        return [NSString stringWithFormat:@"%.2f", entry.y];
    }
    
    return [NSString stringWithFormat:@"%d%%", (int)entry.y];
}

//- (NSArray *)yearData
//{
//    if ( !_yearData ) {
//        _yearData = @[@{
//                          @"name": @"2017年",
//                          @"value": @"2017",
//                          },
//                      @{
//                          @"name": @"2016年",
//                          @"value": @"2016",
//                          },
//                      @{
//                          @"name": @"2015年",
//                          @"value": @"2015",
//                          },
//                      @{
//                          @"name": @"2014年",
//                          @"value": @"2014",
//                          },
//                      ];
//    }
//    return _yearData;
//}

//- (NSArray *)monthData
//{
//    if ( !_monthData ) {
//        NSArray *data = @[@{
//                               @"name": @"全年",
//                               @"value": @"0",
//                               },
//                           @{
//                               @"name": @"一季度",
//                               @"value": @"1",
//                               },
//                           @{
//                               @"name": @"二季度",
//                               @"value": @"2",
//                               },
//                           @{
//                               @"name": @"三季度",
//                               @"value": @"3",
//                               },
//                           @{
//                               @"name": @"四季度",
//                               @"value": @"4",
//                               },
//                           @{
//                               @"name": @"1月",
//                               @"value": @"5",
//                               },
//                           @{
//                               @"name": @"2月",
//                               @"value": @"6",
//                               },
//                           @{
//                               @"name": @"3月",
//                               @"value": @"7",
//                               },
//                           @{
//                               @"name": @"4月",
//                               @"value": @"8",
//                               },
//                           @{
//                               @"name": @"5月",
//                               @"value": @"9",
//                               },
//                           @{
//                               @"name": @"6月",
//                               @"value": @"10",
//                               },
//                           @{
//                               @"name": @"7月",
//                               @"value": @"11",
//                               },
//                           @{
//                               @"name": @"8月",
//                               @"value": @"12",
//                               },
//                           @{
//                               @"name": @"9月",
//                               @"value": @"13",
//                               },
//                           @{
//                               @"name": @"10月",
//                               @"value": @"14",
//                               },
//                           @{
//                               @"name": @"11月",
//                               @"value": @"15",
//                               },
//                           @{
//                               @"name": @"12月",
//                               @"value": @"16",
//                               },];
//        _monthData = data;
//    }
//    return _monthData;
//}

@end

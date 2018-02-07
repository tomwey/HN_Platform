//
//  InvestVC.m
//  HN_ERP
//
//  Created by tomwey on 7/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "InvestVC.h"
#import "Defines.h"
#import "HN_ERP-Bridging-Header.h"

@interface InvestVC () <ChartViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentTop;

@property (nonatomic, strong) PieChartView *chartView;

@property (nonatomic, assign) CGFloat totalMoney;
@property (nonatomic, assign) CGFloat expectedEarning;

@property (nonatomic, assign) NSInteger totalProject;

@property (nonatomic, assign) CGFloat totalCapMoney;

@property (nonatomic, strong) NSArray *flData;

@property (nonatomic, weak) UIButton *rightButton;

@end

@implementation InvestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"我的跟投";
    
    self.contentView.backgroundColor = AWColorFromRGB(235, 235, 241);
    
    __weak typeof(self) me = self;
    self.rightButton = (UIButton *)[self addRightItemWithTitle:@"项目资讯"
                titleAttributes:@{
                                  NSFontAttributeName: AWSystemFontWithSize(15, NO)
                                  }
                           size:CGSizeMake(100, 40)
                    rightMargin:0
                       callback:^{
                           [me gotoNews];
                       }];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.currentTop = 0.0;
    
//    self.scrollView.hidden = YES;
    
    [self loadData];
    
    [self loadNewsBadge];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNewsBadge)
                                                 name:@"kInvestNewsDidViewNotification"
                                               object:nil];
    
//    [self addOtherSections];
}

- (void)loadNewsBadge
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"跟投项目咨询未读条数APP",
              @"param1": @"0",
              @"param2": manID,
              } completion:^(id result, NSError *error) {
                  [me changeNewsBadge:result error:error];
              }];
}

- (void)changeNewsBadge:(id)result error:(NSError *)error
{
    if ( !error ) {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            id item = [result[@"data"] firstObject];
            if ( item && [item[@"total"] integerValue] > 0 ) {
                id count = [item[@"total"] integerValue] > 99 ? @"99+" : item[@"total"];
                [self.rightButton setTitle:[NSString stringWithFormat:@"项目咨询(%@)", count]
                                  forState:UIControlStateNormal];
            }
        }
    }
}

- (void)gotoNews
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"InvestNewsVC"
                                                                params:@{ @"proj_id": @"0" }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadData
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"跟投项目列表APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"无数据显示" offset:CGPointMake(0, 20)];
        } else {
            
            self.flData = result[@"data"];
            
            for (id item in self.flData) {
                CGFloat money = [item[@"money"] floatValue];
                
                self.totalMoney += money;
                
                self.expectedEarning += [item[@"expectedearn"] floatValue];
                
                self.totalCapMoney += [item[@"capitalmoney"] floatValue];
            }
            
            [self addHeadView];
            
            [self addShortcut];
            
            [self addChartView];
            
            self.scrollView.contentSize = CGSizeMake(self.contentView.width, self.currentTop);
        }
    }
}

- (void)addChartView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop,
                                                            self.contentView.width,
                                                            330)];
    [self.scrollView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = view.bottom + 10;
    
    UIView *view2 = [self headViewForTitle:@"各项目跟投本金分布"];
    
    [view addSubview:view2];
    
    // 饼图
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.flData.count; i++)
    {
        id item = self.flData[i];
        //        NSString *label = [NSString stringWithFormat:@"%@ %", item[@"partname"], item[@"rate"]];
//        CGFloat rate = HNFloatFromObject(item[@"rate"], 0.0);
//        totalRate += rate;
        NSString *name = HNStringFromObject(item[@"projaliasname"], @"");
        if ( name.length == 0 ) {
            name = HNStringFromObject(item[@"projname"], @"");
        }
        [values addObject:[[PieChartDataEntry alloc] initWithValue:[item[@"money"] floatValue]
                                                             label:name
                                                              data:item]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values label:@""];
    
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
    pFormatter.percentSymbol = @" 元";
    [chartData setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [chartData setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [chartData setValueTextColor:UIColor.blackColor];
    
//    if ( totalRate > 0.0 ) {
    self.chartView.data = chartData;
//    }
    
    self.chartView.legend.enabled = NO;
//    self.chartView.legend.maxSizePercent = 1;//图例在饼状图中的大小占比, 这会影响图例的宽高
//    self.chartView.legend.formToTextSpace = 15;//文本间隔
//    self.chartView.legend.wordWrapEnabled = YES;
//    self.chartView.legend.font = [UIFont systemFontOfSize:12];//字体大小
//    self.chartView.legend.textColor = [UIColor grayColor];//字体颜色
//    self.chartView.legend.position = ChartLegendPositionBelowChartCenter;//图例在饼状图中的位置
//    self.chartView.legend.form = ChartLegendFormCircle;//图示样式: 方形、线条、圆形
//    self.chartView.legend.formSize = 6;//图示大小
    
    [self.chartView highlightValue:nil];
    
    [view addSubview:self.chartView];
    
    self.chartView.position = CGPointMake(view.width / 2 - self.chartView.width / 2, view2.bottom);

}

- (UIView *)headViewForTitle:(NSString *)text
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 40)];
    
    UIView *tag = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, view.height - 24)];
    [view addSubview:tag];
    tag.backgroundColor = MAIN_THEME_COLOR;
    
    UILabel *label = AWCreateLabel(CGRectMake(tag.right + 10, 0, view.width - 20 - tag.right,
                                              view.height), text,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(16, YES),
                                   AWColorFromRGB(51, 51, 51));
    [view addSubview:label];
    
    return view;
}


- (PieChartView *)chartView
{
    if ( !_chartView ) {
        _chartView = [[PieChartView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth() - 20,
                                                                    280)];
//        [self addSubview:_chartView];
        
        [_chartView setExtraOffsetsWithLeft:30 top:10 right:30 bottom:10];
        _chartView.usePercentValuesEnabled = NO;
        _chartView.dragDecelerationEnabled = NO;
        _chartView.drawSliceTextEnabled = YES;
        
        _chartView.delegate = self;
        
        _chartView.noDataText = @"无数据显示";
        
        _chartView.drawHoleEnabled = YES;//饼状图是否是空心
        _chartView.holeRadiusPercent = 0.5;//空心半径占比
        _chartView.holeColor = [UIColor clearColor];//空心颜色
        _chartView.transparentCircleRadiusPercent = 0.4;//半透明空心半径占比
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
        
//        _chartView.hidden = YES;
    }
    return _chartView;
}

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight
{
    NSLog(@"%@", entry.data);
    id item = entry.data;
    NSArray *units = @[@"套",@"万㎡",@"万元"];
//    NSString *unit = units[self.segControl2.selectedSegmentIndex];
//    id val = item[@"value"];
//    if ( self.segControl2.selectedSegmentIndex > 0 ) {
//        val = [NSString stringWithFormat:@"%.1f", [val floatValue] / 10000.0];
//    }
//    self.showResultLabel.text = [NSString stringWithFormat:@"%@ 成交%@%@", item[@"partname"], val ,unit];
}

- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView
{
//    self.showResultLabel.text = nil;
}

- (void)addShortcut
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop,
                                                            self.contentView.width,
                                                            120)];
    view.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:view];
    
    // total desc
    UILabel *totalLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(15, NO),
                                        AWColorFromRGB(58, 58, 58));
    [view addSubview:totalLabel];
    
    totalLabel.frame = CGRectMake(15, 0, 220, 50);
    
    UIImageView *arrowView = AWCreateImageView(@"icon_arrow-right.png");
    [view addSubview:arrowView];
    
    arrowView.position = CGPointMake(view.width - 8 - arrowView.width,
                                     totalLabel.midY - arrowView.height / 2 - 1);
    
    UILabel *label = AWCreateLabel(CGRectMake(0, 0, 70, 50),
                                   @"查看详情",
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(185, 185, 185));
    [view addSubview:label];
    label.center = CGPointMake(arrowView.left - label.width / 2,
                               totalLabel.midY);
    
    totalLabel.width = label.left - 15;
    
    totalLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *total = [@(self.flData.count) description];
//    NSString *earningRate = @"55%";
    NSString *string = [NSString stringWithFormat:@"累计跟投项目%@个", total];
    
    NSRange range = [string rangeOfString:total];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{
                                NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                                NSForegroundColorAttributeName: MAIN_THEME_COLOR
                                } range:range];
//    range = [string rangeOfString:earningRate];
//    [attrString addAttributes:@{
//                                NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
//                                NSForegroundColorAttributeName: MAIN_THEME_COLOR
//                                } range:range];
    totalLabel.attributedText = attrString;
    
    UIButton *btn = AWCreateImageButton(nil, self, @selector(viewAll));
    [view addSubview:btn];
    btn.frame = CGRectMake(0, 0, view.width, 50);
    
    // 水平线
    AWHairlineView *horLine = [AWHairlineView horizontalLineWithWidth:view.width
                                                                color:self.contentView.backgroundColor
                                                               inView:view];
    horLine.position = CGPointMake(0, totalLabel.bottom);
    
    // 垂直线
    AWHairlineView *verLine = [AWHairlineView verticalLineWithHeight:view.height - totalLabel.height
                                                               color:self.contentView.backgroundColor
                                                              inView:view];
    verLine.center = CGPointMake(view.width / 2, totalLabel.bottom + verLine.height / 2);
    
    // 已退本金
    // 未退本金
    NSArray *arr = @[@{
                         @"label": @"已退本金",
                         @"value": [@(self.totalCapMoney) description],
                         },
                     @{
                         @"label": @"未退本金",
                         @"value": [@(self.totalMoney - self.totalCapMoney) description],
                         },];
    
    for (int i=0; i<arr.count; i++) {
        id item = arr[i];
        UILabel *label = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(185, 185, 185));
        [view addSubview:label];
        
        label.numberOfLines = 2;
        
//        if (i != arr.count - 1) {
            NSString *money = [HNFormatMoney2(item[@"value"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
            NSString *string = [NSString stringWithFormat:@"%@元\n%@", money, item[@"label"]];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
            [attrString addAttributes:@{
                                        NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                        NSFontAttributeName: AWCustomFont(@"PingFang SC", 18)
                                        } range:[string rangeOfString:money]];
        [attrString addAttributes:@{
//                                    NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                    NSFontAttributeName: AWSystemFontWithSize(10, NO)
                                    } range:[string rangeOfString:@"元"]];
        
            label.attributedText = attrString;
//        } else {
//            NSString *string = [NSString stringWithFormat:@"%@%%\n%@", item[@"value"], item[@"label"]];
//            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
//            [attrString addAttributes:@{
//                                        NSForegroundColorAttributeName: MAIN_THEME_COLOR,
//                                        NSFontAttributeName: AWCustomFont(@"PingFang SC", 22)
//                                        } range:[string rangeOfString:item[@"value"]]];
//            label.attributedText = attrString;
//        }
        
        label.frame = CGRectMake(0, 0, view.width / 2, 70);
        
        int m = i % 2;
        int n = i / 2;
        label.position = CGPointMake(m * label.width, totalLabel.bottom + n * label.height);
        
    }

    // 按钮
    
//    CGFloat width = ( view.width - 45 ) / 2;
//    UIButton *btn1 = AWCreateTextButton(CGRectMake(0, 0, width, 40),
//                                        @"已结算项目",
//                                        label.textColor,
//                                        self,
//                                        @selector(btn1Clicked));
//    [view addSubview:btn1];
//    
////    btn1.titleLabel.font = AWSystemFontWithSize(14, NO);
//    
//    btn1.position = CGPointMake(15, ((view.height - totalLabel.height) / 2 - btn1.height / 2) + totalLabel.bottom );
//    
//    btn1.layer.borderColor = self.contentView.backgroundColor.CGColor;
//    btn1.layer.borderWidth = 0.8;
//    btn1.layer.cornerRadius = 4;
//    [btn1 clipsToBounds];
//    
//    UIButton *btn2 = AWCreateTextButton(CGRectMake(0,0,width, 40),
//                                        @"未结算项目",
//                                        label.textColor,
//                                        self,
//                                        @selector(btn2Clicked));
//    [view addSubview:btn2];
//    
////    btn2.titleLabel.font = AWSystemFontWithSize(14, NO);
//    
//    btn2.position = CGPointMake(btn1.right + 15, btn1.top);
//    
//    btn2.layer.borderColor = self.contentView.backgroundColor.CGColor;
//    btn2.layer.borderWidth = 0.8;
//    btn2.layer.cornerRadius = 4;
//    [btn2 clipsToBounds];
    
    self.currentTop = view.bottom + 10;
}

- (void)gotoProjectListForType:(NSInteger)integer
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"InvestProjectListVC"
                                                                params:@{ @"data": self.flData ?: @[] }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewAll
{
    // 查看所有项目
    [self gotoProjectListForType:-1];
}

- (void)btn1Clicked
{
    // 已结算
    [self gotoProjectListForType:1];
}

- (void)btn2Clicked
{
    // 未结算
    [self gotoProjectListForType:0];
}

- (void)addOtherSections
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 8,
                                                            self.contentView.width,
                                                            176)];
    view.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:view];
    
    // 水平线
    AWHairlineView *horLine = [AWHairlineView horizontalLineWithWidth:view.width
                                                                color:self.contentView.backgroundColor
                                                               inView:view];
    horLine.center = CGPointMake(view.width / 2, view.height / 2);
    // 竖直线
    
    AWHairlineView *verLine = [AWHairlineView verticalLineWithHeight:view.height
                                                               color:self.contentView.backgroundColor
                                                              inView:view];
    verLine.center = horLine.center;
    
    NSArray *arr = @[@{
                         @"label": @"已退本金",
                         @"value": @"10000",
                         },
                     @{
                         @"label": @"未退本金",
                         @"value": @"10000",
                         },
                     @{
                         @"label": @"待分红利",
                         @"value": @"3000",
                         },
                     @{
                         @"label": @"年化收益率",
                         @"value": @"0.002",
                         },
                     ];
    
    for (int i=0; i<arr.count; i++) {
        id item = arr[i];
        UILabel *label = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(185, 185, 185));
        [view addSubview:label];
        
        label.numberOfLines = 3;
        
        if (i != arr.count - 1) {
            NSString *money = [HNFormatMoney2(item[@"value"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
            NSString *string = [NSString stringWithFormat:@"%@元\n\n%@", money, item[@"label"]];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
            [attrString addAttributes:@{
                                        NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                        NSFontAttributeName: AWCustomFont(@"PingFang SC", 22)
                                        } range:[string rangeOfString:money]];
            label.attributedText = attrString;
        } else {
            NSString *string = [NSString stringWithFormat:@"%@%%\n\n%@", item[@"value"], item[@"label"]];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
            [attrString addAttributes:@{
                                        NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                        NSFontAttributeName: AWCustomFont(@"PingFang SC", 22)
                                        } range:[string rangeOfString:item[@"value"]]];
            label.attributedText = attrString;
        }
        
        label.frame = CGRectMake(0, 0, view.width / 2, 88);
        
        int m = i % 2;
        int n = i / 2;
        label.position = CGPointMake(m * label.width, n * label.height);
        
    }
}

- (void)addHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop, self.contentView.width,
                                                                128)];
    [self.scrollView addSubview:headView];
    headView.backgroundColor = MAIN_THEME_COLOR;
    
    // 本金
    UILabel *bjLabel = AWCreateLabel(CGRectMake(0, 0, headView.width / 2, 120),
                                     nil,
                                     NSTextAlignmentCenter,
                                     AWSystemFontWithSize(14, NO),
                                     [UIColor whiteColor]);
    [headView addSubview:bjLabel];
    bjLabel.numberOfLines = 3;
    
    bjLabel.center = CGPointMake(bjLabel.width / 2,
                                 headView.height / 2);
    
    NSString *money = [HNFormatMoney2(@(self.totalMoney), nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    NSString *string = [NSString stringWithFormat:@"跟投总金额\n\n%@元",money];
    
    [self setText:string forLabel: bjLabel moneyRange: [string rangeOfString:money]];
    
    
    // 收益
    UILabel *syLabel = AWCreateLabel(CGRectMake(0, 0, headView.width / 2, 120),
                                     nil,
                                     NSTextAlignmentCenter,
                                     AWSystemFontWithSize(14, NO),
                                     [UIColor whiteColor]);
    [headView addSubview:syLabel];
    syLabel.numberOfLines = 3;
    
    syLabel.center = CGPointMake(headView.width - syLabel.width / 2,
                                 headView.height / 2);
    
    money = [HNFormatMoney2(@(self.expectedEarning), nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    string = [NSString stringWithFormat:@"预期收益\n\n%@元",money];
    
    [self setText:string forLabel: syLabel moneyRange: [string rangeOfString:money]];
    
    // 垂直分隔线
    AWHairlineView *verticalLine = [AWHairlineView verticalLineWithHeight:28
                                                                    color:[UIColor whiteColor]
                                                                   inView:headView];
    verticalLine.center = CGPointMake(headView.width / 2, headView.height / 2);
    
    self.currentTop = headView.bottom;
}

- (void)setText:(NSString *)string forLabel:(UILabel *)label moneyRange:(NSRange)range2
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSRange range = [string rangeOfString:@"元"];
    
    [attrString addAttributes:@{
                                NSFontAttributeName: AWSystemFontWithSize(10, NO)
                                } range:range];
    
//    NSInteger loc = range.location;
//    range.location = 0;
//    range.length = loc - 1;
    
    
    [attrString addAttributes:@{
                                NSFontAttributeName: AWCustomFont(@"PingFang SC", 22)
                                } range:range2];
    
    label.attributedText = attrString;
}

@end

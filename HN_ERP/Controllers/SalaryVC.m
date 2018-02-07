//
//  SalaryVC.m
//  HN_ERP
//
//  Created by tomwey on 4/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SalaryVC.h"
#import "Defines.h"
#import "NTMonthYearPicker.h"
#import "MoneyView.h"

@interface SalaryVC () <UIScrollViewDelegate>//<UITableViewDataSource>

@property (nonatomic, strong) NTMonthYearPicker *datePicker;
//@property (nonatomic, strong) NSDateFormatter *dateFormatter;

//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentTop;

@property (nonatomic, weak) UIView *capView;

@property (nonatomic, assign) CGSize originalHeaderSize;

@property (nonatomic, strong) NSDictionary *salaryInfo;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger currentMonth;

@property (nonatomic, weak) UIButton *dateBtn;

@property (nonatomic, copy) NSString *errMsg;

@end

@implementation SalaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    self.currentDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                            value:-1
                                           toDate:[NSDate date] options:0];
    
//    NSString *title = [self yearMonthStringForDate:self.currentDate];
    
    __weak typeof(self) me = self;
    self.dateBtn = (UIButton *)[self addRightItemWithTitle:[[self.params[@"yearMonth"] stringByReplacingOccurrencesOfString:@"-" withString:@"年"] stringByAppendingString:@"月"]
                                           titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(14, NO) }
                                                      size:CGSizeMake(112, 34)
                                               rightMargin:12
                                                  callback:^{
                                                      [me openPicker];
                                                  }];
    
    self.dateBtn.userData = @{ @"name": [self.dateBtn currentTitle], @"value": self.params[@"yearMonth"] ?: @"" };
    
    UIImageView *triangle = AWCreateImageView(@"icon_triangle.png");
    [self.dateBtn addSubview:triangle];
    triangle.image = [[UIImage imageNamed:@"icon_triangle.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    triangle.tintColor = [UIColor whiteColor];
    triangle.position = CGPointMake(self.dateBtn.width - triangle.width - 2,
                                    self.dateBtn.height / 2 - triangle.height / 2 - 2);
    
    self.contentView.backgroundColor = AWColorFromRGB(242, 244, 247);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    // Do any additional setup after loading the view.
    
//    self.navBar.title = @"";
    
//    UILabel *coomingSoon = AWCreateLabel(CGRectZero,
//                                         @"敬请期待...",
//                                         NSTextAlignmentCenter, nil, [UIColor blackColor]);
//    [self.contentView addSubview:coomingSoon];
//    coomingSoon.frame = CGRectMake(0, 168, self.contentView.width, 40);
    
//    UIButton *btn = AWCreateTextButton(CGRectMake(0, 0, 66, 34),
//                                       @"2017年12月",
//                                       [UIColor whiteColor],
//                                       nil,
//                                       nil);
//    [self addRightItemWithTitle:@"2017年12月" size:CGSizeMake(88, 34)
//                       callback:^{
//                           
//                       }];
    
//    NSLog(@"%@", [[UserService sharedInstance] currentUser]);
    
    if ( self.params[@"data"] && [self.params[@"data"] count] > 0 ) {
        self.salaryInfo = self.params[@"data"];
        [self showContents];
    } else {
        [self loadData];
    }
}

- (NSString *)yearMonthStringForDate:(NSDate *)date
{
    NSInteger year = [self yearForDate:date];
    NSInteger month = [self monthForDate:date];
    
    return [NSString stringWithFormat:@"%@年%@月", @(year), @(month)];
}

- (NSInteger)yearForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar component:NSCalendarUnitYear fromDate:date];
}

- (NSInteger)monthForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar component:NSCalendarUnitMonth fromDate:date];
}

- (void)loadData
{
//    NSInteger year = [self yearForDate:self.currentDate];
//    NSInteger month = [self monthForDate:self.currentDate];
//    
//    if ( self.currentYear == year && self.currentMonth == month ) {
//        return;
//    }
//    
//    self.currentYear = year;
//    self.currentMonth = month;
//    
//    [self.dateBtn setTitle:[self yearMonthStringForDate:self.currentDate] forState:UIControlStateNormal];
    
    NSArray *partial = [[self.dateBtn userData][@"value"] componentsSeparatedByString:@"-"];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manid = [user[@"man_id"] ?: @"0" description];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:@"appgetwage" params:@{
                                 @"manid": manid,
                                 @"pwd": self.params[@"pwd"] ?: @"",
                                 @"year": [partial[0] description],
                                 @"month": [partial[1] description],
                                 @"istotal": @"0",
                                 @"isapp": @"1",
                                 } completion:^(id result, NSError *error) {
                                     [me handleResult:result error:error];
                                 }];
    
//    [self showContents];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        [self.contentView showHUDWithText:error.domain succeed:NO];
        if ([error.domain isEqualToString:@"NSCocoaErrorDomain"]) {
            self.errMsg = @"当月无工资数据";
        } else {
            self.errMsg = error.domain;
        }
        self.salaryInfo = nil;
    } else {
        if ( [result[@"code"] integerValue] != 0 ) {
//            [self.contentView showHUDWithText:result[@"codemsg"] succeed:NO];
            self.salaryInfo = nil;
            self.errMsg = result[@"codemsg"];
        } else {
            self.errMsg = nil;
            self.salaryInfo = result;
        }
    }
    
    [self showContents];
}

- (void)showContents
{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    // 工资汇总
    [self initTotalMoney];
    
    // 基本工资
    [self addBaseSalary];
    
    // 绩效
    [self addJXSalary];
    
    // 加班工资
    UIView *titleView = [self createTitleViewWithName:@"加班工资"
                                                money:[NSString stringWithFormat:@"%@ 元",
                                                       HNFormatMoney3(self.salaryInfo[@"jbxj"], nil)
                                                       ]
                                              hasLine:NO];
    [self.scrollView addSubview:titleView];
    titleView.top = self.currentTop + 10;
    self.currentTop = titleView.bottom;
    
    // 补贴
    [self addBTSalary];
    
    // 奖罚
    [self addJFSalary];
    
    // 社保公积金扣除
    [self addSBGJJSalary];
    
    // 所得税扣除
    [self addSDSSalary];
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width,
                                             self.currentTop + 10);
}

- (void)addBaseSalary
{
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 10,
                                                           self.contentView.width,
                                                           148)];
    [self.scrollView addSubview:box];
    box.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = box.bottom;
    
    // 标题
    UIView *titleView = [self createTitleViewWithName:@"基本工资"
                                                money:[NSString stringWithFormat:@"%@ 元", HNFormatMoney3(self.salaryInfo[@"gzxj"], @"元")]
                                              hasLine:YES];
    [box addSubview:titleView];
    
    // 工资
    NSArray *moneys = @[@{
                            @"label": @"固定工资",
                            @"value": HNFormatMoney3(self.salaryInfo[@"taxcost"], @"元"),
                            },
                        @{
                            @"label": @"补发工资",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m5"], @"元"),
                            },
                        @{
                            @"label": @"出勤工资",
                            @"value": HNFormatMoney3(self.salaryInfo[@"fixcost"], @"元"),
                            },
                        ];
    CGFloat width = box.width / moneys.count;
    for (int i=0; i<moneys.count; i++) {
        id item = moneys[i];
        UILabel *label = [self createLabel1:item[@"value"] label:item[@"label"] width:width];
        [box addSubview:label];
        
        label.position = CGPointMake(width * i, titleView.bottom + 15);
    }
    
    // 出勤
    float factor = [self.salaryInfo[@"m16"] floatValue] == 0.0 ? 0.00 :
        [self.salaryInfo[@"m17"] floatValue] / [self.salaryInfo[@"m16"] floatValue] * 100.0;
    NSArray *chuqin = @[
                        @{
                            @"label": @"应出勤",
                            @"value": [@([self.salaryInfo[@"m16"] floatValue]) description],
                            @"unit": @"天",
                            },
                        @{
                            @"label": @"实出勤",
                            @"value": [@([self.salaryInfo[@"m17"] floatValue]) description],
                            @"unit": @"天",
                            },
                        @{
                            @"label": @"出勤率",
                            @"value": factor < 100 ? [NSString stringWithFormat:@"%.2f", factor] : @"100",
                            @"unit": @"%",
                            }
                        ];
    
    width = box.width / chuqin.count;
    for (int i=0; i<chuqin.count; i++) {
        id item = chuqin[i];
        UILabel *label = [self createLabel2:item[@"value"]
                                      label:item[@"label"]
                                      width:width
                                       unit:item[@"unit"]];
        [box addSubview:label];
        
        label.position = CGPointMake(width * i, box.height - 5 - label.height);
    }
}

- (void)addJXSalary
{
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 10,
                                                           self.contentView.width,
                                                           90)];
    [self.scrollView addSubview:box];
    box.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = box.bottom;
    
    // 标题
    UIView *titleView = [self createTitleViewWithName:@"绩效"
                                                money:[NSString stringWithFormat:@"%@ 元",
                                                       HNFormatMoney3(self.salaryInfo[@"jxxj"], nil)
                                                       ]
                                              hasLine:YES];
    [box addSubview:titleView];
    
    // 工资
    NSArray *chuqin = @[
                        @{
                            @"label": @"绩效工资",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m3"], nil) ?: @"0.00",
                            @"unit": @"元",
                            },
                        @{
                            @"label": @"提成工资",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m8"], nil) ?: @"0.00",
                            @"unit": @"元",
                            },
                        ];
    
    CGFloat width = (box.width - 30) / chuqin.count;
    for (int i=0; i<chuqin.count; i++) {
        id item = chuqin[i];
        UILabel *label = [self createLabel2:item[@"value"]
                                      label:item[@"label"]
                                      width:width
                                       unit:item[@"unit"]];
        [box addSubview:label];
        
        label.position = CGPointMake(15 + width * i, titleView.bottom + 5);
        
        if (i == 0) {
            label.textAlignment = NSTextAlignmentLeft;
        } else if (i == chuqin.count - 1) {
            label.textAlignment = NSTextAlignmentRight;
        }
    }
}

- (void)addBTSalary
{
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 10,
                                                           self.contentView.width,
                                                           110)];
    [self.scrollView addSubview:box];
    box.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = box.bottom;
    
    // 标题
    UIView *titleView = [self createTitleViewWithName:@"补贴"
                                                money:[NSString stringWithFormat:@"%@ 元",
                                                       HNFormatMoney3(self.salaryInfo[@"btxj"], nil)
                                                       ]
                                              hasLine:YES];
    [box addSubview:titleView];
    
    // 工资
    NSArray *moneys = @[@{
                            @"label": @"交通通讯补贴",
                            @"value": HNFormatMoney3(self.salaryInfo[@"transportationallowances"], nil),
                            },
                        @{
                            @"label": @"工龄津贴",
                            @"value": HNFormatMoney3(self.salaryInfo[@"workageallowances"], nil),
                            },
                        @{
                            @"label": @"餐费",
                            @"value": HNFormatMoney3(self.salaryInfo[@"mealsupplement"], nil),
                            },
                        @{
                            @"label": @"其它补贴",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m10"], nil),
                            },
                        ];
    CGFloat width = box.width / moneys.count;
    for (int i=0; i<moneys.count; i++) {
        id item = moneys[i];
        UILabel *label = [self createLabel1:item[@"value"] label:item[@"label"] width:width];
        [box addSubview:label];
        
        label.position = CGPointMake(width * i, titleView.bottom + 12);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = - scrollView.contentOffset.y;
    if ( y > 0 ) {
//        CGFloat width = self.originalHeaderSize.width + y * 5 / 3;
        CGFloat height = self.originalHeaderSize.height;// + y;
        self.capView.frame =
        CGRectMake(0, scrollView.contentOffset.y, self.capView.width, height);
//        self.capView.center =
//        CGPointMake(self.contentView.center.x,
//                    self.capView.center.y );
    }
}

- (void)addJFSalary
{
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 10,
                                                           self.contentView.width,
                                                           110)];
    [self.scrollView addSubview:box];
    box.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = box.bottom;
    
    // 标题
    UIView *titleView = [self createTitleViewWithName:@"奖罚"
                                                money:[NSString stringWithFormat:@"%@ 元",
                                                       HNFormatMoney3(self.salaryInfo[@"jfxj"], nil)
                                                       ]
                                              hasLine:YES];
    [box addSubview:titleView];
    
    // 工资
    NSArray *moneys = @[@{
                            @"label": @"营销月奖罚",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m11"], nil),
                            },
                        @{
                            @"label": @"考勤扣款",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m12"], nil),
                            },
                        @{
                            @"label": @"流程时效处罚",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m13"], nil),
                            },
                        @{
                            @"label": @"运营月奖罚",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m14"], nil),
                            },
                        ];
    CGFloat width = box.width / moneys.count;
    for (int i=0; i<moneys.count; i++) {
        id item = moneys[i];
        UILabel *label = [self createLabel1:item[@"value"] label:item[@"label"] width:width];
        [box addSubview:label];
        
        label.position = CGPointMake(width * i, titleView.bottom + 12);
    }
}

- (void)addSBGJJSalary
{
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 10,
                                                           self.contentView.width,
                                                           90)];
    [self.scrollView addSubview:box];
    box.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = box.bottom;
    
    // 标题
    float total = [self.salaryInfo[@"gjjxj"] floatValue] + [self.salaryInfo[@"sbxj"] floatValue];
    UIView *titleView = [self createTitleViewWithName:@"社保公积金扣除"
                                                money:[NSString stringWithFormat:@"%@ 元",
                                                       HNFormatMoney3(@(total), nil)
                                                       ]
                                              hasLine:YES];
    [box addSubview:titleView];
    
    // 工资
    NSArray *chuqin = @[
                        @{
                            @"label": @"社保扣除",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m18"], nil),
                            @"unit": @"元",
                            },
                        @{
                            @"label": @"公积金扣除",
                            @"value": HNFormatMoney3(self.salaryInfo[@"m20"], nil),
                            @"unit": @"元",
                            },
                        ];
    
    CGFloat width = (box.width - 30) / chuqin.count;
    for (int i=0; i<chuqin.count; i++) {
        id item = chuqin[i];
        UILabel *label = [self createLabel2:item[@"value"]
                                      label:item[@"label"]
                                      width:width
                                       unit:item[@"unit"]];
        [box addSubview:label];
        
        label.position = CGPointMake(15 + width * i, titleView.bottom + 5);
        
        if (i == 0) {
            label.textAlignment = NSTextAlignmentLeft;
        } else if (i == chuqin.count - 1) {
            label.textAlignment = NSTextAlignmentRight;
        }
    }
}

- (void)addSDSSalary
{
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop + 10,
                                                           self.contentView.width,
                                                           90)];
    [self.scrollView addSubview:box];
    box.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = box.bottom;
    
    // 标题
    UIView *titleView = [self createTitleViewWithName:@"所得税扣除"
                                                money:[NSString stringWithFormat:@"%@ 元",
                                                       HNFormatMoney3(self.salaryInfo[@"persontax"], nil)]
                                              hasLine:YES];
    [box addSubview:titleView];
    
    // 工资
    NSArray *chuqin = @[
                        @{
                            @"label": @"起征点",
                            @"value": HNFormatMoney3(self.salaryInfo[@"starttaxpoint"], nil),
                            @"unit": @"元",
                            },
                        @{
                            @"label": @"个人所得税",
                            @"value": HNFormatMoney3(self.salaryInfo[@"persontax"], nil),
                            @"unit": @"元",
                            },
                        ];
    
    CGFloat width = (box.width - 30) / chuqin.count;
    for (int i=0; i<chuqin.count; i++) {
        id item = chuqin[i];
        UILabel *label = [self createLabel2:item[@"value"]
                                      label:item[@"label"]
                                      width:width
                                       unit:item[@"unit"]];
        [box addSubview:label];
        
        label.position = CGPointMake(15 + width * i, titleView.bottom + 5);
        
        if (i == 0) {
            label.textAlignment = NSTextAlignmentLeft;
        } else if (i == chuqin.count - 1) {
            label.textAlignment = NSTextAlignmentRight;
        }
    }
}

- (UILabel *)createLabel1:(NSString *)money label:(NSString *)name width:(CGFloat)width
{
    UILabel *label = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromHex(@"#999999"));
    
    label.numberOfLines = 2;
    label.frame = CGRectMake(0, 0, width, 44);
    
    label.adjustsFontSizeToFitWidth = YES;
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@", money, name];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:str];
    [attrText addAttributes:@{
                              NSFontAttributeName: AWCustomFont(@"PingFang SC", 16),
                              NSForegroundColorAttributeName: AWColorFromHex(@"#666666")
                              } range:[str rangeOfString:money]];
    
    label.attributedText = attrText;
    
    return label;
}

- (UILabel *)createLabel2:(NSString *)value
                    label:(NSString *)name
                    width:(CGFloat)width
                     unit:(NSString *)unit
{
    UILabel *label = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromHex(@"#999999"));
    
    label.frame = CGRectMake(0, 0, width, 40);
    
    label.adjustsFontSizeToFitWidth = YES;
    
    NSString *str = [NSString stringWithFormat:@"%@: %@%@", name, value, unit];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:str];
    [attrText addAttributes:@{
                              NSFontAttributeName: AWCustomFont(@"PingFang SC", 16),
                              NSForegroundColorAttributeName: AWColorFromHex(@"#666666")
                              } range:[str rangeOfString:value]];
    
    [attrText addAttributes:@{
                              NSFontAttributeName: AWSystemFontWithSize(10, NO),
                              } range:[str rangeOfString:unit]];
    
    
    label.attributedText = attrText;
    
    return label;
}

- (UIView *)createTitleViewWithName:(NSString *)name
                              money:(NSString *)money
                            hasLine:(BOOL)flag
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 44)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = AWCreateLabel(CGRectMake(15, 0, view.width - 30, view.height),
                                        name,
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(14, YES),
                                        AWColorFromHex(@"#666666"));
    [view addSubview:titleLabel];
    
    UILabel *moneyLabel = AWCreateLabel(titleLabel.frame,
                                        money,
                                        NSTextAlignmentRight,
                                        AWCustomFont(@"PingFang SC", 16),
                                        MAIN_THEME_COLOR);
    [view addSubview:moneyLabel];
    
    if (flag) {
        AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:view.width - 30
                                                                 color:AWColorFromHex(@"#e6e6e6")
                                                                inView:view];
        line.position = CGPointMake(15, view.height - line.height);
    }
    
    return view;
}

- (void)initTotalMoney
{
    UIView *capView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 168)];
    [self.scrollView addSubview:capView];
    capView.backgroundColor = MAIN_THEME_COLOR;
    
    self.originalHeaderSize = capView.frame.size;
    
    self.capView = capView;
    
    self.currentTop = capView.bottom;
    
    // 总金额
    UILabel *totalMoney = AWCreateLabel(CGRectMake(0, 0, capView.width, 40),
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWCustomFont(@"PingFang SC", 28),
                                        [UIColor whiteColor]);
    [capView addSubview:totalMoney];
    totalMoney.text = self.errMsg ?: HNFormatMoney3(self.salaryInfo[@"yourgot"], @"元");
    
    // 总金额文本
    UILabel *totalMoneyName = AWCreateLabel(CGRectMake(0, totalMoney.bottom,
                                                       capView.width,
                                                       30),
                                            @"税后总收入(元)",
                                            NSTextAlignmentCenter,
                                            AWSystemFontWithSize(14, NO),
                                            [UIColor whiteColor]);
    [capView addSubview:totalMoneyName];
    
    CGFloat width = (capView.width - 30) / 3.0;
    // 税前收入
    MoneyView *view1 = [[MoneyView alloc] init];
    [capView addSubview:view1];
    view1.frame = CGRectMake(15, totalMoneyName.bottom + 22, width, 64);
    [view1 setMoney:HNFormatMoney3(self.salaryInfo[@"btaxcosttotal"], @"元") forLabel:@"税前合计(元)"];
    
    // 扣除合计
    MoneyView *view2 = [[MoneyView alloc] init];
    [capView addSubview:view2];
    view2.frame = CGRectMake(view1.right, totalMoneyName.bottom + 22, width, 64);
    [view2 setMoney:HNFormatMoney3(self.salaryInfo[@"persondecsum"], @"元")
           forLabel:@"扣除合计(元)"];
    // 特殊补贴
    MoneyView *view3 = [[MoneyView alloc] init];
    [capView addSubview:view3];
    view3.frame = CGRectMake(view2.right, totalMoneyName.bottom + 22, width, 64);
    [view3 setMoney:HNFormatMoney3(self.salaryInfo[@"m22"], @"元") forLabel:@"特殊补贴(元)"];
}

- (void)openPicker
{
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = self.contentView.bounds;
    //            picker.backgroundColor = [UIColor redColor];
    
//    NSArray *names = [item[@"item_name"] componentsSeparatedByString:@","];
//    NSArray *values = [item[@"item_value"] componentsSeparatedByString:@","];
//    NSUInteger count = MIN(names.count, values.count);
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    NSArray *arr = self.params[@"yearMonths"];
    for (int i=0; i<[arr count]; i++) {
        id item = arr[i];
        id pair = @{ @"name": [NSString stringWithFormat:@"%@年%@月", item[@"fyear"], item[@"fmonth"]],
                     @"value": [NSString stringWithFormat:@"%@-%@", item[@"fyear"], item[@"fmonth"]]
                     };
        [temp addObject:pair];
    }
    
    picker.options = [temp copy];
    picker.currentSelectedOption = self.dateBtn.userData;
    [picker showPickerInView:self.contentView];
    
    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *sender, id selectedOption, NSInteger index) {
        NSString *name = selectedOption[@"name"];
        if ( [name isEqualToString:[me.dateBtn currentTitle]] == NO ) {
            [me.dateBtn setTitle:name forState:UIControlStateNormal];
            
            me.dateBtn.userData = selectedOption;
            
            [me loadData];
        }
    };
    
//    [self.contentView bringSubviewToFront:self.datePicker];
    
//    self.datePicker.superview.top = self.contentView.height;
//
//    [UIView animateWithDuration:.3 animations:^{
//        [self.contentView viewWithTag:1011].alpha = 0.6;
//        self.datePicker.superview.top = self.contentView.height - self.datePicker.superview.height;
//    }];
}

- (void)cancel
{
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView viewWithTag:1011].alpha = 0.0;
        self.datePicker.superview.top = self.contentView.height;
    }];
}

- (void)done
{
    [self cancel];
    
    self.currentDate = self.datePicker.date;
    
    [self loadData];
}

- (NTMonthYearPicker *)datePicker
{
    if ( !_datePicker ) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:maskView];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.0;
        maskView.tag = 1011;
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)]];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width,
                                                                     260)];
        [self.contentView addSubview:container];
        
        container.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.frame = CGRectMake(0, 0, container.width, 44);
        [container addSubview:toolbar];
        
        UIBarButtonItem *cancel =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                          target:self
                                                          action:@selector(cancel)];
        
        UIBarButtonItem *space =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        
        UIBarButtonItem *done =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
        
        
        toolbar.items = @[cancel, space, done];
        
        _datePicker = [[NTMonthYearPicker alloc] init];
        [container addSubview:_datePicker];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        _datePicker.frame = CGRectMake(0, toolbar.bottom,
                                       container.width,
                                       container.height - toolbar.height);
        _datePicker.maximumDate = self.currentDate;
        _datePicker.minimumDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                                       value:-1
                                                      toDate:self.currentDate
                                                     options:0];
        _datePicker.date = self.currentDate;
    }
    
    [self.contentView bringSubviewToFront:[self.contentView viewWithTag:1011]];
    [self.contentView bringSubviewToFront:_datePicker.superview];
    
    return _datePicker;
}

@end


@interface SalaryLoader ()

@property (nonatomic, copy) void (^loadCallback)(NSString *yearMonthStr, id salaryData, NSError *error, NSArray *yearMonths);

@end

@implementation SalaryLoader

+ (instancetype)sharedInstance
{
    static SalaryLoader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SalaryLoader alloc] init];
    });
    return instance;
}

- (void)startLoadingWithPassword:(NSString *)pwd
                            date:(NSDate *)date
                      completion:(void (^)(NSString *yearMonthStr, id data, NSError *error, NSArray *yearMonths))completion
{
    self.loadCallback = completion;
    
//    NSInteger year = [self yearForDate:date];
//    NSInteger month = [self monthForDate:date];
    
    [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
//    NSString *manid = [user[@"man_id"] ?: @"0" description];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"工资有效日期APP",
              @"param1": [user[@"area_id"] ?: @"0" description]
              } completion:^(id result, NSError *error) {
                  if ( error ) {
                      [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
                      
                      [AWAppWindow() showHUDWithText:@"服务器出错了" succeed:YES];
                  } else {
                      if ([result[@"rowcount"] integerValue] > 0) {
                          id item = [result[@"data"] firstObject];
                          
                          [me loadData:pwd year: item[@"fyear"] month:item[@"fmonth"] totalYearAndMonths:result[@"data"]];
                      } else {
                          [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
                          [AWAppWindow() showHUDWithText:@"未找到有效的工资日期" succeed:YES];
                      }
                  }
              }];
}

- (void)loadData:(NSString *)pwd year:(id)year month:(id)month totalYearAndMonths:(NSArray *)data
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manid = [user[@"man_id"] ?: @"0" description];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:@"appgetwage" params:@{
                                 @"manid": manid,
                                 @"pwd": pwd ?: @"",
                                 @"year": [year description],
                                 @"month": [month description],
                                 @"istotal": @"0",
                                 @"isapp": @"1",
                                 } completion:^(id result, NSError *error) {
                                     [me handleResult:result
                                                error:error
                                                 year:year
                                                month:month
                                   totalYearAndMonths:data];
                                 }];
}

- (void)handleResult:(id)result
               error:(NSError *)error
                year:(id)year
               month:(id)month
  totalYearAndMonths:(NSArray *)data
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
    
    NSString *errMsg = nil;
    id salaryData = nil;
    
    if ( error ) {
        //        [self.contentView showHUDWithText:error.domain succeed:NO];
        if ([error.domain isEqualToString:@"NSCocoaErrorDomain"]) {
            errMsg = @"当月无工资数据";
        } else {
            errMsg = error.domain;
        }
    } else {
        if ( [result[@"code"] integerValue] != 0 ) {
            //            [self.contentView showHUDWithText:result[@"codemsg"] succeed:NO];
            salaryData = nil;
            errMsg = result[@"codemsg"];
        } else {
            errMsg = nil;
            salaryData = result;
        }
    }
    
    NSError *err = nil;
    if ( errMsg ) {
        err = [NSError errorWithDomain:errMsg code:-1001 userInfo:nil];
    }
    
    if ( self.loadCallback ) {
        self.loadCallback([NSString stringWithFormat:@"%@-%@", year, month],salaryData, err, data);
    }
}

- (NSInteger)yearForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar component:NSCalendarUnitYear fromDate:date];
}

- (NSInteger)monthForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar component:NSCalendarUnitMonth fromDate:date];
}

@end

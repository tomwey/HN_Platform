//
//  InvestProjectDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 29/11/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "InvestProjectDetailVC.h"
#import "Defines.h"
#import "ValuesUtils.h"

@interface InvestProjectDetailVC ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentTop;

@property (nonatomic, strong) NSArray *bonusNodes;
@property (nonatomic, strong) NSError *bonusNodesError;

@property (nonatomic, strong) NSArray *capitalData;
@property (nonatomic, strong) NSError *capitalDataError;

@property (nonatomic, strong) NSArray *bonusData;
@property (nonatomic, strong) NSError *bonusDataError;

@property (nonatomic, assign) NSInteger loadDoneCounter;

@property (nonatomic, weak) UIButton *rightButton;

@end

@implementation InvestProjectDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", self.params);
    
    self.contentView.backgroundColor = AWColorFromRGB(242, 242, 242);
    
    self.navBar.title = self.params[@"projname"];
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
    
    [self addView1];
    
    [self addView2];
    
    [self loadData];
    
//    [self addView3];
    
//    [self addView4];
//    
//    [self addView5];
    
    [self loadNewsBadge];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNewsBadge)
                                                 name:@"kInvestNewsDidViewNotification"
                                               object:nil];
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width, self.currentTop);
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
              @"param1": [self.params[@"proj_id"] description],
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
                                                                params:@{ @"proj_id": self.params[@"proj_id"] }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    self.loadDoneCounter = 0;
    
    __weak typeof(self) me = self;
    [self sendRequestForFunname:@"跟投分红节点APP" completion:^(id result, NSError *error) {
        [me handleResult1:result error:error];
    }];
    
    [self sendRequestForFunname:@"本金返还列表APP" completion:^(id result, NSError *error) {
        [me handleResult2:result error:error];
    }];
    
    [self sendRequestForFunname:@"分红记录列表APP" completion:^(id result, NSError *error) {
        [me handleResult3:result error:error];
    }];
}

- (void)sendRequestForFunname:(NSString *)funname completion:(void (^)(id result, NSError *error))completion
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": funname,
              @"param1": [self.params[@"proj_id"] description],
              @"param2":  manID
              } completion:^(id result, NSError *error) {
                  if (completion) {
                      completion(result, error);
                  }
              }];
}

- (void)handleResult1:(id)result error:(NSError *)error
{
    if ( error ) {
        self.bonusNodesError = error;
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            self.bonusNodesError = [NSError errorWithDomain:@"分红节点数据为空" code:4004 userInfo:nil];
        } else {
            self.bonusNodes = result[@"data"];
        }
    }
    
    [self checkLoadDone];
    
    
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    if ( error ) {
        self.capitalDataError = error;
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            self.capitalDataError = [NSError errorWithDomain:@"本金返还数据为空" code:4004 userInfo:nil];
        } else {
            self.capitalData = result[@"data"];
        }
    }
    
    [self checkLoadDone];
}

- (void)handleResult3:(id)result error:(NSError *)error
{
    if ( error ) {
        self.bonusDataError = error;
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            self.bonusDataError = [NSError errorWithDomain:@"分红记录数据为空" code:4004 userInfo:nil];
        } else {
            self.bonusData = result[@"data"];
        }
    }
    
    [self checkLoadDone];
}

- (void)checkLoadDone
{
    self.loadDoneCounter++;
    if ( self.loadDoneCounter == 3 ) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        [self addView3];
        
        [self addView4];
        
        [self addView5];
        
        self.scrollView.contentSize = CGSizeMake(self.contentView.width, self.currentTop + 10);
    }
}

- (void)addView4
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop,
                                                            self.contentView.width,
                                                            210)];
    [self.scrollView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = view.bottom + 10;
    
    UIView *view2 = [self headViewForTitle:@"本金返还记录"];
    
    [view addSubview:view2];
    
    [self addContentsForView: view data: self.capitalData error:self.capitalDataError headView: view2];
    
}

- (void)addContentsForView: (UIView *)view
                      data: (NSArray *)data
                     error:(NSError *)error
                  headView: (UIView *)view2
{
    if ( data.count == 0 ) {
        UILabel *label = AWCreateLabel(CGRectMake(0, view2.bottom, view.width,
                                                  40),
                                       @"无数据显示",
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromHex(@"#999999"));
        [view addSubview:label];
        
        view.height = label.bottom  +10;
        
        self.currentTop = view.bottom + 10;
        
    } else {
        
        CGFloat total = 0;
        NSMutableArray *items = [NSMutableArray array];
        
        for (id item in data) {
            if ( [item[@"money"] floatValue] == 0.0 ) {
                continue;
            }
            
            total += [item[@"money"] floatValue];
            [items addObject:@{
                               @"time": data == self.capitalData ?
                                HNDateFromObject(item[@"refunddate"], @"T") :
                                   HNDateFromObject(item[@"realdate"], @"T"),
                               @"money": HNFormatMoney(item[@"money"], @"元")
                               }];
        }
        
        if (total == 0) {
            UILabel *label = AWCreateLabel(CGRectMake(0, view2.bottom, view.width,
                                                      40),
                                           @"无数据显示",
                                           NSTextAlignmentCenter,
                                           AWSystemFontWithSize(14, NO),
                                           AWColorFromHex(@"#999999"));
            [view addSubview:label];
            
            view.height = label.bottom  +10;
            
            self.currentTop = view.bottom + 10;
        } else {
            UILabel *label = AWCreateLabel(CGRectMake(view2.width - 300 - 10, 0, 300, 40),
                                           [HNFormatMoney(@(total), nil) stringByAppendingString:@""],
                                           NSTextAlignmentRight,
                                           AWSystemFontWithSize(16, NO),
                                           MAIN_THEME_COLOR);
            [view2 addSubview:label];
            
            [self addItems:items inView:view];
        }
        
    }
}

- (void)addItems:(NSArray *)data inView:(UIView *)view
{
    for (int i=0; i<data.count; i++) {
        AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:view.width
                                                                 color:AWColorFromHex(@"#dddddd")
                                                                inView:view];
        line.position = CGPointMake(0, 40 + 40 * i);
        
        id item = data[i];
        UILabel *label1 = AWCreateLabel(CGRectMake(10, 40 + 40 * i, view.width - 20,
                                                   40),
                                        item[@"time"],
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(15, NO),
                                        AWColorFromHex(@"#999999"));
        [view addSubview:label1];
        
        UILabel *label2 = AWCreateLabel(label1.frame,
                                        [NSString stringWithFormat:@"%@", item[@"money"]],
//                                        HNFormatMoney(item[@"money"], @"元"),
                                        NSTextAlignmentRight,
                                        AWSystemFontWithSize(15, NO),
                                        AWColorFromHex(@"#999999"));
        [view addSubview:label2];
        
        view.height = label1.bottom + 10;
    }
    
    self.currentTop = view.bottom + 10;
}

- (void)addView5
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop,
                                                            self.contentView.width,
                                                            210)];
    [self.scrollView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = view.bottom + 10;
    
    UIView *view2 = [self headViewForTitle:@"分红记录"];
    
    [view addSubview:view2];
    
    [self addContentsForView:view data:self.bonusData error: self.bonusDataError headView:view2];
}

- (void)addView3
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop,
                                                            self.contentView.width,
                                                            210)];
    [self.scrollView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = view.bottom + 10;
    
    UIView *view2 = [self headViewForTitle:@"计划-实际信息"];
    
    [view addSubview:view2];
    
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    
    [nodes addObject:@{
                       @"name": @"首次开盘",
                       @"plan_time": HNDateFromObject(self.params[@"firstopendateplan"], @"T"),
                       @"real_time": [HNDateFromObject(self.params[@"firstopendatereal"], @"T") stringByReplacingOccurrencesOfString:@"无" withString:@""],
                       @"desc": @"",
                       }];
    [nodes addObject:@{
                       @"name": @"本金返还",
                       @"plan_time": HNDateFromObject(self.params[@"cashbackdateplan"], @"T"),
                       @"real_time": [HNDateFromObject(self.params[@"cashbackdatereal"], @"T") stringByReplacingOccurrencesOfString:@"无" withString:@""],
                       @"desc": @"",
                       }];
    
    for (id item in self.bonusNodes) {
        [nodes addObject:@{
                           @"name": item[@"bonusnodename"] ?: @"--",
                           @"plan_time":HNDateFromObject(item[@"plandate"], @"T"),
                           @"real_time":[HNDateFromObject(item[@"realdate"], @"T") stringByReplacingOccurrencesOfString:@"无" withString:@""],
                           @"desc": HNStringFromObject(item[@"bonuscondition"], @"")
                           }];
    }
    
    UIView *itemContainer = [[UIView alloc] initWithFrame:CGRectMake(30, view2.bottom + 20,
                                                                     view.width - 60, 0)];
    [view addSubview:itemContainer];
    
    for (int i = 0; i<nodes.count; i++) {
        id item = nodes[i];
        
        BOOL comp = [item[@"real_time"] length] > 0;
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        dotView.cornerRadius = dotView.height / 2;
        [itemContainer addSubview:dotView];
        
        dotView.backgroundColor = comp ? AWColorFromHex(@"#54ae3b") : AWColorFromHex(@"#999999");
        
        UILabel *label = AWCreateLabel(CGRectZero, nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(15, NO),
                                       AWColorFromRGB(51, 51, 51));
        [itemContainer addSubview:label];
        
        label.numberOfLines = 3;
        
        NSMutableString *muString = [[NSMutableString alloc] init];
        [muString appendFormat:@"计划%@日期: %@", item[@"name"], item[@"plan_time"]];
        if ([[item[@"real_time"] description] length] > 0) {
            [muString appendFormat:@"\n实际%@日期: %@", item[@"name"], item[@"real_time"]];
        }
        
        if ([[item[@"desc"] description] length] > 0) {
             [muString appendFormat:@"\n(%@)", item[@"desc"]];
        }
        
        label.text = muString;
        
        label.frame = CGRectMake(dotView.right + 20, i * (60 + 20), itemContainer.width - dotView.right - 20,
                                 60);
        
        dotView.position = CGPointMake(0, label.midY - dotView.height / 2);
        
        itemContainer.height = label.bottom;
    }
    
    AWHairlineView *verLine = [AWHairlineView verticalLineWithHeight:itemContainer.height + 30
                                                               color:AWColorFromHex(@"#dddddd")
                                                              inView:view];
    verLine.position = CGPointMake(itemContainer.left + 6, view2.bottom + 10);
    
    [view bringSubviewToFront:itemContainer];
    
    NSString *getinPlan = HNStringFromObject(self.params[@"getinrateplan"], @"");
    if (getinPlan.length == 0) {
        getinPlan = @"--";
    } else {
        getinPlan = [HNFormatMoney(self.params[@"getinrateplan"], @"元") stringByReplacingOccurrencesOfString:@"元" withString:@""];
    }
    
    NSString *getinReal = HNStringFromObject(self.params[@"getinratereal"], @"");
    if (getinReal.length == 0) {
        getinReal = @"--";
    } else {
        getinReal = [HNFormatMoney(self.params[@"getinratereal"], @"元") stringByReplacingOccurrencesOfString:@"元" withString:@""];
    }
    
    NSString *yearPlan = HNStringFromObject(self.params[@"yearrateplan"], @"");
    if (yearPlan.length == 0) {
        yearPlan = @"--";
    } else {
        yearPlan = [HNFormatMoney(self.params[@"yearrateplan"], @"元") stringByReplacingOccurrencesOfString:@"元" withString:@""];
    }
    
    NSString *yearReal = HNStringFromObject(self.params[@"yearratereal"], @"");
    if (yearReal.length == 0) {
        yearReal = @"--";
    } else {
        yearReal = [HNFormatMoney(self.params[@"yearratereal"], @"元") stringByReplacingOccurrencesOfString:@"元" withString:@""];
    }
    
    UIView *v1 = [self compareViewForLabel:@"实得利润率"
                                      plan:[NSString stringWithFormat:@"%@%@", getinPlan,
                                            [getinPlan isEqualToString:@"--"] ? @"" : @"%"]
                                      real:[NSString stringWithFormat:@"%@%@", getinReal,
                                            [getinReal isEqualToString:@"--"] ? @"" : @"%"]];
    [view addSubview:v1];
    
    v1.top = verLine.bottom + 10;
    
    NSString *u1 =
    [yearPlan isEqualToString:@"--"] ? @"" : @"%";
    NSString *u2 =
    [yearReal isEqualToString:@"--"] ? @"" : @"%";
    UIView *v2 = [self compareViewForLabel:@"年化收益率"
                                      plan:[NSString stringWithFormat:@"%@%@", yearPlan,u1]
                                      real:[NSString stringWithFormat:@"%@%@", yearReal,u2]];
    [view addSubview:v2];
    
    v2.top = v1.bottom + 10;
    
    view.height = v2.bottom + 10;
    self.currentTop = view.bottom + 10;
}

- (UIView *)compareViewForLabel:(NSString *)label
                           plan:(NSString *)plan
                           real:(NSString *)real
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.contentView.width - 40,
                                                            60)];
    
    UILabel *label1 = AWCreateLabel(CGRectMake(0, 0,
                                               80, view.height),
                                    label,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(51, 51, 51));
    
    [view addSubview:label1];
    
    UILabel *value1_1 = AWCreateLabel(CGRectMake(label1.right + 10,
                                                 0,
                                                 80,
                                                 view.height),
                                      nil,
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(15, NO),
                                      label1.textColor);
    value1_1.numberOfLines = 2;
    [view addSubview:value1_1];
    
    NSString *string = [NSString stringWithFormat:@"%@\n计划", plan];
    NSRange range = [string rangeOfString:@"\n"];
    NSInteger length = range.location;
    range.location = 0;
    range.length = length;
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName: MAIN_THEME_COLOR,
//                                NSFontAttributeName: AWSystemFontWithSize(18, NO),
                                } range:range];
    value1_1.attributedText = attrString;
    
    UILabel *value1_2 = AWCreateLabel(CGRectMake(value1_1.right + 10,
                                                 0,
                                                 80,
                                                 view.height),
                                      nil,
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(15, NO),
                                      label1.textColor);
    value1_2.numberOfLines = 2;
    [view addSubview:value1_2];
    
    string = [NSString stringWithFormat:@"%@\n实际", real];
    range = [string rangeOfString:@"\n"];
    length = range.location;
    range.location = 0;
    range.length = length;
    
    attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName: MAIN_THEME_COLOR,
//                                NSFontAttributeName: AWSystemFontWithSize(18, NO),
                                } range:range];
    value1_2.attributedText = attrString;
    
    return view;
}

- (UIView *)headViewForTitle:(NSString *)text
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 40)];
    
    UIView *tag = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, view.height - 20)];
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

- (void)addView2
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentTop,
                                                            self.contentView.width,
                                                            210)];
    [self.scrollView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = view.bottom + 10;
    
    // 跟投本金
    UILabel *label = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromHex(@"#999999"));
    [view addSubview:label];
    label.frame = CGRectMake(0, 10, view.width, 70);
    
    NSString *money = [HNFormatMoney2(self.params[@"money"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    NSString *str = [NSString stringWithFormat:@"%@元\n项目跟投本金", money];
    
    NSRange range = [str rangeOfString:money];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    [string addAttributes:@{
                            NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                            NSFontAttributeName: AWSystemFontWithSize(18, NO),
                            } range:range];
    
    label.numberOfLines = 2;
    label.attributedText = string;
    
    NSString *prefix = @"计划";
    NSString *rate1 = [@([self.params[@"getinrateplan"] floatValue]) description];
    NSString *rate2 = [@([self.params[@"yearrateplan"] floatValue]) description];
    if ( [self.params[@"clearstate"] boolValue] ) {
        prefix = @"实际";
        rate1 = [@([self.params[@"getinratereal"] floatValue]) description];
        rate2 = [@([self.params[@"yearratereal"] floatValue]) description];
    }
    
    rate1 = [HNFormatMoney(rate1, nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    rate2 = [HNFormatMoney(rate2, nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    
    // 其它指标
    NSArray *array = @[
                       @{
                           @"name": @"本金进入日期",
                           @"value": HNDateFromObject(self.params[@"capitalenterdate"], @"T"),
                           @"unit": @"",
                           },
                       @{
                           @"name": @"本金额度占比",
                           @"value": [HNFormatMoney(self.params[@"rate"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""],
                           @"unit": @"%",
                           },
                       @{
                           @"name": @"已退本金",
                           @"value": [HNFormatMoney2(self.params[@"capitalmoney"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""],
                           @"unit": @"元",
                           },
                       @{
                           @"name": @"累计实际收益",
                           @"value": [HNFormatMoney2(self.params[@"bonusmoney"], nil) stringByReplacingOccurrencesOfString:@"元" withString:@""],
                           @"unit": @"元",
                           },
                       @{
                           @"name": [prefix stringByAppendingString:@"实得利润率"],
                           @"value": rate1 ?: @"--",
                           @"unit": @"%",
                           },
                       @{
                           @"name": [prefix stringByAppendingString:@"年化收益率"],
                           @"value": rate2 ?: @"--",
                           @"unit": @"%",
                           },
                       ];
    for (int i=0; i<array.count; i++) {
        UILabel *otherLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                            AWColorFromHex(@"#999999"));
        [view addSubview:otherLabel];
        otherLabel.numberOfLines = 2;
        
        id item = array[i];
        
        NSString *val = [NSString stringWithFormat:@"%@%@\n%@", item[@"value"],
                         item[@"unit"], item[@"name"]];
        NSRange range = [val rangeOfString:item[@"value"]];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:val];
        [string addAttributes:@{
                                NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                NSFontAttributeName: AWSystemFontWithSize(18, NO),
                                } range:range];
        
        otherLabel.attributedText = string;
        
        int m = i % 3;
        int n = i / 3;
        
        otherLabel.frame = CGRectMake(0, 0, view.width / 3.0, 60);
        otherLabel.position = CGPointMake(m * otherLabel.width,
                                          label.bottom + otherLabel.height * n);
    }
}

- (void)addView1
{
    UILabel *stateLabel = AWCreateLabel(CGRectZero,
                                        [self.params[@"clearstate"] boolValue] ? @"已结算" : @"未结算",
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(12, NO),
                                        [UIColor whiteColor]);
    [self.scrollView addSubview:stateLabel];
    
    stateLabel.backgroundColor = [self.params[@"clearstate"] boolValue] ? AWColorFromHex(@"#54ae3b") :MAIN_THEME_COLOR;
    [stateLabel sizeToFit];
    
    stateLabel.width += 6;
    stateLabel.height += 4;
    
    stateLabel.cornerRadius = 2;
    
    stateLabel.position = CGPointMake(15, 15);
    
    UILabel *gtLabel = AWCreateLabel(CGRectZero,
                                     nil,
                                     NSTextAlignmentRight,
                                     AWSystemFontWithSize(15, NO),
                                     AWColorFromRGB(51, 51, 51));
    [self.scrollView addSubview:gtLabel];
    
    gtLabel.frame = CGRectMake(0, 0, self.contentView.width - 80, 34);
    gtLabel.position = CGPointMake(self.contentView.width - 15 - gtLabel.width,
                                   10);
    
    NSString *days = [@(HNIntegerFromObject(self.params[@"investdays"], 0)) description];
    NSString *str = [NSString stringWithFormat:@"已跟投%@天", days];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString: str];
    [string addAttributes:@{
                            NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                            NSFontAttributeName: AWSystemFontWithSize(18, YES),
                            } range:[str rangeOfString:days]];
    gtLabel.attributedText = string;
    
    self.currentTop = gtLabel.bottom + 10;
}

@end

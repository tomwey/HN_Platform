//
//  OutputConfirmVC.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputConfirmVC.h"
#import "Defines.h"

@interface OutputConfirmVC ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentBottom;

@property (nonatomic, strong) id roomData;
@property (nonatomic, strong) NSError *roomError;

@property (nonatomic, strong) id approvingData;
@property (nonatomic, strong) NSError *approvingError;

@property (nonatomic, assign) NSInteger counter;

@property (nonatomic, weak) UILabel *totalApprovingLabel;
@property (nonatomic, weak) UIButton *commitBtn;

@end

@implementation OutputConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"产值确认";
    
    // 添加一个返回按钮，返回到最开始的流程详情
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
    [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.height -= 44;
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // 添加底部提交申报按钮
    [self initCommitButton];
    
    // 项目
    UILabel *label1 = AWCreateLabel(CGRectMake(15, 15, self.contentView.width - 30,
                                               30),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, YES),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label1];
    
    label1.text = [NSString stringWithFormat:@"%@%@", [self.params[@"area"] areaName],
                   [self.params[@"project"] projectName]];
    
    // 合同
    UILabel *label2 = AWCreateLabel(CGRectMake(15, label1.bottom + 5,
                                               self.contentView.width - 30,
                                               50),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label2];
    label2.numberOfLines = 2;
    label2.adjustsFontSizeToFitWidth = YES;
    
    label2.text = self.params[@"item"][@"contractname"];
    
    UIColor *textColor = AWColorFromRGB(74, 74, 74);
    // 产值
    UILabel *planLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       textColor);
    [self.scrollView addSubview:planLabel];
    
    NSString *planMoney = [NSString stringWithFormat:@"%@\n本月计划产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthplan"], @"万")];
    planLabel.numberOfLines = 2;
    
    NSRange range1 = [planMoney rangeOfString:@"万"];
//    range.length = range.location;
//    range.location = 0;
    NSRange range2 = NSMakeRange(0, range1.location);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:planMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(12, NO)}
                    range:range1];
    
    planLabel.attributedText = string;
    [planLabel sizeToFit];
    
    planLabel.position = CGPointMake(15, label2.bottom + 10);
    
    // 实际产值
    UILabel *realLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       textColor);
    [self.scrollView addSubview:realLabel];
    NSString *realMoney = [NSString stringWithFormat:@"%@\n本月实际产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthfact"], @"万")];
    realLabel.numberOfLines = 2;
    
    range1 = [realMoney rangeOfString:@"万"];
    range2 = NSMakeRange(0, range1.location);
    
    string = [[NSMutableAttributedString alloc] initWithString:realMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(12, NO)}
                    range:range1];
    
    realLabel.attributedText = string;
    [realLabel sizeToFit];
    
    realLabel.center = CGPointMake(self.contentView.width / 2.0, planLabel.midY);
    
    // 本月应付产值
    UILabel *totalLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       textColor);
    
    [self.scrollView addSubview:totalLabel];
    
    NSString *totalMoney = [NSString stringWithFormat:@"%@\n本月应付产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthpayable"], @"万")];
    totalLabel.numberOfLines = 2;
    
    range1 = [totalMoney rangeOfString:@"万"];
    range2 = NSMakeRange(0, range1.location);
    
    string = [[NSMutableAttributedString alloc] initWithString:totalMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(12, NO)}
                    range:range1];
    
    totalLabel.attributedText = string;
    [totalLabel sizeToFit];
    
    totalLabel.center = CGPointMake(self.contentView.width - 15 - totalLabel.width / 2.0, planLabel.midY);
    
    // 累计实际产值
    UILabel *totalRealLabel = AWCreateLabel(CGRectZero,
                                            nil,
                                            NSTextAlignmentLeft,
                                            AWSystemFontWithSize(12, NO),
                                            textColor);
    [self.scrollView addSubview:totalRealLabel];
    totalRealLabel.frame = CGRectMake(15, totalLabel.bottom + 5,
                                      (self.contentView.width - 35) / 2.0, 30);
    
    totalRealLabel.adjustsFontSizeToFitWidth = YES;

    AWLabelFormatShow(totalRealLabel,
                      @"累计实际产值",
                      [HNFormatMoney(self.params[@"item"][@"contractfactoutvalue"], @"万")
                       stringByReplacingOccurrencesOfString:@"万" withString:@""],
                      @"万",
                      AWCustomFont(@"PingFang SC", 18),
                      MAIN_THEME_COLOR,
                      YES);
    // 累计应付产值
    UILabel *totalYFLabel = AWCreateLabel(CGRectZero,
                                            nil,
                                            NSTextAlignmentRight,
                                            AWSystemFontWithSize(12, NO),
                                            textColor);
    [self.scrollView addSubview:totalYFLabel];
    totalYFLabel.frame = totalRealLabel.frame;
    totalYFLabel.left  = totalRealLabel.right + 5;
    
    totalYFLabel.adjustsFontSizeToFitWidth = YES;
    
    AWLabelFormatShow(totalYFLabel,
                      @"累计应付产值",
                      [HNFormatMoney(self.params[@"item"][@"contractpayableoutvalue"], @"万")
                       stringByReplacingOccurrencesOfString:@"万" withString:@""],
                      @"万",
                      AWCustomFont(@"PingFang SC", 18),
                      MAIN_THEME_COLOR,
                      YES);
    
    // 水平线
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:self.scrollView];
    line.position = CGPointMake(0, totalYFLabel.bottom + 30);
    
    self.currentBottom = line.bottom + 30;
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kOutputDidConfirmNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kOutputDeclareDidCommitNotification"
                                               object:nil];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"产值确认"
                                    keyMemo:nil];
}

- (void)initCommitButton
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height - 44, self.contentView.width, 44)];
    [self.contentView addSubview:view];
    
    view.backgroundColor = [UIColor whiteColor];
    
    // 线
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:view.width
                                                             color:AWColorFromHex(@"#e6e6e6")
                                                            inView:view];
    line.position = CGPointZero;
    
    // 申报总数
    UILabel *label = AWCreateLabel(CGRectMake(15, 0, view.width - 15 - 5 - 120,
                                              view.height),
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(74, 74, 74));
    [view addSubview:label];
    
    self.totalApprovingLabel = label;
    
    label.adjustsFontSizeToFitWidth = YES;
    
    // 提交按钮
    UIButton *btn = AWCreateTextButton(CGRectMake(view.width - 120, 0, 120, 44),
                                       @"提交申报",
                                       [UIColor whiteColor],
                                       self,
                                       @selector(prepareCommit));
    btn.backgroundColor = MAIN_THEME_COLOR;
    [view addSubview:btn];
    
    self.commitBtn = btn;
    
    btn.titleLabel.font = AWSystemFontWithSize(15, NO);
    
    [self updateApprovingCount:0];
}

- (void)prepareCommit
{
    NSDictionary *params = @{
                             @"isNew": @"0",
                             @"contractid":[self.params[@"item"][@"contractid"] description] ?: @"",
                             @"data": self.approvingData[@"data"] ?: @[],
                             @"item": self.params[@"item"] ?: @{},
                             @"area": self.params[@"area"] ?: @{},
                             @"project": self.params[@"project"] ?: @{},
                             @"needShowCloseBtn": @"0",
                             };
    
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"OutputDeclareListVC"
                                                                params:params];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)updateApprovingCount:(NSInteger)count
{
    NSString *total = [@(count) description];
    
    NSString *string = [NSString stringWithFormat:@"共 %@ 项可以申报", total];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrText addAttributes:@{
                              NSFontAttributeName: AWCustomFont(@"PingFang SC", 16),
                              NSForegroundColorAttributeName: MAIN_THEME_COLOR
                              } range:[string rangeOfString:total]];
    
    self.totalApprovingLabel.attributedText = attrText;
    
    self.commitBtn.userInteractionEnabled = count > 0;
    self.commitBtn.backgroundColor = count > 0 ? MAIN_THEME_COLOR : AWColorFromHex(@"#bbbbbb");
}

- (void)backToPage
{
    NSArray *controllers = [self.navigationController viewControllers];
    if ( controllers.count > 1 ) {
        [self.navigationController popToViewController:controllers[1] animated:YES];
    }
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同楼栋APP",
              @"param1": [self.params[@"item"][@"contractid"] description] ?: @""
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"产值确认获取待申报列表APP",
                       @"param1": [self.params[@"item"][@"contractid"] description] ?: @""
                       } completion:^(id result, NSError *error) {
                           [me handleResult2:result error:error];
                       }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    self.approvingData = result;
    self.approvingError = error;
    
    [self loadDone];
}

- (void)handleResult:(id)result error:(NSError *)error
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    NSLog(@"result: %")
//    if ( error ) {
//        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
//    } else {
//        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.contentView showHUDWithText:@"楼栋数据为空" offset:CGPointMake(0,20)];
//        } else {
//            [self showRoom:result[@"data"]];
//        }
//    }
    
    self.roomData = result;
    self.roomError = error;
    
    [self loadDone];
}

- (void)loadDone
{
    if ( ++self.counter == 2 ) {
        
        self.counter = 0;
        
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        // 显示楼栋
        if ( self.roomError ) {
            [self.contentView showHUDWithText:self.roomError.localizedDescription succeed:NO];
        } else {
            if ( [self.roomData[@"rowcount"] integerValue] == 0 ) {
                [self.contentView showHUDWithText:@"楼栋数据为空" offset:CGPointMake(0,20)];
            } else {
                [self showRoom:self.roomData[@"data"]];
            }
        }
        
        // 显示待申报列表
        [self showApprovingContent];
    }
}

- (void)showApprovingContent
{
    if ( self.approvingData && self.approvingData[@"rowcount"] ) {
        [self updateApprovingCount:[self.approvingData[@"rowcount"] integerValue]];
    }
}

- (void)showRoom:(NSArray *)data
{
    NSInteger cols = self.contentView.width > 320 ? 3 : 2;
    
    CGFloat width = (self.contentView.width - 15 * ( cols + 1 )) / cols;
    
    CGFloat bottom = 0;
    for (int i=0; i<data.count; i++) {
        
        UIButton *btn = AWCreateImageButton(nil, self, @selector(btnClicked:));
        [self.scrollView addSubview:btn];
        
        btn.cornerRadius = 12;
        
        btn.frame = CGRectMake(0, 0, width, width * 0.682);
        
        int dtx = i % cols;
        int dty = i / cols;
        
        btn.position = CGPointMake(15 + dtx * ( width + 15 ),
                                   self.currentBottom + ( width * 0.682 + 15 ) * dty);
        
        id item = data[i];
        
        UILabel *label = AWCreateLabel(CGRectInset(btn.bounds, 10, 0),
                                       [NSString stringWithFormat:@"%@\n(%d)",
                                        [item[@"building_name"] description], HNIntegerFromObject(item[@"roomnodenum"], 0)],
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(16, NO),
                                       AWColorFromRGB(74, 74, 74));
        [btn addSubview:label];
        label.numberOfLines = 3;
        label.adjustsFontSizeToFitWidth = YES;
        
        btn.userData = item;
        
        btn.backgroundColor = AWColorFromRGB(241, 241, 241);
        
        bottom = btn.bottom + 15;
        
    }
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width,
                                             bottom);
}

- (void)btnClicked:(UIButton *)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputJDConfirmVC"
                                                                params:@{
                                                                         @"area": self.params[@"area"],
                                                                         @"project": self.params[@"project"],
                                                                         @"item": self.params[@"item"],
                                                                         @"building": sender.userData,
                                                                         }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

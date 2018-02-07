//
//  OutputJDConfirmVC.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputJDConfirmVC.h"
#import "Defines.h"
#import "NTMonthYearPicker.h"

@interface OutputJDConfirmVC ()

@property (nonatomic, strong) UIView *scrollView;

@property (nonatomic, assign) CGFloat currentBottom;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NTMonthYearPicker *datePicker;

@property (nonatomic, weak) UIButton *dateButton;

@property (nonatomic, weak) UILabel *planLabel;
@property (nonatomic, weak) UILabel *realLabel;
@property (nonatomic, weak) UILabel *totalLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSArray *uncompletedNodes;
@property (nonatomic, strong) NSArray *completedNodes;
@property (nonatomic, strong) NSArray *approvingNodes;
//@property (nonatomic, strong) NSArray *approvingNodes2; // 申报中

@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation OutputJDConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"进度确认";
    
    // 添加一个返回按钮，返回到最开始的流程详情
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
    [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.currentDate = [NSDate date];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy年M月";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kOutputDidConfirmNotification"
                                               object:nil];
    
    [self loadData];
}

- (void)openDatePicker
{
    self.datePicker.superview.top = self.contentView.height;
    
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView viewWithTag:1011].alpha = 0.6;
        self.datePicker.superview.top = self.contentView.height - self.datePicker.superview.height;
    }];
}

- (void)cancel
{
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView viewWithTag:1011].alpha = 0.0;
        self.datePicker.superview.top = self.contentView.height;
    }];
}

- (void)backToPage
{
    NSArray *controllers = [self.navigationController viewControllers];
    if ( controllers.count > 1 ) {
        [self.navigationController popToViewController:controllers[1] animated:YES];
    }
}

- (void)done
{
    [self cancel];
    
    self.currentDate = self.datePicker.date;
    
    [self.dateButton setTitle:[[self.dateFormatter stringFromDate:self.currentDate]
                               stringByAppendingString:@"▾"] forState:UIControlStateNormal];
    
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
        
        [NSCalendar currentCalendar];
        
        _datePicker.frame = CGRectMake(0, toolbar.bottom,
                                       container.width,
                                       container.height - toolbar.height);
        _datePicker.maximumDate = [NSDate date];
//        _datePicker.minimumDate =
        _datePicker.date = [NSDate date];
    }
    
    [self.contentView bringSubviewToFront:[self.contentView viewWithTag:1011]];
    [self.contentView bringSubviewToFront:_datePicker.superview];
    
    return _datePicker;
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                       fromDate:self.currentDate];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询楼栋产值APP",
              @"param1": [self.params[@"item"][@"contractid"] description] ?: @"",
              @"param2": [self.params[@"building"][@"building_id"] description] ?: @"",
              @"param3": [@(dc.year) description],
              @"param4": [@(dc.month) description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    NSLog(@"result: %")
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"楼栋数据为空" offset:CGPointMake(0,20)];
        } else {
//            [self showRoom:result[@"data"]];
            [self showContent:result[@"data"]];
        }
    }
}

- (void)showContent:(id)data
{
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    
    if ( !self.scrollView ) {
        self.scrollView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.scrollView];
    }
    
    // 项目
    UILabel *label1 = AWCreateLabel(CGRectMake(15, 15, self.contentView.width - 30,
                                               30),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, YES),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label1];
    
    label1.text = [NSString stringWithFormat:@"%@%@：%@", [self.params[@"area"] areaName],
                   [self.params[@"project"] projectName], self.params[@"building"][@"building_name"]];
    
    UIButton *dateBtn = AWCreateTextButton(CGRectMake(0, 0, 90,34),
                                           [[self.dateFormatter stringFromDate:self.currentDate] stringByAppendingString:@"▾"],
                                           AWColorFromRGB(74, 74, 74),
                                           self,
                                           @selector(openDatePicker));
    [self.scrollView addSubview:dateBtn];
    
    self.dateButton = dateBtn;
    
    dateBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
    
    //    [dateBtn setImage:[UIImage imageNamed:@"icon_caret.png"] forState:UIControlStateNormal];
    //    [dateBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    
    label1.width -= 95;
    
    dateBtn.center = CGPointMake(self.contentView.width - 15 - dateBtn.width / 2, label1.midY);
    
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
    
    id item = [data firstObject];
    
    UIColor *textColor = AWColorFromRGB(74, 74, 74);
    // 产值
    UILabel *planLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       textColor);
    [self.scrollView addSubview:planLabel];
    
    self.planLabel = planLabel;
    
    NSString *planMoney = [NSString stringWithFormat:@"%@\n本月计划产值",
                           HNFormatMoney(item[@"curmonthplan"], @"万")];
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
    
    realLabel.numberOfLines = 2;
    
    NSString *realMoney = [NSString stringWithFormat:@"%@\n本月实际产值",
                           HNFormatMoney(item[@"curmonthfact"], @"万")];
    
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
    
    // 截止本月产值
    UILabel *totalLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(12, NO),
                                        textColor);
    
    [self.scrollView addSubview:totalLabel];
    
    NSString *totalMoney = [NSString stringWithFormat:@"%@\n本月应付产值",
                            HNFormatMoney(item[@"curmonthpayable"], @"万")];
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
    line.position = CGPointMake(0, totalRealLabel.bottom + 20);
    
    self.currentBottom = line.bottom + 20;
    
    // 加一个切换功能
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"未确认", @"待申报", @"已申报"]];
    [self.scrollView addSubview:control];
    control.frame = CGRectMake(0, 0, self.scrollView.width * 0.7, 34);
    control.center = CGPointMake(self.scrollView.width / 2, self.currentBottom + control.height / 2);
    control.tintColor = MAIN_THEME_COLOR;
    [control addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    control.selectedSegmentIndex = 0;
    
    
    self.currentBottom = control.bottom + 20;
    
    self.scrollView.height = self.currentBottom;
    
    self.tableView.tableHeaderView = self.scrollView;
    
    [self loadNodeData];
}

- (void)valueChanged:(UISegmentedControl *)sender
{
    [self updateTable:sender.selectedSegmentIndex];
}

- (void)updateTable:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            self.dataSource.dataSource = self.uncompletedNodes;
        }
            break;
        case 1:
        {
            self.dataSource.dataSource = self.approvingNodes;
        }
            break;
        case 2:
        {
            self.dataSource.dataSource = self.completedNodes;
        }
            break;
            
        default:
            self.dataSource.dataSource = nil;
            break;
    }
    
    [self.tableView reloadData];
    
    self.emptyLabel.hidden = self.dataSource.dataSource.count != 0;
    self.tableView.scrollEnabled = self.dataSource.dataSource.count != 0;
}

- (UILabel *)emptyLabel
{
    if ( !_emptyLabel ) {
        _emptyLabel = AWCreateLabel(CGRectMake(0, 0, self.contentView.width - 30,
                                               30),
                                    @"无数据显示",
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromHex(@"#666666"));
        [self.contentView addSubview:_emptyLabel];
        
        _emptyLabel.center = CGPointMake(self.contentView.width / 2,
                                         self.contentView.height * 2 / 3 );
    }
    
    [self.contentView bringSubviewToFront:_emptyLabel];
    
    return _emptyLabel;
}

- (void)loadNodeData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同楼栋产值节点APP",
              @"param1": [self.params[@"item"][@"contractid"] description] ?: @"",
              @"param2": [self.params[@"building"][@"building_id"] description] ?: @"",
              } completion:^(id result, NSError *error) {
                  [me handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    NSLog(@"result: %")
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"楼栋产值节点数据为空" offset:CGPointMake(0,20)];
        } else {
            //            [self showRoom:result[@"data"]];
            [self showContent2:result[@"data"]];
        }
    }
}

- (void)showContent2:(id)data
{
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    NSMutableArray *arr3 = [NSMutableArray array];
    
    for (id dict in data) {
        if ([dict[@"nodecompletestatusnum"] integerValue] == 1) { // 已完成
            [arr1 addObject:dict];
        } else if ([dict[@"nodecompletestatusnum"] integerValue] == 2) {
            [arr2 addObject:dict];
        } else if ([dict[@"nodecompletestatusnum"] integerValue] == 3) {
            [arr3 addObject:dict];
        }
    }
    
    self.uncompletedNodes = arr1;
    self.approvingNodes   = arr2;
    self.completedNodes   = arr3;
    
    [self updateTable:0];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        
        [self.contentView addSubview:_tableView];
        
        _tableView.rowHeight = 56;
        
        [_tableView removeBlankCells];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.dataSource = self.dataSource;
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil,
                                                  @"OutputNodeCell",
                                                  @"cell.id");
        
        __weak typeof(self) me = self;
        _dataSource.itemDidSelectBlock = ^(UIView<AWTableDataConfig> *sender, id selectedData)
        {
            NSInteger value = [selectedData[@"confirmbase"] integerValue];
            
            NSMutableDictionary *params = [me.params mutableCopy];
            [params setObject:selectedData forKey:@"floor"];
            
            UIViewController *vc = nil;
            if ( value == 10 ) {
                vc = [[AWMediator sharedInstance] openVCWithName:@"OutputRoomConfirmVC"
                                                          params:params];
            } else if ( value == 50 ) {
                vc = [[AWMediator sharedInstance] openVCWithName:@"OutputValueConfirmVC"
                                                          params:params];
            }
            
            [me.navigationController pushViewController:vc animated:YES];
        };
    }
    return _dataSource;
}

@end

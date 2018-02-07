//
//  BIDataDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 6/5/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BIDataDetailVC.h"
#import "Defines.h"
#import "TYAttributedLabel.h"
#import "SelectButton.h"

@interface BIDataDetailVC ()

@property (nonatomic, weak)   UIView *toolView;

@property (nonatomic, strong) TYAttributedLabel *titleLabel;

//@property (nonatomic, strong) SelectButton *monthButton;
//@property (nonatomic, strong) id currentMonthOption;
//@property (nonatomic, strong) NSArray *monthData;
//
//@property (nonatomic, strong) SelectButton *yearButton;
//@property (nonatomic, strong) id currentYearOption;
//@property (nonatomic, strong) NSArray *yearData;

@property (nonatomic, copy) NSString *areaID;
@property (nonatomic, copy) NSString *industryID;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation BIDataDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = [NSString stringWithFormat:@"%@%@%@明细",
                         self.params[@"area"][@"name"],
                         self.params[@"industry"][@"name"],
                         self.params[@"action"]];
    
    self.areaID = [self.params[@"area"][@"id"] description];
    self.industryID = [self.params[@"industry"][@"id"] description];
    
    [self loadData];
    
//    [self initToolView];
}

- (void)updateTitleLabel
{
    float totalPlan = [self.params[@"total_summary"][@"plan"] floatValue];
    float totalReal = [self.params[@"total_summary"][@"real"] floatValue];
    
    self.titleLabel.text = nil;
    self.titleLabel.attributedText = nil;
    
//    NSString *string = [NSString stringWithFormat:@"%@%@%@计划%@",
//                        self.params[@"area"][@"name"],
//                        self.params[@"industry"][@"name"],
//                        self.currentMonthOption[@"name"],
//                        self.params[@"action"]];
    NSString *string = [NSString stringWithFormat:@"计划%@",
//                        self.params[@"area"][@"name"],
//                        self.params[@"industry"][@"name"],
//                        self.currentMonthOption[@"name"],
                        self.params[@"action"]];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttributeFont:AWSystemFontWithSize(15, NO)];
    [attrString addAttributeTextColor:AWColorFromRGB(58, 58, 58)];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", totalPlan]];
    [attrString addAttributeFont:AWSystemFontWithSize(18, NO)];
    [attrString addAttributeTextColor:MAIN_THEME_COLOR];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    NSString *unit = [[self.areaID description] isEqualToString:@"0"] ? @"亿" : @"万";
    
    attrString = [[NSMutableAttributedString alloc] initWithString:
                  [NSString stringWithFormat:@"%@，实际%@", unit, self.params[@"action"]]];
    [attrString addAttributeFont:AWSystemFontWithSize(15, NO)];
    [attrString addAttributeTextColor:AWColorFromRGB(58, 58, 58)];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", totalReal]];
    [attrString addAttributeFont:AWSystemFontWithSize(18, NO)];
    [attrString addAttributeTextColor:MAIN_THEME_COLOR];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    attrString = [[NSMutableAttributedString alloc] initWithString:unit];
    [attrString addAttributeFont:AWSystemFontWithSize(15, NO)];
    [attrString addAttributeTextColor:AWColorFromRGB(58, 58, 58)];
    
    [self.titleLabel appendTextAttributedString:attrString];
    
    self.titleLabel.textAlignment = kCTTextAlignmentCenter;
}

- (void)initToolView
{
    UIView *toolView = [[UIView alloc] init];
    [self.contentView addSubview:toolView];
    toolView.frame = CGRectMake(0, 0, self.contentView.width, 50);
    toolView.backgroundColor = [UIColor whiteColor];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // 设置工具条
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:toolView.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:toolView];
    line.position = CGPointMake(0, toolView.height - 1);
    
    self.toolView = toolView;
    
//    __weak typeof(self) me = self;
    
//    self.monthButton = [[SelectButton alloc] init];
//    [self.toolView addSubview:self.monthButton];
//    
//    self.monthButton.clickBlock = ^(SelectButton *sender) {
//        [me openPickerForData:me.monthData];
//    };
//    
//    self.yearButton = [[SelectButton alloc] init];
//    [self.toolView addSubview:self.yearButton];
//    self.yearButton.clickBlock = ^(SelectButton *sender) {
//        [me openPickerForData:me.yearData];
//    };
//    
//    self.currentMonthOption = @{ @"name": self.params[@"timeData"][@"name"],
//                                 @"value": self.params[@"timeData"][@"value"]
//                                 };
//    self.currentYearOption  = @{ @"name": [NSString stringWithFormat:@"%@年",
//                                           self.params[@"timeData"][@"year"]],
//                                 @"value": self.params[@"timeData"][@"year"]
//                                 };
    
    [self updateMonthButton];
    
    // 标题
    self.titleLabel = [[TYAttributedLabel alloc] init];
    [self.toolView addSubview:self.titleLabel];
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.titleLabel.frame = CGRectMake(15, 0,
                                       self.contentView.width - 30,
                                       50);
    
    [self updateTitleLabel];
}

- (void)openPickerForData:(NSArray *)data
{
//    SelectPicker *picker = [[SelectPicker alloc] init];
//    picker.frame = self.contentView.bounds;
//    
//    //    id currentOption;
//    
//    picker.options = data;
//    
//    picker.currentSelectedOption = data == self.yearData ? self.currentYearOption : self.currentMonthOption;
//    
//    [picker showPickerInView:self.contentView];
//    
//    //    __weak typeof(self) me = self;
//    picker.didSelectOptionBlock = ^(SelectPicker *sender, id selectedOption, NSInteger index) {
//        
//        if ( data == self.yearData ) {
//            self.currentYearOption = data[index];
//        } else if ( data == self.monthData ) {
//            self.currentMonthOption = data[index];
//        }
//        
//        [self updateMonthButton];
//    };
}

- (void)loadData
{
    self.titleLabel.hidden = YES;
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
//    NSString *taskType = @"0";
//    NSString *quarter  = @"0";
//    NSString *month    = @"0";
//    NSString *year     = @"0";
    
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
    
    NSString *taskType = @"0";
    NSString *quarter  = [self.params[@"timeData"][@"quarter"] description];
    NSString *month    = [self.params[@"timeData"][@"month"] description];;
    NSString *year     = [self.params[@"timeData"][@"year"] description];;
    NSString *week     = [self.params[@"timeData"][@"week"] description];;
    
    //    if ( self.timeSelect.quarter == 0 ) {
    //        taskType = @"0";
    //    } else if ( self.timeSelect.month == 0 ) {
    //        taskType = @"1";
    //    } else {
    //        taskType = @"2";
    //    }
    
    if ( [quarter isEqualToString:@"0"]) {
        taskType = @"0";
    } else {
        if ( [month isEqualToString:@"0"] ) {
            taskType = @"1";
        } else {
            taskType = @"2";
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI签约回款明细周查询APP",
              @"param1": self.areaID,
              @"param2": self.industryID,
              @"param3": taskType,
              @"param4": year,
              @"param5": quarter,
              @"param6": month,
              @"param7": week,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult: result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
//        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
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
//            [self.contentView showHUDWithText:@"没有查询到数据" offset:CGPointMake(0,20)];
            [self.tableView showErrorOrEmptyMessage:@"没有查询到数据" reloadDelegate:nil];
        } else {
            NSArray *data = result[@"data"];
            
            self.dataSource.dataSource = data;
            
            [self.tableView reloadData];
        }
    }
}

- (void)updateMonthButton
{
//    self.monthButton.maxWidth = 120;
    
//    self.monthButton.title = [NSString stringWithFormat:@"%@", self.currentMonthOption[@"name"]];
//    self.monthButton.center = CGPointMake(self.contentView.width - 15 -
//                                          self.monthButton.width / 2,
//                                          13 + self.monthButton.height / 2);
//    
//    self.yearButton.title = [NSString stringWithFormat:@"%@", self.currentYearOption[@"name"]];
//    
//    self.yearButton.center = CGPointMake(self.monthButton.left - 5 - self.yearButton.width / 2,
//                                         self.monthButton.midY);
//    
//    CGFloat width = self.monthButton.width + 5 + self.yearButton.width;
//    CGFloat left  = self.contentView.width / 2 - width / 2;
//    self.yearButton.left = left;
//    self.monthButton.left = self.yearButton.right + 5;
    
    [self loadData];
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
//                              @"name": @"全年",
//                              @"value": @"0",
//                              },
//                          @{
//                              @"name": @"一季度",
//                              @"value": @"1",
//                              },
//                          @{
//                              @"name": @"二季度",
//                              @"value": @"2",
//                              },
//                          @{
//                              @"name": @"三季度",
//                              @"value": @"3",
//                              },
//                          @{
//                              @"name": @"四季度",
//                              @"value": @"4",
//                              },
//                          @{
//                              @"name": @"1月",
//                              @"value": @"5",
//                              },
//                          @{
//                              @"name": @"2月",
//                              @"value": @"6",
//                              },
//                          @{
//                              @"name": @"3月",
//                              @"value": @"7",
//                              },
//                          @{
//                              @"name": @"4月",
//                              @"value": @"8",
//                              },
//                          @{
//                              @"name": @"5月",
//                              @"value": @"9",
//                              },
//                          @{
//                              @"name": @"6月",
//                              @"value": @"10",
//                              },
//                          @{
//                              @"name": @"7月",
//                              @"value": @"11",
//                              },
//                          @{
//                              @"name": @"8月",
//                              @"value": @"12",
//                              },
//                          @{
//                              @"name": @"9月",
//                              @"value": @"13",
//                              },
//                          @{
//                              @"name": @"10月",
//                              @"value": @"14",
//                              },
//                          @{
//                              @"name": @"11月",
//                              @"value": @"15",
//                              },
//                          @{
//                              @"name": @"12月",
//                              @"value": @"16",
//                              },];
//        _monthData = data;
//    }
//    return _monthData;
//}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        CGRect frame = CGRectMake(0, 0,
                                  self.contentView.width,
                                  self.contentView.height - 0);
        _tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        
        [_tableView removeBlankCells];
        
        CGFloat width = (self.contentView.width - 30 - 30) / 3.0; // 三个部分
        
        _tableView.rowHeight = 30 + 30 + 10 + width;
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil,
                                                  @"BIDataCell",
                                                  @"cell.id");
        
    }
    return _dataSource;
}

@end

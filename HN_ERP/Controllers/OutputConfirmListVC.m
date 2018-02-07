//
//  OutputConfirmListVC.m
//  HN_ERP
//
//  Created by tomwey on 27/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "OutputConfirmListVC.h"
#import "Defines.h"
#import "OutputNodeConfirmCell.h"
#import "AWFilterView.h"

@interface OutputConfirmListVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UILabel *totalApprovingLabel;
@property (nonatomic, weak) UIButton *commitBtn;

@property (nonatomic, strong) UIView *filterBox;
@property (nonatomic, strong) DMButton *dateBtn; // 时间过滤
@property (nonatomic, strong) DMButton *roomBtn; // 楼栋过滤
@property (nonatomic, strong) DMButton *stateBtn; // 状态过滤

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) AWFilterView *filterView;

@property (nonatomic, strong) NSMutableArray *rooms;
@property (nonatomic, strong) NSMutableDictionary *roomNodes;

@property (nonatomic, strong) id approvingData;
@property (nonatomic, strong) NSError *approvingError;

@property (nonatomic, strong) id nodeListData;
@property (nonatomic, strong) NSError *nodeListError;

@property (nonatomic, assign) NSInteger counter;

@property (nonatomic, strong) id roomData;
@property (nonatomic, strong) NSError *roomError;
@property (nonatomic, strong) NSMutableArray *roomOptions;

@end

@implementation OutputConfirmListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.params);
    
    self.navBar.title = self.params[@"item"][@"contractname"];
    
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
    [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
    
    UIButton *btn = AWCreateImageButtonWithColor(@"btn_info.png", [UIColor whiteColor],
                                                 self,
                                                 @selector(openInfo));
    btn.frame = CGRectMake(0, 0, 40, 40);
    [self addRightItemWithView:btn rightMargin:5];
    
    [self initFilterView];
    
    [self initCommitButton];
    
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

- (void)loadData
{
//    [self.tableView reloadData];
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [self.tableView removeErrorOrEmptyTips];
    
    self.roomNodes = [@{} mutableCopy];
    self.rooms     = [@[] mutableCopy];
    
    __weak typeof(self) me = self;
    
    AWFilterItem *item = (AWFilterItem *)self.dateBtn.userData;
    NSString *startDate = @"";
    NSString *endDate   = @"";
    
    if ( [item.value integerValue] == 4 ) { // 自定义日期
        if ( item.userData[@"startDate"] ) {
            startDate = item.userData[@"startDate"];
        } else {
            startDate = @"";
        }
        
        if ( item.userData[@"endDate"] ) {
            endDate = item.userData[@"endDate"];
        } else {
            endDate = @"";
        }
    }
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] ?: @"0" description];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同楼栋产值节点APP",
              @"param1": [self.params[@"item"][@"contractid"] ?: @"0" description],
              @"param2": [[(AWFilterItem *)self.roomBtn.userData value] ?: @"0" description],
              @"param3": [self.searchBar.text trim] ?: @"",
              @"param4": [[(AWFilterItem *)self.stateBtn.userData value] ?: @"0" description],
              @"param5": [[(AWFilterItem *)self.dateBtn.userData value] ?: @"0" description],
              @"param6": startDate,
              @"param7": endDate,
              @"param8": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"产值确认获取待申报列表APP",
                       @"param1": [self.params[@"item"][@"contractid"] description] ?: @"",
                       @"param2": @"2",
                       @"param3": manID,
                       } completion:^(id result, NSError *error) {
                           [me handleResult2:result error:error];
                       }];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同楼栋APP",
              @"param1": [self.params[@"item"][@"contractid"] description] ?: @""
              } completion:^(id result, NSError *error) {
                  [me handleResult3:result error:error];
              }];

}

- (void)handleResult3:(id)result error:(NSError *)error
{
    self.roomData = result;
    self.roomError = error;
    
    [self loadDone];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    self.approvingData = result;
    self.approvingError = error;
    
    [self loadDone];
}

- (void)loadDone
{
    if ( ++self.counter == 3 ) {
        
        self.counter = 0;
        
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        // 显示楼栋
        if ( self.nodeListError ) {
            [self.tableView showErrorOrEmptyMessage:self.nodeListError.localizedDescription reloadDelegate:nil];
        } else {
            if ( [self.nodeListData[@"rowcount"] integerValue] == 0 ) {
                [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
                
                [self.rooms removeAllObjects];
                [self.roomNodes removeAllObjects];
                
            } else {
                NSArray *data = self.nodeListData[@"data"];
                
                for (id item in data) {
                    NSString *roomName = [item[@"roomname"] description];
                    NSMutableArray *arr = self.roomNodes[roomName];
                    if ( !arr ) {
                        arr = [@[] mutableCopy];
                        self.roomNodes[roomName] = arr;
                        [arr addObject:item];
                        
                        [self.rooms addObject:roomName];
                    } else {
                        [arr addObject:item];
                    }
                }
            }
            
            [self.tableView reloadData];
        }
        
        // 显示待申报列表
        [self showApprovingContent];
        
        // 处理楼栋数据
        [self prepareRoomData];
    }
}

- (void)prepareRoomData
{
    AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:@"全部楼栋"
                                                         value:@"-1"
                                                          type:FilterItemTypeNormal];
    
    self.roomOptions = [@[] mutableCopy];
    
    [self.roomOptions addObject:newItem];
    
    if ( self.roomData && [self.roomData[@"rowcount"] integerValue] > 0 ) {
        NSArray *data = self.roomData[@"data"];
        
        for (id item in data) {
            AWFilterItem *obj = [[AWFilterItem alloc] initWithName:[item[@"building_name"] description]
                                                             value:item[@"building_id"] ?: @"0"
                                                              type:FilterItemTypeNormal];
            [self.roomOptions addObject:obj];
        }
    }
}

- (void)showApprovingContent
{
    if ( self.approvingData && self.approvingData[@"rowcount"] ) {
        [self updateApprovingCount:[self.approvingData[@"rowcount"] integerValue]];
    }
}

- (void)initFilterView
{
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width,
                                                                  84)];
    [self.contentView addSubview:filterView];
    filterView.backgroundColor = [UIColor whiteColor];
    
    self.filterBox = filterView;
    
    self.dateBtn.frame =
    self.roomBtn.frame =
    self.stateBtn.frame = CGRectMake(0, 0, self.contentView.width / 3.0, 40);
    
    self.roomBtn.left = self.dateBtn.right;
    self.stateBtn.left = self.roomBtn.right;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, self.dateBtn.bottom,
                                                                   filterView.width - 10, 44)];
    
    [filterView addSubview:self.searchBar];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundImage = AWImageFromColor([UIColor whiteColor]);
    self.searchBar.placeholder = @"输入节点名称搜索";
    self.searchBar.delegate = self;
    
    self.searchBar.tintColor = MAIN_THEME_COLOR;
    
    // 线
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:filterView.width
                                                             color:AWColorFromHex(@"#e6e6e6")
                                                            inView:filterView];
    line.position = CGPointMake(0, self.dateBtn.bottom);
}

- (void)openPickerForData:(NSArray *)data sender:(DMButton *)sender
{
    [self.searchBar resignFirstResponder];
    
    [[self.contentView viewWithTag:11022] removeFromSuperview];
    
    AWFilterView *filterView = [[AWFilterView alloc] init];
//    self.filterView = filterView;
    filterView.tag = 11022;
    
    filterView.frame = CGRectMake(0, 41, self.contentView.width,
                                  self.contentView.height - 41);
    
    NSMutableArray *temp = [@[] mutableCopy];
    NSMutableArray *temp2 = [@[] mutableCopy];
    for (id item in data) {
        
        if ( [[item name] isEqualToString:@"自定义"] ) {
            [temp2 addObject:item];
        } else {
            [temp addObject:item];
        }
    }
    
//    if ( sender == self.roomBtn ) {
    NSInteger index = [data indexOfObject:sender.userData];
    if ( index == NSNotFound ) {
        for (int i = 0; i<data.count; i++) {
            AWFilterItem *item = data[i];
            if ( [[[(AWFilterItem *)sender.userData value] description] isEqualToString:[item.value description]] ) {
                index = i;
                break;
            }
        }
    }
    
    filterView.selectedIndex = index;
//    } else {
//        filterView.selectedIndex = 1;
//    }
    
    __weak typeof(self) me = self;
    
    filterView.filterItems = temp;
    filterView.customFilterItems = temp2;
    [filterView showInView:self.contentView selectBlock:^(AWFilterView *sender1, AWFilterItem *selectedItem) {
        NSLog(@"select item #########");
        sender.userData = selectedItem;
        sender.title = [selectedItem name];
        
        if ( selectedItem.itemType == FilterItemTypeNormal ) {
            for (AWFilterItem *item in filterView.customFilterItems) {
                item.userData = nil;
            }
        }
        
        [me loadData];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self loadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    
    [self loadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self searchBarResignAndChangeUI];
    });
}

- (void)searchBarResignAndChangeUI
{
    [self.searchBar resignFirstResponder];
    
    [self changeSearchBarCancelBtnTitleColor:self.searchBar];
}

- (void)changeSearchBarCancelBtnTitleColor:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        btn.enabled = YES;
        btn.userInteractionEnabled = YES;
        // 设置取消按钮的颜色
        [btn setTitleColor:MAIN_BG_COLOR forState:UIControlStateReserved];
        [btn setTitleColor:MAIN_BG_COLOR forState:UIControlStateDisabled];
    }else{
        for (UIView *subView in view.subviews) {
            [self changeSearchBarCancelBtnTitleColor:subView];
        }
    }
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
                             @"isNew": @"1",
                             @"contractid":[self.params[@"item"][@"contractid"] description] ?: @"",
                             @"data": self.approvingData[@"data"] ?: @[],
                             @"item": self.params[@"item"] ?: @{},
                             };
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"OutputDeclareListVC"
                                                                   params:params];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//    
//    if ( error ) {
//        [self.tableView showErrorOrEmptyMessage:error.localizedDescription reloadDelegate:nil];
//    } else {
//        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
//            
//            [self.rooms removeAllObjects];
//            [self.roomNodes removeAllObjects];
//            
//        } else {
//            NSArray *data = result[@"data"];
//            
//            for (id item in data) {
//                NSString *roomName = [item[@"roomname"] description];
//                NSMutableArray *arr = self.roomNodes[roomName];
//                if ( !arr ) {
//                    arr = [@[] mutableCopy];
//                    self.roomNodes[roomName] = arr;
//                    [arr addObject:item];
//                    
//                    [self.rooms addObject:roomName];
//                } else {
//                    [arr addObject:item];
//                }
//            }
//        }
//    }
//    
//    [self.tableView reloadData];
    
    self.nodeListData = result;
    self.nodeListError = error;
    
    [self loadDone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.rooms count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.rooms[section];
    return [self.roomNodes[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OutputNodeConfirmCell *cell = (OutputNodeConfirmCell *)[tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[OutputNodeConfirmCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *key = self.rooms[indexPath.section];
    id item = self.roomNodes[key][indexPath.row];
    
    [cell configData:item];
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    NSString *key = self.rooms[indexPath.section];
    id item = self.roomNodes[key][indexPath.row];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputConfirmCommitVC"
                                                                params:@{ @"floor": item ?: [NSNull null] }];
    
    // 此处会导致卡顿Bug，所以加一个主线程异步执行
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:vc
//                           animated:YES
//                         completion:nil];
//    });
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.rooms[section];
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

- (void)openInfo
{
    [self.searchBar resignFirstResponder];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputInfoVC" params:self.params];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)backToPage
{
    NSArray *controllers = [self.navigationController viewControllers];
    if ( controllers.count > 1 ) {
        [self.navigationController popToViewController:controllers[1] animated:YES];
    }
}

- (DMButton *)dateBtn
{
    if ( !_dateBtn ) {
        _dateBtn = [[DMButton alloc] init];
        [self.filterBox addSubview:_dateBtn];
        
        __weak typeof(self) me = self;
        NSArray *arr = @[
                         @{
                             @"label": @"全部",
                             @"value": @"0",
                             },
                         @{
                             @"label": @"本月",
                             @"value": @"1",
                             },
                         @{
                             @"label": @"近两月",
                             @"value": @"2",
                             },
                         @{
                             @"label": @"近三月",
                             @"value": @"3",
                             },
                         @{
                             @"label": @"自定义",
                             @"value": @"4",
                             },
                         ];
        
        NSMutableArray *temp = [@[] mutableCopy];
        for (id item in arr) {
            if ( [item[@"label"] isEqualToString:@"自定义"] ) {
                AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:item[@"label"]
                                                                     value:item[@"value"]
                                                                      type:FilterItemTypeCustomDateRange];
                [temp addObject:newItem];
            } else {
                AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:item[@"label"]
                                                                     value:item[@"value"]
                                                                      type:FilterItemTypeNormal];
                [temp addObject:newItem];
            }
            
        }
        
        _dateBtn.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:temp sender:sender];
        };
        
        _dateBtn.title = @"本月";
        _dateBtn.userData = temp[1];
    }
    return _dateBtn;
}

- (DMButton *)roomBtn
{
    if ( !_roomBtn ) {
        _roomBtn = [[DMButton alloc] init];
        [self.filterBox addSubview:_roomBtn];
        
//        NSArray *arr = @[
//                         @{
//                             @"label": @"全部楼栋",
//                             @"value": @"-1",
//                             },
//                         @{
//                             @"label": @"不区分楼栋",
//                             @"value": @"0",
//                             }
//                         ];
//        
//        NSMutableArray *temp = [@[] mutableCopy];
//        for (id item in arr) {
//            AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:item[@"label"]
//                                                                 value:item[@"value"]
//                                                                  type:FilterItemTypeNormal];
//            [temp addObject:newItem];
//        }
        
        AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:@"全部楼栋"
                                                             value:@"-1"
                                                              type:FilterItemTypeNormal];
        
        self.roomOptions = [@[] mutableCopy];
        
        [self.roomOptions addObject:newItem];
        
        __weak typeof(self) me = self;
        _roomBtn.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.roomOptions sender:sender];
        };
        
        _roomBtn.title = @"全部楼栋";
        
        _roomBtn.userData = [self.roomOptions firstObject];
    }
    return _roomBtn;
}

- (DMButton *)stateBtn
{
    if ( !_stateBtn ) {
        _stateBtn = [[DMButton alloc] init];
        [self.filterBox addSubview:_stateBtn];
        
        __weak typeof(self) me = self;
        NSArray *arr = @[
                         @{
                             @"label": @"全部",
                             @"value": @"0",
                             },
                         @{
                             @"label": @"未确认",
                             @"value": @"1",
                             },
                         @{
                             @"label": @"待申报",
                             @"value": @"2",
                             },
                         @{
                             @"label": @"已申报",
                             @"value": @"3",
                             },
                         ];
        
        NSMutableArray *temp = [@[] mutableCopy];
        for (id item in arr) {
            AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:item[@"label"]
                                                              value:item[@"value"]
                                                               type:FilterItemTypeNormal];
            [temp addObject:newItem];
        }
        
        _stateBtn.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:temp sender:sender];
        };
        
        _stateBtn.title = @"未确认";
        _stateBtn.userData = temp[1];
    }
    return _stateBtn;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.top = 84;
        _tableView.height -= (84 + 44);
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 95;
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
    }
    return _tableView;
}

@end

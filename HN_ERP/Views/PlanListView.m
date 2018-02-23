//
//  PlanListView.m
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanListView.h"
#import "Defines.h"
#import "AWFilterView.h"

@interface PlanListView () <UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) UIView *filterBox;

@property (nonatomic, strong) DMButton *projButton;

@property (nonatomic, strong) NSMutableArray *projOptions;

@property (nonatomic, strong) DMButton *levelButton;
@property (nonatomic, strong) DMButton *dateBtn;

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation PlanListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(loadPlans)
//                                                     name:@"kPlanFlowDidCommitNotification"
//                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.dateSelectControl.frame = CGRectMake(15, 0, self.width - 30, 60);
    
    self.dateBtn.frame =
    self.projButton.frame =
    self.levelButton.frame = CGRectMake(0, 0, self.width / 3.0, 40);
    
    self.levelButton.left = self.projButton.right;
    self.dateBtn.left = self.levelButton.right;
    
    self.searchBar.position = CGPointMake(5, self.projButton.bottom);
    
    self.tableView.frame = self.bounds;
    self.tableView.top = self.filterBox.bottom;
    self.tableView.height = self.height - self.filterBox.height;
}

- (void)startLoading
{
    [self loadPlans];
}

- (void)closeFilterView
{
    [[self.superview viewWithTag:11022] removeFromSuperview];
}

- (void)loadPlans
{
    if ( self.loading ) return;
    
    self.loading = YES;
    
    [self.tableView removeErrorOrEmptyTips];
    
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [self.tableView removeErrorOrEmptyTips];
    
    __weak PlanListView *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"工作计划查询APP",
                       @"param1": manID,
                       @"param2": @"",
                       @"param3": @"",
                       @"param4": @"",
                       } completion:^(id result, NSError *error) {
                           __strong PlanListView *strongSelf = weakSelf;
                           if ( strongSelf ) {
                               [strongSelf handleResult:result error:error];
                           }
                       }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.loading = NO;
    
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    
    [self.tableView.pullToRefreshView stopAnimating];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {            
            
            self.dataSource.dataSource = result[@"data"];
        }
        [self.tableView reloadData];
    }
    
    [self.superview bringSubviewToFront:[self.superview viewWithTag:11022]];
}

// 项目，层级，计划名称，完成时间，是否完成
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self, self.dataSource.dataSource[indexPath.row]);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[AWTableViewDataSource alloc] initWithArray:nil cellClass:@"PlanCell" identifier:@"cell.plan.id"];
    }
    return _dataSource;
}

- (UIView *)filterBox
{
    if ( !_filterBox ) {
        _filterBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth(), 84)];
        [self addSubview:_filterBox];
        _filterBox.backgroundColor = [UIColor whiteColor];
        
    }
    return _filterBox;
}

- (UISearchBar *)searchBar
{
    if ( !_searchBar ) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 0,
                                                                       self.filterBox.width - 10, 44)];
        
        [self.filterBox addSubview:_searchBar];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.backgroundImage = AWImageFromColor([UIColor whiteColor]);
        _searchBar.placeholder = @"输入任务名称搜索";
        _searchBar.delegate = self;
        
        _searchBar.tintColor = MAIN_THEME_COLOR;
    }
    
    return _searchBar;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self loadPlans];
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
    
    [self loadPlans];
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

- (DMButton *)projButton
{
    if ( !_projButton ) {
        _projButton = [[DMButton alloc] init];
        [self.filterBox addSubview:_projButton];
        
        AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:@"全部"
                                                             value:@"-1"
                                                              type:FilterItemTypeNormal];
        
        self.projOptions = [@[] mutableCopy];
        
        [self.projOptions addObject:newItem];
        
        __weak typeof(self) me = self;
        _projButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.projOptions sender:sender];
        };
        
        _projButton.title = @"全部";
        
        _projButton.userData = [self.projOptions firstObject];
    }
    return _projButton;
}

- (DMButton *)levelButton
{
    if ( !_levelButton ) {
        _levelButton = [[DMButton alloc] init];
        [self.filterBox addSubview:_levelButton];
        
        __weak typeof(self) me = self;
        NSArray *arr = @[
                         @{
                             @"label": @"全部",
                             @"value": @"0",
                             },
                         @{
                             @"label": @"一级",
                             @"value": @"1",
                             },
                         @{
                             @"label": @"二级",
                             @"value": @"2",
                             },
                         @{
                             @"label": @"三级",
                             @"value": @"3",
                             },
                         @{
                             @"label": @"里程碑",
                             @"value": @"4",
                             },
                         ];
        
        NSMutableArray *temp = [@[] mutableCopy];
        for (id item in arr) {
            AWFilterItem *newItem = [[AWFilterItem alloc] initWithName:item[@"label"]
                                                                 value:item[@"value"]
                                                                  type:FilterItemTypeNormal];
            [temp addObject:newItem];
        }
        
        _levelButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:temp sender:sender];
        };
        
        _levelButton.title = @"全部";
        _levelButton.userData = temp[0];
    }
    return _levelButton;
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

- (void)openPickerForData:(NSArray *)data sender:(DMButton *)sender
{
    [self.searchBar resignFirstResponder];
    
    [[self.superview viewWithTag:11022] removeFromSuperview];
    
    AWFilterView *filterView = [[AWFilterView alloc] init];
    //    self.filterView = filterView;
    filterView.tag = 11022;
    
    filterView.frame = CGRectMake(0, 41, self.width,
                                  self.superview.height - 41);
    
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
    [filterView showInView:self.superview selectBlock:^(AWFilterView *sender1, AWFilterItem *selectedItem) {
        NSLog(@"select item #########");
        sender.userData = selectedItem;
        sender.title = [selectedItem name];
        
        if ( selectedItem.itemType == FilterItemTypeNormal ) {
            for (AWFilterItem *item in filterView.customFilterItems) {
                item.userData = nil;
            }
        }
        
        [me loadPlans];
    }];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = [UIColor clearColor];
        
        _tableView.rowHeight = 120;
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        [_tableView removeCompatibility];
        
        [_tableView removeBlankCells];
        
    }
    
    return _tableView;
}

@end

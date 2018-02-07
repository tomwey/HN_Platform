//
//  OAListView.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OAListView.h"
#import "Defines.h"

@interface OAListView () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, weak) UIRefreshControl *refreshControl;

// 分页使用
@property (nonatomic, assign) NSInteger pageIndex;

// 提示去进行流程查询
@property (nonatomic, strong) FlowSearchHelpView *searchHelpView;

@property (nonatomic, copy) NSString *stateType;

@property (nonatomic, strong) NSMutableDictionary *loadingStates;

@end

@implementation OAListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
    }
    return self;
}

- (NSMutableDictionary *)loadingStates
{
    if ( !_loadingStates ) {
        _loadingStates = [@{} mutableCopy];
    }
    return _loadingStates;
}

- (void)setState:(NSString *)state
{
    if (_state == state) return;
    
    _state = state;
    
    [self updateTable];
}

- (void)setSearchCondition:(NSDictionary *)searchCondition
{
    if (_searchCondition == searchCondition) return;
    
    _searchCondition = searchCondition;
    
    [self updateTable];
}

- (void)updateTable
{
    self.searchHelpView.hidden = YES;
    
    id obj = [[HNCache sharedInstance] objectForKey:[self getCacheKey]];
    if ( obj ) {
        self.dataSource.dataSource = obj;
        [self.tableView removeErrorOrEmptyTips];
        [self.tableView reloadData];
    } else {
        self.dataSource.dataSource = nil;
        [self.tableView reloadData];
    }
}

- (NSString *)searchConditionHash
{
    if ( self.searchCondition.count > 0 ) {
        NSUInteger hash = [[self.searchCondition description] hash];
        return [NSString stringWithFormat:@":%@", @(hash)];
    }
    return @"";
}

- (NSString *)getCacheKey
{
    NSString *manID = [[UserService sharedInstance] currentUser][@"man_id"];
    return [NSString stringWithFormat:@"%@:%@%@", manID, self.state, [self searchConditionHash]];
}

- (NSString *)getPaginateCacheKey
{
    NSString *manID = [[UserService sharedInstance] currentUser][@"man_id"];
    return [NSString stringWithFormat:@"%@:%@:page%@", manID, self.state,[self searchConditionHash]];
}

- (NSInteger)pageIndex
{
    if ( [[HNCache sharedInstance] objectForKey:[self getPaginateCacheKey]] ) {
        return [[[HNCache sharedInstance] objectForKey:[self getPaginateCacheKey]] integerValue];
    }
    
    return 0;
}

- (void)loadMoreData
{
    NSLog(@"执行了");
    
    [self loadDataForState:self.state];
}

- (void)refreshData
{
    NSLog(@"执行了...");
    [self forceRefreshForState:self.state];
}

- (NSString *)dateForKey:(NSString *)key
{
    if (!key) {
        return @"";
    }
    
    if (!self.searchCondition) {
        return @"";
    }
    
    id value = self.searchCondition[key];
    if ( !value ) {
        return @"";
    }
    
    NSString *dateStr = [value description];
    
    return [[[dateStr componentsSeparatedByString:@" "] firstObject] description];
}

- (NSString *)creatorIdsForKey:(NSString *)key
{
    if (!key) {
        return @"";
    }
    
    if (!self.searchCondition) {
        return @"";
    }
    
    id object = self.searchCondition[key];
    if ( ![object isKindOfClass:[NSArray class]] ) {
        return @"";
    }
    
    NSArray *employees = (NSArray *)object;
    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:employees.count];
    for (Employ *emp in employees) {
        if ( emp._id ) {
            [ids addObject:[emp._id description]];
        }
    }
    return [ids componentsJoinedByString:@","];
}

- (NSDictionary *)prepareParamsForState:(NSString *)state
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    // 0：全部流程；1：我的待办；2：我的请求；3：我的已办；4：我的归档；5：我的抄送；6：总裁批示；7：授权查询
    NSString *searchType = @"0"; // 默认为-1
    if ( [state isEqualToString:@"todo"] ) {
        // 我的待办
        searchType = @"1";
    } else if ( [state isEqualToString:@"cc"] ) {
        // 我的抄送
        searchType = @"5";
    } else if ( [state isEqualToString:@"done"] ) {
        // 我的已办
        searchType = @"3";
    } else if ( [state isEqualToString:@"search"] ) {
        if ( self.searchCondition[@"flow_state"] &&
            self.searchCondition[@"flow_state"][@"value"]) {
            searchType = [self.searchCondition[@"flow_state"][@"value"] description];
            if ([searchType isEqualToString:@"-1"]) {
                searchType = @"0";
            }
        }
    }
    
    self.stateType = searchType;
    
    NSString *beginDate  = [self dateForKey:@"create_date.1"];
    NSString *endDate    = [self dateForKey:@"create_date.2"];
    NSString *creatorIds = [self creatorIdsForKey:@"contacts"];
    NSString *flowNo     = self.searchCondition[@"flow_no"] ?: @""; // 流程编号
    NSString *flowDesc   = self.searchCondition[@"flow_desc"] ?: @""; // 流程说明
    flowNo = [flowNo trim];
    flowDesc = [flowDesc trim];
    NSString *joinMan    = [self creatorIdsForKey:@"contacts2"]; // 参与人
    
    return @{
             @"dotype": @"GetData",
             @"funname": @"流程查询APP",
             @"param1": manID,      // man id
             @"param2": searchType, // 搜索类型
             @"param3": beginDate,  // 开始日期
             @"param4": endDate,    // 结束日期
             @"param5": creatorIds, // 创建人ID，以逗号分隔
             @"param6": flowNo,     // 流程编号
             @"param7": flowDesc,   // 流程说明
             @"param8": joinMan,    // 参与人
             };
}

- (void)loadDataForState:(NSString *)state
{
    if ( self.pageIndex == -1 ) {
        // 没有更多数据
        return;
    }
    
    if ( [self.loadingStates[state] boolValue] == YES ) {
        // 当前状态正在加载数据，直接返回，
        NSLog(@"同一状态重复加载...");
        return;
    }
    
    self.loadingStates[state] = @(YES);
    
    [self.tableView removeErrorOrEmptyTips];
    
    if ( self.pageIndex == 0 ) {
        // 表示加载第一页数据
        [self.tableView.pullToRefreshView startAnimating];
    }
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
            POST:nil
          params:[self prepareParamsForState:state]
      completion:^(id result, NSError *error) {
         [me handleResult:result error:error];
     }];
    
    /*
    if ([state isEqualToString:@"todo"]) {
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"todolist",
                  @"manid": manID,
                  @"todotype": state ?: @"",
                  @"pageindex": [@(self.pageIndex) description],
                  } completion:^(id result, NSError *error) {
                      [me handleResult:result error:error];
                  }];
    } else {
        // 抄送
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"GetData",
                  @"funname": @"我的抄送",
                  @"param1": manID,
                  @"param2": @"-1",
                  @"param3": @"",
                  @"param4": @"-1",
                  @"param5": @"",
                  @"param6": @"",
                  @"param7": @"",
                  @"param8": @"",
                  @"param9": [@(self.pageIndex) description],
                  } completion:^(id result, NSError *error) {
                      [me handleResult:result error:error];
                  }];
    }*/
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
    
    self.loadingStates[self.state] = @(NO);
    
    [self.tableView.pullToRefreshView stopAnimating];

    if ( error ) {
        if ( self.pageIndex == 0 ) {
            // 第一页
            if ([self.state isEqualToString:@"search"]) {
                self.searchHelpView.hidden = NO;
                self.searchHelpView.errorOrEmptyMessage = @"加载出错了!";
                self.searchHelpView.searchButtonTitle   = @"重新搜索";
            } else {
                self.searchHelpView.hidden = YES;
                [self.tableView showErrorOrEmptyMessage:@"加载出错了!" reloadDelegate:nil];
            }
            
            self.tableView.showsInfiniteScrolling = NO;
            
        } else {
            [self showHUDWithText:@"加载出错了!" succeed:NO];
        }
    } else {
        NSInteger count = [result[@"rowcount"] integerValue];
        if ( count == 0  ) {
//            self.tableView.hidden = YES;
            
            if ( self.pageIndex == 0 ) {
                // 取第一页
                self.dataSource.dataSource = nil;
                [self.tableView reloadData];
                
                [[HNCache sharedInstance] removeCacheForKey:[self getCacheKey]];
                
//                [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
//                                         reloadDelegate:nil];
                if ([self.state isEqualToString:@"search"]) {
                    self.searchHelpView.hidden = NO;
                    self.searchHelpView.errorOrEmptyMessage = @"<无数据显示>";
                    self.searchHelpView.searchButtonTitle   = @"去搜索";
                } else {
                    self.searchHelpView.hidden = YES;
                    [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
                }
                
            } else {
                // 其他页
//                [self makeToast:@"没有更多数据了"];
                [self showHUDWithText:LOADING_MORE_NO_RESULT];
            }
            
            // 只要是没有数据就隐藏加载更多
            self.tableView.showsInfiniteScrolling = NO;
        } else {
            
            self.searchHelpView.hidden = YES;
            
            id resultData = result[@"data"];
            if ([[resultData lastObject][@"pageindex"] integerValue] == -1) {
                self.tableView.showsInfiniteScrolling = NO;
            } else {
                self.tableView.showsInfiniteScrolling = YES;
            }
            
            if ( [resultData isKindOfClass:[NSArray class]] ) {
                
                NSMutableArray *tempResult = [NSMutableArray array];
                
                for (id obj in resultData) {
                    if ( [obj isKindOfClass:[NSDictionary class]] ) {
                        NSMutableDictionary *dict = [obj mutableCopy];
                        dict[@"state_type"] = self.stateType ?: @"0";
                        [tempResult addObject:dict];
                    }
                }
                
                NSLog(@"state: %@", self.state);
                
                if ( self.pageIndex <= 0 ) {
                    self.dataSource.dataSource = tempResult;
                } else {
                    NSMutableArray *oldData = [self.dataSource.dataSource mutableCopy];
                    [oldData addObjectsFromArray:tempResult];
                    self.dataSource.dataSource = [oldData copy];
                }
                
                // 缓存数据
                [[HNCache sharedInstance] setObject:self.dataSource.dataSource forKey:[self getCacheKey]];
                
                // 缓存下一页的请求id
                [[HNCache sharedInstance] setObject:[resultData lastObject][@"pageindex"] forKey:[self getPaginateCacheKey]];
                
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
        }
    }
}

- (void)forceRefreshForState:(NSString *)state
{
    // 清空缓存的页码
    NSLog(@"强制刷新了...");
    [[HNCache sharedInstance] removeCacheForKey:[self getPaginateCacheKey]];
    [[HNCache sharedInstance] removeCacheForKey:[self getCacheKey]];

    [self loadDataForState:state];
}

- (void)startLoadingForState:(NSString *)state
{
    id obj = [[HNCache sharedInstance] objectForKey:[self getCacheKey]];
    if ( !obj ) {
        if ( [state isEqualToString:@"search"] ) {
            self.searchHelpView.hidden = NO;
        } else {
            self.searchHelpView.hidden = YES;
            // 没得缓存数据存在，就去加载第一页数据
            
            [self forceRefreshForState:state];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
    self.searchHelpView.frame = self.bounds;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.rowHeight = 90;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView removeBlankCells];
        
        _tableView.backgroundColor = [UIColor clearColor];
        
        // 添加下拉刷新
        __weak OAListView *weakSelf = self;
        [_tableView addPullToRefreshWithActionHandler:^{
            __strong OAListView *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf refreshData];
            }
        }];
        
        // 配置下拉刷新功能
        HNRefreshView *stopView = [[HNRefreshView alloc] init];
        stopView.text = @"下拉刷新";
        
        HNRefreshView *loadingView = [[HNRefreshView alloc] init];
        loadingView.text = @"加载中...";
        loadingView.animated = YES;
        
        HNRefreshView *triggerView = [[HNRefreshView alloc] init];
        triggerView.text = @"松开刷新";
        triggerView.animated = YES;
        
        [_tableView.pullToRefreshView setCustomView:triggerView forState:SVPullToRefreshStateTriggered];
        [_tableView.pullToRefreshView setCustomView:loadingView forState:SVPullToRefreshStateLoading];
        [_tableView.pullToRefreshView setCustomView:stopView forState:SVPullToRefreshStateStopped];
        
        // 添加加载更多
        [_tableView addInfiniteScrollingWithActionHandler:^{
            __strong OAListView *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf loadMoreData];
            }
        }];
        
        // 配置加载更多
        DGActivityIndicatorView *view = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:MAIN_THEME_COLOR];
        [view startAnimating];
        [_tableView.infiniteScrollingView setCustomView:view forState:SVInfiniteScrollingStateAll];
        
        _tableView.showsInfiniteScrolling = NO;
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[AWTableViewDataSource alloc] initWithArray:nil
                                                         cellClass:@"OACell2"
                                                        identifier:@"oa.cell"];
        
        __weak typeof(self) me = self;
        _dataSource.itemDidSelectBlock = ^(UIView<AWTableDataConfig> *sender, id selectedData) {
            
            if ( !me.from ) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OADetailVC" params:@{ @"item": selectedData, @"has_action": @([me.state isEqualToString:@"todo"]),
                                                                                                           @"state": me.state ?: @"todo"}];
                [[AWAppWindow() navController] pushViewController:vc animated:YES];
            } else {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"kFlowDidSelectNotification"
                               object:@{ @"field_name": me.from,
                                         @"flow": selectedData
                                         }];
            }
        };
    }
    return _dataSource;
}

- (FlowSearchHelpView *)searchHelpView
{
    if ( !_searchHelpView ) {
        _searchHelpView = [[FlowSearchHelpView alloc] init];
        [self addSubview:_searchHelpView];
        _searchHelpView.backgroundColor = AWColorFromRGB(247, 247, 247);
    }
    
    [self bringSubviewToFront:_searchHelpView];
    
    return _searchHelpView;
}

@end

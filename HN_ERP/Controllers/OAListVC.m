//
//  OAListVC.m
//  HN_ERP
//
//  Created by tomwey on 1/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OAListVC.h"
#import "Defines.h"

@interface OAListVC () <SwipeViewDataSource, SwipeViewDelegate, UISearchBarDelegate, AWPagerTabStripDataSource>

@property (nonatomic, strong) AWPagerTabStrip* tabStrip;
@property (nonatomic, strong) SwipeView*       swipeView;

@property (nonatomic, strong) NSArray *states;

/** 保存搜索条件 */
@property (nonatomic, strong) NSMutableDictionary *searchConditions;

@property (nonatomic, strong) UIButton *viewAllBtn;

@end

@implementation OAListVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"流程"
                                                        image:[UIImage imageNamed:@"tab_flow_1.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_flow_click_1.png"]];
//        self.tabBarItem.badgeValue = @"10";
//        [[HNNewFlowCountService sharedInstance] registerObserver:self.tabBarItem];
        [[HNBadgeService sharedInstance] registerObserver:self.tabBarItem forKey:@"_flows"];
    }
    return self;
}

- (void)dealloc
{
    [[HNBadgeService sharedInstance] unregisterObserverForKey:@"_flows"];
    
//    [[HNNewFlowCountService sharedInstance] unregisterObserver:self.tabBarItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"流程";
    
    self.viewAllBtn = AWCreateImageButtonWithColor(@"btn_reset.png",
                                                   [UIColor whiteColor],
                                                   self,
                                                   @selector(resetSearch));
    
    [self.navBar addFluidBarItem:self.viewAllBtn atPosition:FluidBarItemPositionTitleRight];
    
    self.viewAllBtn.hidden = YES;
    
    self.navBar.marginOfFluidItem = 0;
    
    self.contentView.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    // 准备数据
    self.states = @[@{@"name": @"待办",
                      @"state": @"todo"},
                    @{@"name": @"已办",
                      @"state": @"done"},
//                    @{@"name": @"请求",
//                      @"state": @"request"},
                    @{@"name": @"抄送",
                      @"state": @"cc"},
                    @{@"name": @"查询",
                      @"state": @"search"}];
    
    NSMutableArray *stateNames = [[NSMutableArray alloc] init];
    for (id dict in self.states) {
        [stateNames addObject:dict[@"name"]];
    }
    
    /////////
    __weak typeof(self) me = self;
    [self addRightItemWithImage:@"btn_search.png" rightMargin:2 callback:^{
        [me doSearch];
    }];
    
    // 创建标签
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    [self.contentView addSubview:self.tabStrip];
    
    if ( self.params[@"from"] ) {
        self.navBar.title = @"选择流程";
        self.tabStrip.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
//        [self addLeftItemWithView:nil];
//        if (AWOSVersionIsLower(11)) {
//            self.tabStrip.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
//        } else {
            self.tabStrip.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        }
    }
    
    self.tabStrip.tabWidth = self.contentView.width / self.states.count;
    
    self.tabStrip.dataSource = self;
    
    self.tabStrip.titleAttributes = @{ NSForegroundColorAttributeName: AWColorFromRGB(137, 137, 137),
                                  NSFontAttributeName: AWSystemFontWithSize(15, NO) };;
    self.tabStrip.selectedTitleAttributes = @{ NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                  NSFontAttributeName: AWSystemFontWithSize(15, NO) };
    
    __weak typeof(self) weakSelf = self;
    self.tabStrip.didSelectBlock = ^(AWPagerTabStrip* stripper, NSUInteger index) {
//        weakSelf.swipeView.currentPage = index;
        __strong OAListVC *strongSelf = weakSelf;
        if ( strongSelf ) {
            // 如果duration设置为大于0.0的值，动画滚动，tab stripper动画会有bug
            [strongSelf.swipeView scrollToPage:index duration:0.0f]; // 0.35f
        }
    };
    
    // 翻页视图
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0,
                                          self.tabStrip.bottom,
                                          self.tabStrip.width,
                                          self.contentView.height - self.tabStrip.height);
        
        self.swipeView.delegate = self;
        self.swipeView.dataSource = self;
        
        self.swipeView.backgroundColor = self.contentView.backgroundColor;
    }
    
    // 加载第一页数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        OAListView *listView = (OAListView *)self.swipeView.currentItemView;
        listView.from = self.params[@"from"];
        [listView startLoadingForState:self.states[self.swipeView.currentPage][@"state"]];

    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flowHandleSuccess)
                                                 name:@"kFlowHandleSuccessNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearch:)
                                                 name:@"kSearchConditionDidSaveNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doSearch)
                                                 name:@"kForwardToSearchVCNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTodoFlows)
                                                 name:@"kNeedReloadTodoFlowsNotification"
                                               object:nil];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"流程"
                                    keyMemo:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[HNNewFlowCountService sharedInstance] resetNewFlowCount];
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return self.states.count;
}

- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.states[index][@"name"];
}

/** 重新刷新待办 */
- (void)reloadTodoFlows
{
    NSString *state = self.states[[self.swipeView currentPage]][@"state"];
    if ( [state isEqualToString:@"todo"] ) {
        // 当前正处于待办列表，强制刷新待办流程
        OAListView *listView = (OAListView *)[self.swipeView currentItemView];
        listView.from = self.params[@"from"];
        
        [listView forceRefreshForState:state];
    } else {
        // 清空待办的缓存，让下次查看待办时有机会重新获取待办
        // 注意：此处简单处理，清除所有的缓存
        [[HNCache sharedInstance] removeAllCaches];
    }
}

- (void)flowHandleSuccess
{
    [self.tabStrip setSelectedIndex:0 animated:YES];
    
//    [self.swipeView scrollToItemAtIndex:0 duration:0.25];
    [self.swipeView scrollToPage:0 duration:0.0f];
    
    NSString *state = self.states[[self.swipeView currentPage]][@"state"];
    OAListView *listView = (OAListView *)[self.swipeView currentItemView];
    listView.from = self.params[@"from"];
    
    [listView forceRefreshForState:state];
}

- (void)handleSearch:(NSNotification *)noti
{
    id object = noti.object;
    if ( [object isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *currentSearchCondition = [object copy];
        
        NSString *state = nil;
        if ( self.swipeView.currentPage < self.states.count ) {
            state = self.states[self.swipeView.currentPage][@"state"];
            
            // 保存当前的搜索条件
            [self saveSearchCondition:currentSearchCondition forState:state];
            
            // 开始搜索
            [self startSearch:currentSearchCondition forState:state];
        }
    }
}

- (void)doSearch
{
    NSString *state = nil;
    NSString *title = @"搜索";
    NSDictionary *searchCondition = nil;
    if ( self.swipeView.currentPage < self.states.count ) {
        state = self.states[self.swipeView.currentPage][@"state"];
        searchCondition = [self searchConditionForState:state];
        
        if ( [state isEqualToString:@"todo"] ) {
            title = @"待办";
        } else if ( [state isEqualToString:@"cc"] ) {
            title = @"抄送";
        } else if ( [state isEqualToString:@"search"] ) {
            title = @"流程";
        } else if ( [state isEqualToString:@"done"] ) {
            title = @"已办";
        }
    }
    
    NSDictionary *params = nil;
    if ( self.swipeView.currentPage > 0 && self.swipeView.currentPage == self.states.count - 1 ) {
        // 流程查询
        params = @{ @"search_type": @"1", @"search_conditions": searchCondition ?:@{} };
    } else {
        params = @{ @"search_type": @"0", @"search_conditions": searchCondition ?:@{} };
    }
    
    NSMutableDictionary *newParams = [params mutableCopy];
    newParams[@"title"] = title;
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"SearchConditionVC" params:[newParams copy]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.states count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    OAListView *listView = (OAListView *)view;
    if ( !listView ) {
        listView = [[OAListView alloc] init];
        listView.frame = swipeView.bounds;
        view = listView;
    }
    
    id state = self.states[index];
    listView.searchCondition = [self searchConditionForState:state[@"state"]];
    listView.state = state[@"state"];
    listView.from = self.params[@"from"];
    
    return listView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    NSLog(@"index: %d", swipeView.currentPage);
    
    // 更新标签状态
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    // 按需添加重置搜索按钮
    [self addResetSearchButtonIfNeeded];
    
    // 加载数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDataForIndex:self.swipeView.currentPage];
    });
}

- (void)loadDataForIndex:(NSInteger)index
{
    if ( index < self.states.count ) {
        OAListView *listView = (OAListView *)self.swipeView.currentItemView;
        id state = self.states[index];
        listView.from = self.params[@"from"];
        [listView startLoadingForState:state[@"state"]];
    }
}

- (void)addResetSearchButtonIfNeeded
{
    NSInteger index = self.swipeView.currentPage;
    if ( index < self.states.count ) {
        NSString *state = self.states[index][@"state"];
        [self addResetSearchButtonForState:state];
    }
}

- (void)addResetSearchButtonForState:(NSString *)state
{
    if ( [state isEqualToString:@"search"] ) {
        // 流程查询不需要重置，保留用户上一次的搜索结果
//        [self addLeftItemWithView:nil];
        self.viewAllBtn.hidden = YES;
    } else {
        NSDictionary *searchDictionary = [self searchConditionForState:state];
        if ( searchDictionary.count > 0 ) {
            self.viewAllBtn.hidden = NO;
            // 当前状态已经搜索过
//            __weak typeof(self) weakSelf = self;
//            
//            NSDictionary *titleAttributes = @{ NSFontAttributeName: AWSystemFontWithSize(16, NO) };
//            CGSize size = [@"查看所有" sizeWithAttributes:titleAttributes];
//            size.width += 20;
//            size.height = 40;
//            
//            [self addLeftItemWithTitle:@"查看所有"
//                       titleAttributes:titleAttributes
//                                  size:size
//                            leftMargin:5
//                              callback:^{
//                                  __strong OAListVC *strongSelf = weakSelf;
//                                  if ( strongSelf ) {
//                                      [strongSelf resetSearchConditionForState:state];
//                                  }
//                              }];
        } else {
//            [self addLeftItemWithView:nil];
            self.viewAllBtn.hidden = YES;
        }
    }
}

// 开始搜索
- (void)startSearch:(NSDictionary *)searchCondition forState:(NSString *)state
{
    // 根据状态添加清除按钮
    [self addResetSearchButtonForState:state];
    
    UIView *view = self.swipeView.currentItemView;
    if ( [view isKindOfClass:[OAListView class]] ) {
        OAListView *listView = (OAListView *)view;
        listView.searchCondition = searchCondition;
        listView.state = state;
        listView.from = self.params[@"from"];
        
        [listView forceRefreshForState:state];
    }
}

- (void)resetSearch
{
    NSInteger index = self.swipeView.currentPage;
    if ( index < self.states.count ) {
        NSString *state = self.states[index][@"state"];
        [self resetSearchConditionForState:state];
    }
}

// 重置搜索
- (void)resetSearchConditionForState:(NSString *)state
{
    [self.searchConditions removeObjectForKey:state];
    
    [self startSearch:@{} forState:state];
}

// 保存搜索状态
- (void)saveSearchCondition:(NSDictionary *)searchCondition
                   forState:(NSString *)state
{
    if ( state ) {
        self.searchConditions[state] = searchCondition ?: @{};
    }
}

- (NSDictionary *)searchConditionForState:(NSString *)state
{
    if ( !state ) return nil;
    id object = self.searchConditions[state];
    if ( !object ) {
        object = @{};
        self.searchConditions[state] = object;
    }
    
    if ( [object isKindOfClass:[NSDictionary class]] ) {
        return (NSDictionary *)object;
    }
    
    return nil;
}

- (NSMutableDictionary *)searchConditions
{
    if ( !_searchConditions ) {
        _searchConditions = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _searchConditions;
}

@end

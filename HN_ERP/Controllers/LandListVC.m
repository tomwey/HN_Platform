//
//  LandListVC.m
//  HN_ERP
//
//  Created by tomwey on 4/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandListVC.h"
#import "Defines.h"

@interface LandListVC () <SwipeViewDelegate, SwipeViewDataSource, AWPagerTabStripDataSource, AWPagerTabStripDelegate>

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) SwipeView       *swipeView;

@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) NSMutableDictionary *searchConditions;

@property (nonatomic, strong) UIButton *viewAllBtn;

@end

@implementation LandListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"土地信息";
    
    __weak typeof(self) me = self;
    [self addRightItemWithImage:@"btn_search.png" rightMargin:2 callback:^{
        [me doSearch];
    }];
    
    self.viewAllBtn = AWCreateImageButtonWithColor(@"btn_reset.png",
                                                   [UIColor whiteColor],
                                                   self,
                                                   @selector(resetSearch));
    
    [self.navBar addFluidBarItem:self.viewAllBtn atPosition:FluidBarItemPositionTitleRight];
    
    self.viewAllBtn.hidden = YES;
    
    self.navBar.marginOfFluidItem = 0;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.tabTitles = @[@{
                           @"name": @"全部",
                           @"type": @"0",
                           },
                       @{
                           @"name": @"立项",
                           @"type": @"1",
                           },
                       @{
                           @"name": @"放弃",
                           @"type": @"2",
                           },
                       @{
                           @"name": @"已成交",
                           @"type": @"3",
                           },
                       ];
    
    // 创建标签
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.tabStrip.tabWidth = self.contentView.width / self.tabTitles.count;
    
    self.tabStrip.titleAttributes = @{ NSForegroundColorAttributeName: AWColorFromRGB(137, 137, 137),
                                       NSFontAttributeName: AWSystemFontWithSize(14, NO) };;
    self.tabStrip.selectedTitleAttributes = @{ NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                               NSFontAttributeName: AWSystemFontWithSize(14, NO) };
    
//    self.tabStrip.delegate   = self;
    self.tabStrip.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    self.tabStrip.didSelectBlock = ^(AWPagerTabStrip* stripper, NSUInteger index) {
        //        weakSelf.swipeView.currentPage = index;
        __strong LandListVC *strongSelf = weakSelf;
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
        [self loadDataForCurrentPage];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNoti:) name:@"kNeedSearchNotification" object:nil];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"土地信息"
                                    keyMemo:nil];
}

- (void)resetSearch
{
    if ( self.swipeView.currentPage < self.tabTitles.count ) {
        id item = self.tabTitles[self.swipeView.currentPage];
        [self resetSearchConditionForItem:item];
    }
}

- (void)handleNoti:(NSNotification *)noti
{
    id object = noti.object;
    if ( [object isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *currentSearchCondition = [object copy];
        
        if ( self.swipeView.currentPage < self.tabTitles.count ) {
            id item = self.tabTitles[self.swipeView.currentPage];
            
            // 保存当前的搜索条件
            [self saveSearchCondition:currentSearchCondition forItem:item];
            
            [self addResetSearchButtonForItem:item];
            
            // 开始搜索
            [self loadDataForCurrentPage];
//            [self startSearchCondition:currentSearchCondition forItem:item];
        }
    }
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return [self.tabTitles count];
}
- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index][@"name"];
}

- (CGFloat)pagerTabStrip:(AWPagerTabStrip *)tabStrip tabWidthForIndex:(NSInteger)index
{
    NSString *title = self.tabTitles[index][@"name"];
    
    CGSize size = [title sizeWithAttributes:self.tabStrip.titleAttributes];
    NSLog(@"width: %f", size.width);
    return size.width + 24;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.tabTitles count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    LandListView *listView = nil;//(LandListView *)view;
    if ( !listView ) {
        listView = [[LandListView alloc] init];
        listView.frame = swipeView.bounds;
        view = listView;
        
        __weak LandListVC *weakSelf = self;
        listView.didSelectItemBlock = ^(LandListView *sender, id selectedItem) {
            [weakSelf openDetailPageWithItem:selectedItem];
        };
    }
    
    id item = self.tabTitles[index];
    
    listView.searchCondition = [self searchConditionForItem:item];
    listView.item = item;
    
    return listView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
//    NSLog(@"index: %d", swipeView.currentPage);
    
    // 更新标签状态
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    // 按需添加重置搜索按钮
    NSInteger index = self.swipeView.currentPage;
    if ( index < self.tabTitles.count ) {
        id item = self.tabTitles[index];
        [self addResetSearchButtonForItem:item];
    }
    
    // 加载数据
    [self loadDataForCurrentPage];
//    [self loadDataForIndex:self.swipeView.currentPage];
}

- (void)openDetailPageWithItem:(id)item
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"LandDetailVC" params:@{ @"item": item ?: @{} }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadDataForCurrentPage
{
    LandListView *listView = (LandListView *)[self.swipeView currentItemView];
    if ( self.swipeView.currentPage < self.tabTitles.count ) {
        NSInteger currentPage = self.swipeView.currentPage;
        if ( currentPage < self.tabTitles.count ) {
            id item = self.tabTitles[currentPage];
            listView.searchCondition = [self searchConditionForItem:item];
            listView.item = item;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [listView startLoading];
            });
        }
    }
}

- (void)doSearch
{
    id item = self.tabTitles[self.swipeView.currentPage];
    
    NSString *title = self.tabTitles[self.swipeView.currentPage][@"name"];
    title = [title stringByAppendingString:@"土地搜索"];
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"LandSearchVC" params:@{ @"title": title, @"search_conditions" : [self searchConditionForItem:item] ?: @{} }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)addResetSearchButtonForItem:(id)item
{
    NSLog(@"search condition: %@", [self searchConditionForItem:item]);
    self.viewAllBtn.hidden = !([[self searchConditionForItem:item] count] > 0);
}

// 开始搜索
- (void)startSearch:(NSDictionary *)searchCondition forItem:(id)item
{
    // 根据状态添加清除按钮
    [self addResetSearchButtonForItem:item];
    
    UIView *view = self.swipeView.currentItemView;
    if ( [view isKindOfClass:[LandListView class]] ) {
        LandListView *listView = (LandListView *)view;
        listView.searchCondition = searchCondition;
        listView.item = item;
        
        [listView forceRefreshing];
    }
}

// 重置搜索
- (void)resetSearchConditionForItem:(id)item
{
    [self.searchConditions removeObjectForKey:item[@"name"]];
    
    [self startSearch:@{} forItem:item];
}

// 保存搜索状态
- (void)saveSearchCondition:(NSDictionary *)searchCondition
                    forItem:(id)item
{
    if ( item && item[@"name"] ) {
        self.searchConditions[[item[@"name"] description]] = searchCondition ?: @{};
    }
}

- (NSDictionary *)searchConditionForItem:(id)item
{
    if ( !item || !item[@"name"] ) return nil;
    id object = self.searchConditions[[item[@"name"] description]];
    if ( !object ) {
        object = @{};
        self.searchConditions[[item[@"name"] description]] = object;
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

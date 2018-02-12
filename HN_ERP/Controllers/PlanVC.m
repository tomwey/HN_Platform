//
//  PlanVC.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanVC.h"
#import "Defines.h"

@interface PlanVC () <UITableViewDelegate,AWPagerTabStripDataSource, AWPagerTabStripDelegate, SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) SwipeView *swipeView;

@property (nonatomic, strong) NSMutableDictionary *swipeSubviews;

@property (nonatomic, strong) UISegmentedControl *segControl;

@end

@implementation PlanVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"计划";
    
//    [self addRightItemWithView:self.segControl rightMargin:10];
    
    // 创建滚动标签
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    self.tabStrip.dataSource = self;
    self.tabStrip.delegate   = self;
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.tabStrip.titleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: AWColorFromRGB(137,137,137) };
    self.tabStrip.selectedTitleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: MAIN_THEME_COLOR };
    
    self.swipeView = [[SwipeView alloc] initWithFrame:
                      CGRectMake(0, self.tabStrip.bottom,
                                 self.contentView.width, self.contentView.height - self.tabStrip.bottom)];
    [self.contentView addSubview:self.swipeView];
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate   = self;
    
    // 加载数据
    self.tabTitles = @[@"总控", @"专项"];
    
    self.tabStrip.tabWidth = (self.contentView.width / self.tabTitles.count);
    
    [self.tabStrip reloadData];
    
    [self.swipeView reloadData];
    
    // 加载第一页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self doSearch:@""];
        PlanProjectView *listView = (PlanProjectView *)[self swipeSubviewForIndex:0];
        listView.userData = @"0";
//        listView.didSelectBlock = ^(PlanListView *sender, id selectedItem) {
//            UIViewController *vc =
//                [[AWMediator sharedInstance] openVCWithName:@"PlanDetailVC"
//                                                     params:selectedItem ?: @{}];
//            [self.navigationController pushViewController:vc animated:YES];
//        };
//        listView.dataType = -1;
        [listView startLoading];
    });
    
    id user = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"总控计划列表查询APP",
              @"param1": [user[@"man_id"] ?: @"0" description],
              @"param2": @"0",
              @"param3": @"1",
              } completion:^(id result, NSError *error) {
                  
              }];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.tabTitles.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *aView = [self swipeSubviewForIndex:index];
    return aView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *view = [self swipeSubviewForIndex:swipeView.currentPage];
        view.userData = [@(swipeView.currentPage) description];
        
        [view performSelector:@selector(startLoading) withObject:nil];
    });
    
//    if ( self.swipeView.currentPage == 0 ) {
//        [self addRightItemWithView:self.segControl rightMargin:10];
//    } else {
//        [self addRightItemWithView:nil];
//        _segControl = nil;
//    }
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return [self.tabTitles count];
}

- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index];
}

- (void)pagerTabStrip:(AWPagerTabStrip *)tabStrip didSelectTabAtIndex:(NSInteger)index
{
    self.swipeView.currentPage = index;
    //    [self.swipeView scrollToPage:index duration:.3];
}

- (UIView *)swipeSubviewForIndex:(NSInteger)index
{
    static const int viewCount = 2;
    static NSString * viewNames[viewCount] = {
                                      //@"PlanListView",
                                      @"PlanProjectView",
                                      @"PlanProjectView"
                                    };
    
    if  ( index >= viewCount ) {
        return nil;
    }
    
    UIView *view = self.swipeSubviews[@(index)];
    if ( !view ) {
        view = [[NSClassFromString(viewNames[index]) alloc] init];
        view.frame = self.swipeView.bounds;
        self.swipeSubviews[@(index)] = view;
        
        if ([view isKindOfClass:[PlanProjectView class]]) {
            PlanProjectView *projView = (PlanProjectView *)view;
            __weak typeof(self) me = self;
            projView.didSelectItem = ^(PlanProjectView *sender, id inItem) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": inItem }];
                [me.navigationController pushViewController:vc animated:YES];
            };
        }
    }
    return view;
}

- (void)segDidChange:(id)sender
{
    UIView *currentView = self.swipeView.currentItemView;
    if ( [currentView isKindOfClass:[PlanListView class]] ) {
        PlanListView *listView = (PlanListView *)currentView;
        listView.dataType = self.segControl.selectedSegmentIndex == 0 ? -1 : 0;
        [listView startLoading];
    }
}

- (NSMutableDictionary *)swipeSubviews
{
    if ( !_swipeSubviews ) {
        _swipeSubviews = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _swipeSubviews;
}

- (UISegmentedControl *)segControl
{
    if ( !_segControl ) {
        _segControl = [[UISegmentedControl alloc] initWithItems:@[@"全部", @"未完成"]];
        _segControl.frame = CGRectMake(0, 0, 88, 25);
        [_segControl setTitleTextAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(10, NO) } forState:UIControlStateNormal];
        _segControl.tintColor = [UIColor whiteColor];
        _segControl.selectedSegmentIndex = 0;
        [_segControl addTarget:self
                        action:@selector(segDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segControl;
}

@end

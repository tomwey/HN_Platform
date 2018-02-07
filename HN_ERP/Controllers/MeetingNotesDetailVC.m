//
//  MeetingNotesDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 7/28/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingNotesDetailVC.h"
#import "Defines.h"
#import "MeetingBaseInfoView.h"
#import "TracePlanListView.h"

@interface MeetingNotesDetailVC () <AWPagerTabStripDataSource, AWPagerTabStripDelegate, SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) SwipeView *swipeView;

@property (nonatomic, strong) MeetingBaseInfoView *baseInfoView;
@property (nonatomic, strong) TracePlanListView   *listView;

@end

@implementation MeetingNotesDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"会议纪要详情";
    
    // 创建滚动标签
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    self.tabStrip.dataSource = self;
    self.tabStrip.delegate   = self;
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.tabStrip.titleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: AWColorFromRGB(137,137,137) };
    self.tabStrip.selectedTitleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: MAIN_THEME_COLOR };
    
    // 添加滚动试图
    self.swipeView = [[SwipeView alloc] initWithFrame:
                      CGRectMake(0, self.tabStrip.bottom,
                                 self.contentView.width, self.contentView.height - self.tabStrip.bottom)];
    [self.contentView addSubview:self.swipeView];
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate   = self;
    
    // 加载数据
    self.tabTitles = @[@"基本信息",@"跟踪与计划"];
    
    self.tabStrip.tabWidth = (self.contentView.width / self.tabTitles.count);
    
    [self.tabStrip reloadData];
    
    [self.swipeView reloadData];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.tabTitles.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if ( index == 0 ) {
        // 基本信息
        self.baseInfoView.meetingNotesData = self.params;
        
        return self.baseInfoView;
    }
    
    if ( index == 1 ) {
        // 跟踪与计划
        self.listView.id_ = [self.params[@"id"] description];
        
        return self.listView;
    }
    
    return nil;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    if ( swipeView.currentPage == 1 ) {
        [self.listView startLoading:nil];
    }
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

- (MeetingBaseInfoView *)baseInfoView
{
    if ( !_baseInfoView ) {
        _baseInfoView = [[MeetingBaseInfoView alloc] init];
        _baseInfoView.frame = self.swipeView.bounds;
        
        _baseInfoView.navigationController = self.navigationController;
//        _baseInfoView.meetingNotesData = self.params;
    }
    return _baseInfoView;
}

- (TracePlanListView *)listView
{
    if ( !_listView ) {
        _listView = [[TracePlanListView alloc] init];
        _listView.frame = self.swipeView.bounds;
    }
    return _listView;
}

@end

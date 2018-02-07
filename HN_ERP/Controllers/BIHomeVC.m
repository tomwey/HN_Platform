//
//  BIHomeVC.m
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BIHomeVC.h"
#import "Defines.h"
#import "BIVIewProtocol.h"

@interface BIHomeVC () <SwipeViewDelegate, SwipeViewDataSource, AWPagerTabStripDataSource, AWPagerTabStripDelegate>

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) SwipeView       *swipeView;

@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) NSMutableDictionary *swipePages;

@property (nonatomic, strong) NSArray *areaData;
@property (nonatomic, strong) id userDefaultArea;

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation BIHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"经营分析";
    
    self.contentView.backgroundColor = AWColorFromRGB(254, 254, 254);
    
    self.tabTitles = @[@{
                           @"name": @"签约回款",
                           @"type": @"0",
                           @"page": @"ConFeeView",
                           },
                       @{
                           @"name": @"剩余货值",
                           @"type": @"1",
                           @"page": @"RemainStockView",
                           },
//                       @{
//                           @"name": @"价格趋势",
//                           @"type": @"2",
//                           @"page": @"PriceTrendView",
//                           },
                       @{
                           @"name": @"成交溢价",
                           @"type": @"3",
                           @"page": @"DealOverflowView",
                           },
                       @{
                           @"name": @"热销排名",
                           @"type": @"4",
                           @"page": @"HotSaleRankView",
                           },
                       ];
    
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = MAIN_THEME_COLOR;
    
    self.tabStrip.tabWidth = 88;//self.contentView.width / self.tabTitles.count;
    
//    self.tabStrip.top = -5;
//    self.tabStrip.height = 50;
    
    self.tabStrip.titleAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: AWSystemFontWithSize(14, NO) };;
    self.tabStrip.selectedTitleAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                               NSFontAttributeName: AWSystemFontWithSize(14, NO) };
    
    //    self.tabStrip.delegate   = self;
    self.tabStrip.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    self.tabStrip.didSelectBlock = ^(AWPagerTabStrip* stripper, NSUInteger index) {
        //        weakSelf.swipeView.currentPage = index;
        __strong BIHomeVC *strongSelf = weakSelf;
        if ( strongSelf ) {
            // 如果duration设置为大于0.0的值，动画滚动，tab stripper动画会有bug
            [strongSelf.swipeView scrollToPage:index duration:0.0f]; // 0.35f
            [strongSelf swipeViewDidEndDecelerating:strongSelf.swipeView];
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
    
//    [self pageStartLoadingData];
    [self startLoadAreaData];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"经营分析"
                                    keyMemo:nil];
}

- (void)startLoadAreaData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI区域权限查询APP",
              @"param1": manID,
              //              @"param2": @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
        [self.contentView showHUDWithText:@"获取区域失败" succeed:NO];
    } else {
        [self prepareAreaData:result];
    }
    
}

- (void)prepareAreaData:(id)result
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
        self.areaData = result[@"data"];
    } else {
        self.areaData = nil;
        
        [self.contentView showHUDWithText:@"没有查看权限" succeed:NO];
        
        return;
    }
    
    // 处理用户默认区域
    self.userDefaultArea = [self fetchUserDefaultArea:self.areaData];
    
    [self pageStartLoadingData];
}

- (id)fetchUserDefaultArea:(NSArray *)areaData
{
    if ( areaData.count == 0 ) {
        return nil;
    }
    
    id user = [[UserService sharedInstance] currentUser];
    
    // 如果有默认区域，返回默认区域
    for (id area in areaData) {
        if ( [area[@"area_id"] integerValue] == [user[@"area_id"] integerValue] ) {
            return area;
        }
    }
    
    // 否则返回第一个区域，注：第一个数据默认后台返回的是全集团
    return [areaData firstObject];
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return [self.tabTitles count];
}
- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index][@"name"];
}

//- (CGFloat)pagerTabStrip:(AWPagerTabStrip *)tabStrip tabWidthForIndex:(NSInteger)index
//{
//    NSString *title = self.tabTitles[index][@"name"];
//    
//    CGSize size = [title sizeWithAttributes:self.tabStrip.titleAttributes];
//    NSLog(@"width: %f", size.width);
//    return size.width + 24;
//}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.tabTitles count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    return [self swipePageForIndex:index];
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    //    NSLog(@"index: %d", swipeView.currentPage);
    
    // 更新标签状态
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
//    [self pageStartLoadingData];
}

- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
    self.currentPage = self.swipeView.currentPage;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    NSLog(@"end decelerate");
    if ( self.currentPage != self.swipeView.currentPage ) {
        self.currentPage = self.swipeView.currentPage;
        
        [self startLoadingData];
    }
}

- (void)swipeViewDidEndScrollingAnimation:(SwipeView *)swipeView
{
    NSLog(@"end scrolling");
}

- (void)pageStartLoadingData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startLoadingData];
    });
}

- (void)startLoadingData
{
    UIView <BIViewProtocol> *view = [self swipePageForIndex:self.swipeView.currentPage];
    //        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    [view startLoadingData:^(BOOL succeed, NSError *error) {
        //            [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    }];
}

- (NSString *)swipePageNameForIndex:(NSInteger)index
{
    if ( index < self.tabTitles.count ) {
        return self.tabTitles[index][@"page"];
    }
    return nil;
}

- (UIView <BIViewProtocol> *)swipePageForIndex:(NSInteger)index
{
    NSString *pageName = [self swipePageNameForIndex:index];
    if ( !pageName ) {
        return nil;
    }
    
    UIView <BIViewProtocol> *view = self.swipePages[pageName];
    if ( !view ) {
        view = [[NSClassFromString(pageName) alloc] init];
        view.frame = CGRectMake(0, 0, self.swipeView.width, self.swipeView.height);
        if (view) {
            self.swipePages[pageName] = view;
        }
    }
    
    view.userDefaultArea = self.userDefaultArea;
    view.areaData = self.areaData;
    view.navController = self.navigationController;
    
    return view;
}

- (NSMutableDictionary *)swipePages
{
    if ( !_swipePages ) {
        _swipePages = [[NSMutableDictionary alloc] init];
    }
    return _swipePages;
}

@end

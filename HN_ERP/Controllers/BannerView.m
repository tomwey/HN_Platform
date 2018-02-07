//
//  BannerView.m
//  HN_ERP
//
//  Created by tomwey on 4/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BannerView.h"
#import <objc/runtime.h>

@interface BannerView () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong, readwrite) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *autoScrollTimer;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableDictionary  *viewControllers;

@end

@interface UIViewController (PageIndex)

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation UIViewController (PageIndex)

static char kUIViewControllerPageIndexKey;

- (void)setPageIndex:(NSInteger)pageIndex
{
    objc_setAssociatedObject(self, &kUIViewControllerPageIndexKey,
                             @(pageIndex), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)pageIndex
{
    id obj = objc_getAssociatedObject(self, &kUIViewControllerPageIndexKey);
    if (!obj) {
        return -1;
    }
    
    return [obj integerValue];
}

@end

@implementation BannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _autoScrollInterval = 3.0;
    _autoScroll = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroud) name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroud) name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(tap)]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"正确释放了...");
}

- (void)appWillEnterForegroud
{
    [self resume];
}

- (void)appDidEnterBackgroud
{
    [self pause];
}

- (void)tap
{
    if ( self.didSelectItemBlock ) {
        self.didSelectItemBlock(self, self.pageControl.currentPage);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.pageViewController.view.frame = self.bounds;
    
    self.pageControl.frame = CGRectMake(CGRectGetWidth(self.bounds) - 60 - 3,
                                        CGRectGetHeight(self.bounds) - 30,
                                        60,
                                        30);
}

- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    
    if ( !autoScroll ) {
        [_autoScrollTimer invalidate];
        _autoScrollTimer = nil;
    }
}

- (void)setAutoScrollInterval:(NSTimeInterval)autoScrollInterval
{
    _autoScrollInterval = autoScrollInterval;
    
    [_autoScrollTimer invalidate];
    _autoScrollTimer = nil;
    
    if ( self.autoScroll ) {
        [self.autoScrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:autoScrollInterval]];
    }
}

- (void)setDataSource:(id<BannerViewDataSource>)dataSource
{
    if ( _dataSource == dataSource ) {
        return;
    }
    
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)reloadData
{
    NSInteger count = [self.dataSource numberOfItemsInBannerView:self];
    if ( count <= 0 ) return;
    
    self.pageViewController.dataSource = self;
    
    self.pageControl.numberOfPages = count;
    
    // 滚动到第一页
    [self scrollToPage:0 animated:NO];
    
    [self stop];
    
    // 一定时间后启动定时器
    if ( self.autoScroll && self.pageControl.numberOfPages > 1 ) {
        [self.autoScrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.autoScrollInterval]];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIPageViewController dataSource
////////////////////////////////////////////////////////////////////////////////
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger count = [self.dataSource numberOfItemsInBannerView:self];
    
    if ( count <= 1 ) {
        return nil;
    }
    
    NSInteger index = viewController.pageIndex - 1;
    if ( index < 0 ) {
        index = count - 1;
    }
    
    return [self viewControllerAtIndex:index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger count = [self.dataSource numberOfItemsInBannerView:self];
    
    if ( count <= 1 ) {
        return nil;
    }
    
    NSInteger index = viewController.pageIndex + 1;
    if ( index > count - 1 ) {
        index = 0;
    }
    
    return [self viewControllerAtIndex:index];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIPageViewController delegate
////////////////////////////////////////////////////////////////////////////////
- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    // 暂停自动滚动
    [self.autoScrollTimer setFireDate:[NSDate distantFuture]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    // 启动自动滚动
    NSInteger count = [self.dataSource numberOfItemsInBannerView:self];
    
    if ( count > 1 && self.autoScroll ) {
        [self.autoScrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.autoScrollInterval]];
    }
    
    if ( completed ) {
        
        UIViewController* bvc = [pageViewController.viewControllers firstObject];
        self.pageControl.currentPage = bvc.pageIndex;
    }
}

- (void)pause
{
    [self.autoScrollTimer setFireDate:[NSDate distantFuture]];
}

- (void)resume
{
    [self.autoScrollTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.autoScrollInterval]];
}

- (void)stop
{
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
}

- (NSTimer *)autoScrollTimer
{
    if ( !_autoScrollTimer ) {
        _autoScrollTimer = [NSTimer timerWithTimeInterval:self.autoScrollInterval
                                                   target:self
                                                 selector:@selector(autoScroll:)
                                                 userInfo:nil
                                                  repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_autoScrollTimer forMode:NSRunLoopCommonModes];
        
        [_autoScrollTimer setFireDate:[NSDate distantFuture]];
    }
    return _autoScrollTimer;
}

- (void)autoScroll:(id)sender
{
    NSInteger page = self.pageControl.currentPage + 1;
    if ( page == self.pageControl.numberOfPages ) {
        page = 0;
    }
    
    [self scrollToPage:page animated:YES];
}

- (void)pageControlValueChanged:(id)sender
{
    [self scrollToPage:self.pageControl.currentPage animated:YES];
}

- (void)scrollToPage:(NSInteger)pageIndex animated:(BOOL)animated
{
    self.pageControl.currentPage = pageIndex;
    
    UIViewController *vc = [self viewControllerAtIndex:pageIndex];
    if ( vc ) {
        [self.pageViewController setViewControllers:@[vc]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:animated
                                         completion:^(BOOL finished) {
                                             
                                         }];
    }
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)pageIndex
{
    id key = [@(pageIndex) description];
    UIViewController *vc = self.viewControllers[key];
    if ( !vc ) {
        vc = [[UIViewController alloc] init];
        self.viewControllers[key] = vc;
        vc.pageIndex = pageIndex;
        vc.view.frame = self.pageViewController.view.bounds;
    }
    
    if ( [self.dataSource respondsToSelector:@selector(bannerView:viewForItemAtIndex:reusingView:)] ) {
        
        UIView *oldView = [vc.view viewWithTag:10011];
        if ( !oldView ) {
            oldView = [self.dataSource bannerView:self viewForItemAtIndex:pageIndex reusingView:nil];
            [vc.view addSubview:oldView];
            oldView.tag = 10011;
        } else {
            [self.dataSource bannerView:self
                     viewForItemAtIndex:pageIndex
                            reusingView:oldView];
        }
    }
    
    return vc;
}

- (UIPageControl *)pageControl
{
    if ( !_pageControl ) {
        _pageControl = [[UIPageControl alloc] init];
        [self addSubview:_pageControl];
        _pageControl.hidesForSinglePage = YES;
        
        [_pageControl addTarget:self
                         action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (UIPageViewController *)pageViewController
{
    if ( !_pageViewController ) {
        _pageViewController =
            [[UIPageViewController alloc] initWithTransitionStyle:
                UIPageViewControllerTransitionStyleScroll
                                            navigationOrientation:
                UIPageViewControllerNavigationOrientationHorizontal
                                                          options:nil];
        
        [self addSubview:_pageViewController.view];
        _pageViewController.delegate = self;
    }
    return _pageViewController;
}

- (NSMutableDictionary *)viewControllers
{
    if ( !_viewControllers ) {
        _viewControllers = [[NSMutableDictionary alloc] init];
    }
    return _viewControllers;
}

@end

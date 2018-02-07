//
//  BannerView.h
//  HN_ERP
//
//  Created by tomwey on 4/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BannerViewDataSource;

@interface BannerView : UIView

@property (nonatomic, weak) id <BannerViewDataSource> dataSource;

/** 自动轮播的时间间隔，默认为3.0 */
@property (nonatomic, assign) NSTimeInterval autoScrollInterval;

/** 默认为YES，注意：释放该对象之前，需设置该属性的值为NO来关闭定时器 */
@property (nonatomic, assign) BOOL autoScroll;

@property (nonatomic, copy) void (^didSelectItemBlock)(BannerView *sender, NSInteger index);

@property (nonatomic, strong, readonly) UIPageControl *pageControl;

- (void)reloadData;

- (void)pause;
- (void)resume;
- (void)stop;

@end

@protocol BannerViewDataSource <NSObject>

@required

- (NSInteger)numberOfItemsInBannerView:(BannerView *)bannerView;

- (UIView *)bannerView:(BannerView *)bannerView
  viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@optional

@end

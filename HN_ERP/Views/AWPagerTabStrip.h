//
//  AWPagerTabStrip.h
//  HN_ERP
//
//  Created by tomwey on 2/8/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class AWPagerTabStrip;
@protocol AWPagerTabStripDelegate;

@protocol AWPagerTabStripDataSource <NSObject>

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip;
- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index;

@end

@interface AWPagerTabStrip : UIView

@property (nonatomic, weak) id <AWPagerTabStripDataSource> dataSource;
@property (nonatomic, weak) id <AWPagerTabStripDelegate>   delegate;

@property (nonatomic, assign) CGFloat tabWidth; // 默认为60

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, copy) NSDictionary<NSString*, id>* titleAttributes;
@property (nonatomic, copy) NSDictionary<NSString*, id>* selectedTitleAttributes;

@property (nonatomic, assign) BOOL allowShowingIndicator;

@property (nullable, nonatomic, copy) void (^didSelectBlock)(AWPagerTabStrip*, NSUInteger);

@property (nonatomic, assign) NSUInteger selectedIndex;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (void)reloadData;

@end

@protocol AWPagerTabStripDelegate <NSObject>

@optional
- (CGFloat)pagerTabStrip:(AWPagerTabStrip *)tabStrip tabWidthForIndex:(NSInteger)index;

- (void)pagerTabStrip:(AWPagerTabStrip *)tabStrip didSelectTabAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

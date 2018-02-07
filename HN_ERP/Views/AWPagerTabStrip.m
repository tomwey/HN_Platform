//
//  PagerTabStripper.m
//  zgnx
//
//  Created by tomwey on 5/25/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "AWPagerTabStrip.h"

@interface AWPagerTabStrip ()

@property (nonatomic, strong, readwrite) UIScrollView* scrollView;

@property (nonatomic, strong) NSMutableArray* stripperArray;

@property (nonatomic, strong) UIView* tabIndicator;

@property (nonatomic, assign) UIView* lastItem;

@end

@implementation AWPagerTabStrip

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]),
                             40);
    
    self.scrollView = [[UIScrollView alloc] init];
    [self addSubview:self.scrollView];
    
    self.scrollView.frame = self.bounds;
    
    //    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.scrollView.showsVerticalScrollIndicator =
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    _titleAttributes = [@{ NSFontAttributeName: [UIFont systemFontOfSize:15],
                          NSForegroundColorAttributeName : [UIColor blackColor]
                        } copy];
    _selectedTitleAttributes = [@{ NSFontAttributeName: [UIFont systemFontOfSize:15],
                                   NSForegroundColorAttributeName : [UIColor redColor]
                                   } copy];
    
    self.stripperArray = [NSMutableArray array];
    
    _allowShowingIndicator = YES;
    _tabWidth = 60;
    
    _selectedIndex = 0;
}

- (void)setDataSource:(id<AWPagerTabStripDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)calcuScrollViewContentSizeForCount:(NSInteger)count
{
    CGFloat sumWidth = 0;
    if ( [self.delegate respondsToSelector:@selector(pagerTabStrip:tabWidthForIndex:)] ) {
        for (int i=0; i<count; i++) {
            sumWidth += [self.delegate pagerTabStrip:self tabWidthForIndex:i];
        }
    } else {
        sumWidth = self.tabWidth * count;
    }
    
    self.scrollView.contentSize = CGSizeMake(sumWidth, CGRectGetHeight(self.scrollView.frame));
}

- (void)resetTabs
{
    for (UIView* item in self.stripperArray) {
        [item removeFromSuperview];
    }
    
    [self.stripperArray removeAllObjects];
}

- (void)recreateTabsForCount:(NSInteger)count
{
    CGFloat posX = 0;
    for (int i=0; i<count; i++) {
        CGFloat width = self.tabWidth;
        if ( [self.delegate respondsToSelector:@selector(pagerTabStrip:tabWidthForIndex:)] ) {
            width = [self.delegate pagerTabStrip:self tabWidthForIndex:i];
//            NSLog(@"width: %f", width);
        }
        
        CGRect frame = CGRectMake(posX, 0, width, CGRectGetHeight(self.frame));
        UIView *tab = [[UIView alloc] initWithFrame:frame];
        [self.scrollView addSubview:tab];
        
        tab.tag = i;
        
        posX = CGRectGetMaxX(tab.frame);
        
        [self.stripperArray addObject:tab];
        
        // 添加标题
        UILabel* titleLabel = [[UILabel alloc] init];
        titleLabel.frame = tab.bounds;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [tab addSubview:titleLabel];
        titleLabel.text = [self.dataSource pagerTabStrip:self titleForIndex:i];
        titleLabel.tag = 1101;
        titleLabel.font = self.titleAttributes[NSFontAttributeName];
        titleLabel.textColor = self.titleAttributes[NSForegroundColorAttributeName];
        
        // 添加点击手势
        [tab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
}

- (void)reloadData
{
    // 获取所有的标签
    NSInteger count = count = [self.dataSource numberOfTabs:self];
    if ( count <= 0 ) {
        return;
    }
    
    // 重置标签
    [self resetTabs];
    
    // 重新计算滚动大小
    [self calcuScrollViewContentSizeForCount:count];
    
    // 重新生成标签
    [self recreateTabsForCount:count];
    
    self.selectedIndex = 0;
    
    self.tabIndicator.hidden = !self.allowShowingIndicator;
}

- (UIView *)tabIndicator
{
    if ( !_tabIndicator ) {
        _tabIndicator = [[UIView alloc] init];
        _tabIndicator.backgroundColor = self.selectedTitleAttributes[NSForegroundColorAttributeName];
        [self.scrollView addSubview:_tabIndicator];
    }
    return _tabIndicator;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setAllowShowingIndicator:(BOOL)allowShowingIndicator
{
    _allowShowingIndicator = allowShowingIndicator;
    
    self.tabIndicator.hidden = !allowShowingIndicator;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    
    NSInteger count = [self.dataSource numberOfTabs:self];
    
    if (count <= 0) return;
    
    if ( selectedIndex >= self.stripperArray.count ) return;
    
    UIView* currentItem = self.stripperArray[selectedIndex];
    
    if ( self.lastItem == currentItem ) {
        return;
    }
    
    CGRect frame = currentItem.frame;
    frame.size.height = 2;
    frame.origin.y = CGRectGetHeight(self.scrollView.frame) - frame.size.height;
    
    UILabel* labelFromCurrentItem = (UILabel *)[currentItem viewWithTag:1101];
    UILabel* labelFromLastItem = (UILabel *)[self.lastItem viewWithTag:1101];
    
    UIColor *selectedColor = self.selectedTitleAttributes[NSForegroundColorAttributeName];
    
    self.tabIndicator.hidden = !self.allowShowingIndicator;
    if ( !animated ) {
        if ( self.allowShowingIndicator ) {
//                self.tabIndicator.frame = frame;
            self.tabIndicator.frame = CGRectMake(0, 0, 18, 2);
            self.tabIndicator.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            
            self.tabIndicator.backgroundColor = selectedColor;
        }
        
        labelFromCurrentItem.textColor = selectedColor;
        labelFromLastItem.textColor    = self.titleAttributes[NSForegroundColorAttributeName];
        
        [self.scrollView scrollRectToVisible:currentItem.frame animated:NO];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            
            if (self.allowShowingIndicator) {
//                self.tabIndicator.frame = frame;
                self.tabIndicator.frame = CGRectMake(0, 0, 18, 2);
                self.tabIndicator.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
                
                self.tabIndicator.backgroundColor = self.selectedTitleAttributes[NSForegroundColorAttributeName];
            }
            
            labelFromCurrentItem.textColor = selectedColor;
            labelFromLastItem.textColor    = self.titleAttributes[NSForegroundColorAttributeName];
            
            [self.scrollView scrollRectToVisible:currentItem.frame animated:NO];
        }];
    }
    
    self.lastItem = currentItem;
}

- (void)setTitleAttributes:(NSDictionary<NSString *,id> *)titleAttributes
{
    _titleAttributes = titleAttributes;
    
    for (UIView *view in self.stripperArray) {
        UILabel *titleLabel = (UILabel *)[view viewWithTag:1101];
        if ( titleAttributes[NSFontAttributeName] ) {
            titleLabel.font = titleAttributes[NSFontAttributeName];
        }
        
        if ( titleAttributes[NSForegroundColorAttributeName] ) {
            titleLabel.textColor = titleAttributes[NSForegroundColorAttributeName];
        }
    }
}

- (void)setSelectedTitleAttributes:(NSDictionary<NSString *,id> *)selectedTitleAttributes
{
    _selectedTitleAttributes = selectedTitleAttributes;
    
    if ( [self.stripperArray count] > 0 ) {
        UIView *view = self.stripperArray[self.selectedIndex];
        UILabel *titleLabel = (UILabel *)[view viewWithTag:1101];
        if ( selectedTitleAttributes[NSFontAttributeName] ) {
            titleLabel.font = selectedTitleAttributes[NSFontAttributeName];
        }
        
        if ( selectedTitleAttributes[NSForegroundColorAttributeName] ) {
            titleLabel.textColor = selectedTitleAttributes[NSForegroundColorAttributeName];
        }
        
        if (self.allowShowingIndicator) {
            self.tabIndicator.backgroundColor = selectedTitleAttributes[NSForegroundColorAttributeName];
        }
    }
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    [self setSelectedIndex:gesture.view.tag animated:YES];
    
    if ( [self.delegate respondsToSelector:@selector(pagerTabStrip:didSelectTabAtIndex:)] ) {
        [self.delegate pagerTabStrip:self didSelectTabAtIndex:gesture.view.tag];
    } else if ( self.didSelectBlock ) {
        self.didSelectBlock(self, gesture.view.tag);
    }
}

@end

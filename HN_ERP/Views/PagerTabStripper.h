//
//  PagerTabStripper.h
//  zgnx
//
//  Created by tomwey on 5/25/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface PagerTabStripper : UIView

- (instancetype)initWithTitles:(NSArray *)titles;

@property (nonatomic, copy) NSArray* titles;
@property (nonatomic, copy) NSDictionary<NSString*, id>* titleAttributes;

@property (nonatomic, strong) UIColor*  selectedColor;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) BOOL allowShowingIndicator;

@property (nullable, nonatomic, copy) void (^didSelectBlock)(PagerTabStripper*, NSUInteger);

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END

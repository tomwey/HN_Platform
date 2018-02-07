//
//  AWSectionHeaderView.h
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWSectionHeaderView;

@protocol SectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(AWSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(AWSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

@end
@interface AWSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic) NSInteger section;

@property (nonatomic, strong) id sectionData;

@property (nonatomic, weak) id <SectionHeaderViewDelegate> delegate;

@property (nonatomic) BOOL opened;

- (void)setOpened:(BOOL)opened animated:(BOOL)animated;

@end

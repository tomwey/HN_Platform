//
//  AWMultipleColumnTableViewDataSource.m
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "AWMultipleColumnTableViewDataSource.h"
#import "UITableViewCell+RemoveBackground.h"

@implementation AWMultipleColumnTableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView resetForGridLayout];
    self.tableView = tableView;
    return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.identifier];
        [cell removeBackground];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 添加每一行内容
    [self addContentsForCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSUInteger)numberOfRows
{
    return ( [self.dataSource count] + self.numberOfItemsPerRow - 1 ) / self.numberOfItemsPerRow;
}

- (void)addContentsForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfCols = self.numberOfItemsPerRow;
    if ( indexPath.row == [self numberOfRows] - 1 ) {
        // 计算最后一行的列数
        numberOfCols = [self.dataSource count] - indexPath.row * self.numberOfItemsPerRow;
    }
    
    // 由于cell重用的缘故，需要删除脏数据
    if ( numberOfCols < self.numberOfItemsPerRow ) {
        for (NSInteger i=numberOfCols; i<self.numberOfItemsPerRow; i++) {
            UIView* view = [cell.contentView viewWithTag:1000 + i];
            [view removeFromSuperview];
        }
    }
    
    // 添加每一行的内容
    CGFloat itemWidth = ( CGRectGetWidth(self.tableView.frame) - ( self.itemMargin * 2 + ( self.numberOfItemsPerRow - 1 ) * self.itemSpacing ) ) / self.numberOfItemsPerRow;
    for (int i=0; i<numberOfCols; i++) {
        
        UIView<AWTableDataConfig>* view = [cell.contentView viewWithTag:1000 + i];
        if ( !view ) {
            view = [[NSClassFromString(self.itemClass) alloc] init];
            view.tag = 1000 + i;
            [cell.contentView addSubview:view];
            
            view.frame = CGRectMake(self.itemMargin + (itemWidth + self.itemSpacing) * i,
                                    self.offsetY,
                                    itemWidth,
                                    self.itemSize.height == 0 ? itemWidth : self.itemSize.height);
        }
        
        NSInteger index = indexPath.row * self.numberOfItemsPerRow + i;
        if ( index < [self.dataSource count] ) {
            [view configData:[self.dataSource objectAtIndex:index] selectBlock:self.itemDidSelectBlock];
        }
    }
    
}

- (NSUInteger)numberOfItemsPerRow
{
    if ( _numberOfItemsPerRow == 0 ) {
        _numberOfItemsPerRow = 2;
    }
    return _numberOfItemsPerRow;
}

- (CGFloat)itemMargin
{
    if ( _itemMargin == 0.0 ) {
        _itemMargin = self.itemSpacing;
    }
    return _itemMargin;
}

- (CGFloat)itemSpacing
{
    if ( _itemSpacing == 0.0 ) {
        _itemSpacing = 10;
    }
    return _itemSpacing;
}

@end

@implementation UITableView (AWGridLayout)

- (void)resetForGridLayout
{
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
}

@end

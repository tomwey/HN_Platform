//
//  CatalogContentView.m
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CatalogContentView.h"
#import "Defines.h"
#import "OutputCatalog.h"
#import "SubCatalogCell.h"

@interface CatalogContentView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation CatalogContentView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.tableView reloadData];
}

//- (NSArray *)dataSource
//{
//    if ( !_dataSource ) {
//        _dataSource = [@[
//                        @[
//                            @{ @"name": @"土石方合同", @"count": @"2" },
//                            @{ @"name": @"基坑合同", @"count": @"1" },
//                            @{ @"name": @"桩基合同", @"count": @"1" },
//                        ],
//                        @[
//                            @{ @"name": @"施工总包合同", @"count": @"2" },
//                            @{ @"name": @"保温合同", @"count": @"1" },
//                            @{ @"name": @"门窗合同", @"count": @"1" },
//                            @{ @"name": @"配电箱合同", @"count": @"2" },
//                            @{ @"name": @"基坑合同", @"count": @"1" },
//                            @{ @"name": @"桩基合同", @"count": @"1" },
//                            @{ @"name": @"土石方合同", @"count": @"2" },
//                            @{ @"name": @"基坑合同", @"count": @"1" },
//                        ],
//                        ] copy];
//    }
//    return _dataSource;
//}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds
                                                  style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        _tableView.rowHeight = 50;
        
        [_tableView removeCompatibility];
        
//        _tableView.layer.borderWidth = 0.5;
//        _tableView.layer.borderColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR.CGColor;
        
        _tableView.showsVerticalScrollIndicator = NO;
        
        _tableView.backgroundColor = [UIColor clearColor];
        
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
//        _tableView.sectionHeaderHeight = 27;
//        _tableView.contentInset = UIEdgeInsetsMake(-32, 0, -20, 0);
        
        [_tableView removeBlankCells];
        
    }
    return _tableView;
}

- (void)setCatalogData:(NSArray *)catalogData
{
    _catalogData = catalogData;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.catalogData.count;
}

//- (NSInteger)numberOfCols
//{
//    return 2;
//}

- (NSInteger)numberRowsForSection:(NSInteger)section
{
    OutputCatalog *catalog = self.catalogData[section];
    
    return [catalog.children count];
    //([catalog.children count] + [self numberOfCols] - 1) / [self numberOfCols];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberRowsForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cell.ids";
    //[NSString stringWithFormat:@"sec-%d-row-%d", indexPath.section, indexPath.row];
    
    SubCatalogCell *cell = (SubCatalogCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if ( !cell ) {
        cell = [[SubCatalogCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellId];
    }
    
    OutputCatalog *catalog = self.catalogData[indexPath.section];
    NSArray *arr = catalog.children;
    OutputCatalog *item = arr[indexPath.row];
    
    [cell configData:item];
    
//    cell.textLabel.font = AWSystemFontWithSize(13, NO);
//    cell.detailTextLabel.font = AWSystemFontWithSize(13, NO);
//    
//    cell.textLabel.textColor = AWColorFromHex(@"#666666");
//    
//    cell.textLabel.text = item.name;
//    cell.detailTextLabel.text = [item.total description];
    
//    [self addContentsAtIndexPath:indexPath forCell:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OutputCatalog *catalog = self.catalogData[indexPath.section];
    if (self.didSelectBlock) {
        self.didSelectBlock(catalog.children[indexPath.row]);
    }
}

//- (void)addContentsAtIndexPath:(NSIndexPath *)indexPath forCell:(UITableViewCell *)cell
//{
//    NSInteger numberOfCols = [self numberOfCols];
//    
//    // 计算列
//    OutputCatalog *catalog = self.catalogData[indexPath.section];
//    NSArray *arr = catalog.children;
//    
//    NSInteger secTotal = arr.count;
//    
//    NSInteger cols = numberOfCols;
//    
//    if ( indexPath.row == [self numberRowsForSection:indexPath.section] - 1 ) {
//        cols = secTotal - numberOfCols * indexPath.row;
//        
//        for (int i = cols; i<numberOfCols; i++) {
//            [[cell.contentView viewWithTag:100 + i] removeFromSuperview];
//        }
//    }
//    
//    for (int i=0; i<cols; i++) {
//        UIButton *btn = [cell.contentView viewWithTag:100 + i];
//        if ( !btn ) {
//            btn = AWCreateTextButton(CGRectZero,
//                                     nil,
//                                     AWColorFromRGB(74, 74, 74),
//                                     self,
//                                     @selector(btnClicked:));
//            [cell.contentView addSubview:btn];
//            btn.tag = 100 + i;
//            
//            btn.frame = CGRectMake(0, 0, (self.width - 10) / 2.0,
//                                   50);
//            btn.position = CGPointMake((btn.width + 10) * i, 8);
//            
//            btn.layer.cornerRadius = 4;
//            btn.layer.borderColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR.CGColor;
//            btn.layer.borderWidth = 0.5;
//            btn.clipsToBounds = YES;
//            
//            btn.titleLabel.font = AWSystemFontWithSize(14, NO);
//            btn.titleLabel.numberOfLines = 2;
//            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
//        }
//        
//        NSInteger index = indexPath.row * numberOfCols + i;
//        if ( index < secTotal ) {
//            OutputCatalog *item = arr[index];
//            
//            btn.userData = item;
//            
//            [btn setTitle:[NSString stringWithFormat:@" %@(%@) ", item.name, item.total ]
//                 forState:UIControlStateNormal];
//        }
//    }
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
//    NSLog(@"view: %@", view);
//    view.backgroundColor = [UIColor whiteColor];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
//    header.backgroundColor = [UIColor redColor];
    header.contentView.backgroundColor = [UIColor whiteColor];
    
    
//    header.textLabel.font = AWCustomFont(@"PingFang SC", 16);
//    header.textLabel.backgroundColor = [UIColor whiteColor];
    header.textLabel.textColor = AWColorFromHex(@"#666666");
    header.textLabel.font = AWSystemFontWithSize(12, YES);
    //AWCustomFont(@"PingFang SC Bold", 12);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header.cell"];
    if ( !view ) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header.cell"];
//        view.contentView.backgroundColor = [UIColor clearColor];
    }
    
//    NSArray *titles = @[@"基础工程合同", @"主体建安合同"];
    
    OutputCatalog *catalog = self.catalogData[section];
    
    view.textLabel.text = catalog.name;
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)btnClicked:(UIButton *)sender
{
    if (self.didSelectBlock) {
        self.didSelectBlock(sender.userData);
    }
}

@end

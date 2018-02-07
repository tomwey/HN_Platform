//
//  CatalogLeftMenuView.m
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CatalogLeftMenuView.h"
#import "Defines.h"
//#import "AWTableViewDataSource.h"
//#import "AWTableView.h"

@interface CatalogMenuCell : UITableViewCell <AWTableDataConfig>

@end

@interface CatalogLeftMenuView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, assign) NSInteger selectedIndex;

@end
@implementation CatalogLeftMenuView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
//    [self.tableView reloadData];
}

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
        
//        _tableView.backgroundColor = AWColorFromRGB(244, 244, 244);
        
        [_tableView removeCompatibility];
        
//        _tableView.layer.borderWidth = 0.5;
//        _tableView.layer.borderColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR.CGColor;
        
        _tableView.showsVerticalScrollIndicator = NO;
        
        _tableView.separatorColor = [UIColor whiteColor];
        
        [_tableView removeBlankCells];
        
    }
    return _tableView;
}

- (void)setCatalogData:(NSArray *)catalogData
{
    _catalogData = catalogData;
    
    self.dataSource.dataSource = catalogData;
    
    self.tableView.height = MIN(self.dataSource.dataSource.count * self.tableView.rowHeight,
                                self.height);
    
    if ( self.tableView.height < self.height ) {
        self.tableView.scrollEnabled = NO;
    } else {
        self.tableView.scrollEnabled = YES;
    }
    
//    self.selectedIndex = 0;
    
    [self.tableView reloadData];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.catalogData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogMenuCell *cell = (CatalogMenuCell *)[tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[CatalogMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
    }
    
    [cell configData:self.catalogData[indexPath.row] selectBlock:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    
    if (self.didSelectCatalog) {
        self.didSelectCatalog(self.dataSource.dataSource[indexPath.row]);
    }
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil,
                                                  @"CatalogMenuCell",
                                                  @"catalog.menu.cell");
    }
    return _dataSource;
}

@end

@implementation CatalogMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.layoutMargins = UIEdgeInsetsZero;
        self.separatorInset = UIEdgeInsetsZero;
        
        self.backgroundColor = AWColorFromRGB(244, 244, 244);
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id))selectBlock
{
    self.textLabel.text = [data name];
//    self.textLabel.layer.borderColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR.CGColor;
//    self.textLabel.layer.borderWidth = 1;
//    self.textLabel.textAlignment = NSTextAlignmentCenter;
//    self.textLabel.numberOfLines = 2;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textColor = AWColorFromHex(@"#666666");
    self.textLabel.font = AWSystemFontWithSize(14, NO);
}

@end

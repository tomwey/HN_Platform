//
//  AWTableViewDataSource.m
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "AWTableViewDataSource.h"

// 此种作法仅仅是为了让编译器通过编译
@interface UITableViewCell (AWTableDataConfig) <AWTableDataConfig>

- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock;

@end

@interface AWTableViewDataSource ()

//@property (nonatomic, assign) UITableView* tableView;

@end

@implementation AWTableViewDataSource

- (instancetype)initWithArray:(NSArray *)dataSource cellClass:(NSString *)className identifier:(NSString *)identifier
{
    if ( self = [super init] ) {
        self.dataSource = dataSource;
        self.cellClass = className;
        self.identifier = identifier;
        
    }
    return self;
}

+ (instancetype)dataSourceWithArray:(NSArray *)dataSource cellClass:(NSString *)className identifier:(NSString *)identifier
{
    return [[self alloc] initWithArray:dataSource cellClass:className identifier:identifier];
}

- (instancetype)init
{
    return [self initWithArray:nil cellClass:nil identifier:nil];
}

- (void)dealloc
{
    self.dataSource = nil;
    self.cellClass  = nil;
    self.identifier = nil;
    
    self.tableView = nil;
    
//    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView = tableView;
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(!!self.cellClass, @"Cell类不能为空");
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    if ( cell == nil ) {
        cell = [[NSClassFromString(self.cellClass) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.identifier];
    }
    
    NSAssert([cell conformsToProtocol:@protocol(AWTableDataConfig)], @"自定义Cell类必须实现AWTableDataConfig接口");
    
    // 配置数据到视图
    if ( indexPath.row < [self.dataSource count] ) {
        id data = [self.dataSource objectAtIndex:indexPath.row];
        [cell configData:data selectBlock:self.itemDidSelectBlock];
    }
    
    return cell;
}

- (void)notifyDataChanged
{
    [self.tableView reloadData];
}

@end

@implementation UITableViewCell (AWTableDataConfig)

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *sender, id selectedData))selectBlock
{
    // 仅仅是为了让编译器通过编译
}

@end

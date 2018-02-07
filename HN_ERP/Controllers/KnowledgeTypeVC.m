//
//  KnowledgeTypeVC.m
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "KnowledgeTypeVC.h"
#import "Defines.h"
#import "TypeGridView.h"
#import "DocBreadcrumbView.h"

@interface KnowledgeTypeVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataSource;
@property (nonatomic, strong) DocBreadcrumbView *breadcrumbView;

@end

@implementation KnowledgeTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = self.params[@"title"];
    
    __weak typeof(self) weakSelf = self;
    [self addRightItemWithImage:@"btn_search.png" rightMargin:5 callback:^{
        [weakSelf gotoSearch];
    }];
    
    NSArray *breadcrumbs = self.params[@"breadcrumbs"] ?: @[];
    if ( breadcrumbs.count == 0 ) {
        self.breadcrumbView.frame = CGRectZero;
        self.breadcrumbView.hidden = YES;
        self.tableView.frame = self.contentView.bounds;
    } else {
        self.breadcrumbView.frame = CGRectMake(0, 0, self.contentView.width, 60);
        self.tableView.height -= self.breadcrumbView.height;
        self.tableView.top     = self.breadcrumbView.height;
    }
    
    NSMutableArray *temp = [breadcrumbs mutableCopy];
    [temp addObject:[[DocBreadcrumb alloc] initWithName:self.navBar.title
                                                   data:nil
                                                   page:self]];
    self.breadcrumbView.breadcrumbs = [temp copy];
    
    [self loadData];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"知识库"
                                    keyMemo:nil];
}

- (DocBreadcrumbView *)breadcrumbView
{
    if ( !_breadcrumbView ) {
        _breadcrumbView = [[DocBreadcrumbView alloc] init];
        [self.contentView addSubview:_breadcrumbView];
        _breadcrumbView.backgroundColor = [UIColor whiteColor];
        
        AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:_breadcrumbView];
        line.position = CGPointMake(0, 59);
        
        __weak typeof(self) me = self;
        _breadcrumbView.breadcrumbClickCallback =
        ^(DocBreadcrumbView *sender, DocBreadcrumb *b) {
            [me forwardForBreadcrumb:b];
        };
    }
    return _breadcrumbView;
}

- (void)forwardForBreadcrumb:(DocBreadcrumb *)b
{
    [self.navigationController popToViewController:b.page animated:YES];
}

- (void)gotoSearch
{
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"KnowledgeDocSearchVC" params:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"知识库分类查询APP",
              @"param1": manID,
              @"param2": [self.params[@"mid"] description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                     reloadDelegate:nil];
            self.dataSource = nil;
        } else {
            self.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfCols
{
    if ( self.contentView.width > 320 ) {
        return 4;
    } else {
        return 3;
    }
}

- (NSInteger)numberOfRows
{
//    if (self.dataSource.count == 0) {
//        return 0;
//    }
//    
//    NSInteger rowSize = [self numberOfCols];
//    if ( rowSize == 0 )
//        return 0;
//    
//    return (self.dataSource.count + rowSize - 1) / rowSize;
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
//    [self addContentsForCell:cell atIndexPath:indexPath];
    id item = self.dataSource[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"icon_folder.png"];
    
    cell.textLabel.text = item[@"typename"];
    
    return cell;
}

- (void)addContentsForCell:(UITableViewCell *)cell
               atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowSize = [self numberOfCols];
    if ( indexPath.row == [self numberOfRows] - 1 ) {
        // 最后一行
        rowSize = self.dataSource.count - ( indexPath.row * rowSize );
    }
    
    NSLog(@"rowSize: %d", rowSize);
    
    // 移除最后一行由于cell重用导致的多出来的grid
    if ( rowSize < [self numberOfCols] ) {
        for (int i = rowSize; i< [self numberOfCols]; i++) {
            [[cell.contentView viewWithTag:100 + i] removeFromSuperview];
        }
    }
    
    // 添加grid
    for (int i = 0; i < rowSize; i++) {
        [self addGridForCell:cell atIndexPath:indexPath position:i];
    }
}

- (void)addGridForCell:(UITableViewCell *)cell
           atIndexPath:(NSIndexPath *)indexPath
              position:(int)position
{
    TypeGridView *gridView = (TypeGridView *)[cell.contentView viewWithTag:100 + position];
    if ( !gridView ) {
        gridView = [[TypeGridView alloc] init];
        
        CGFloat padding = 15;
        CGFloat width   = (self.contentView.width - ( [self numberOfCols] + 1 ) * padding) / [self numberOfCols];
        
        // 设置位置大小
        gridView.frame = CGRectMake(0, 0, width, 60);
        
        gridView.position =
            CGPointMake(padding + ( gridView.width + padding ) * position,
                        self.tableView.rowHeight / 2 - gridView.height / 2 + 5);
        
        [cell.contentView addSubview:gridView];
        gridView.tag = 100 + position;
//        gridView.backgroundColor = [UIColor redColor];
        gridView.tapCallback = ^(TypeGridView *sender) {
            [self gridTap:sender.item];
        };
    }
    
    NSInteger index = indexPath.row * [self numberOfCols] + position;
    if ( index < self.dataSource.count ) {
        gridView.item = self.dataSource[index];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self gridTap:self.dataSource[indexPath.row]];
}

- (void)gridTap:(id)item
{
    NSString *vcName;
    if ( [item[@"count"] integerValue] == 0 ) {
        // 表示还有子类别
        vcName = @"KnowledgeTypeVC";
    } else {
        // 表示是叶子类别了
        vcName = @"KnowledgeDocListVC";
    }
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:vcName
                                                                params:
                            @{ @"title": item[@"typename"] ?: @"", @"mid": item[@"mid"] ?: @"", @"breadcrumbs": self.breadcrumbView.breadcrumbs ?: @[] }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 60;
        
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

@end

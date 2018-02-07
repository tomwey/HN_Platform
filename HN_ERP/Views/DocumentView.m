//
//  DocumentView.m
//  HN_ERP
//
//  Created by tomwey on 2/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DocumentView.h"
#import "Defines.h"

@interface DocumentView () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation DocumentView

- (void)setIndustryType:(NSString *)industryType
{
    if (_industryType == industryType) return;
    
    _industryType = industryType;
    
    [self updateTable];
}

- (void)setSearchCondition:(NSDictionary *)searchCondition
{
    if ( _searchCondition == searchCondition ) return;
    
    _searchCondition = searchCondition;
    
    [self updateTable];
}

- (void)updateTable
{
    
}

- (void)startLoadingForType:(NSString *)type
{
    // 重新刷新数据
    self.pageIndex = 0;
    NSLog(@"type: %@, condition: %@", type, self.searchCondition);
    
    [self loadDocuments];
}

- (void)forceRefreshForType:(NSString *)type
{
    [self startLoadingForType:type];
}

- (UIView *)loadingContainer
{
    if ( !_loadingContainer ) {
        _loadingContainer = self;
    }
    return _loadingContainer;
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.loadingContainer animated:YES];
    
    if ( error ) {
        if ( self.pageIndex == 0 ) {
            // 取第一页
            [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
        } else {
            // 分页数据加载失败
            [self showHUDWithText:error.domain offset:CGPointMake(0, MBProgressMaxOffset)];
        }
        self.tableView.showsInfiniteScrolling = NO;
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            if ( self.pageIndex == 0 ) {
                // 取第一页
                [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
            } else {
                // 分页数据
                [self showHUDWithText:LOADING_MORE_NO_RESULT
                               offset:CGPointMake(0, MBProgressMaxOffset)];
            }
            self.tableView.showsInfiniteScrolling = NO;
        } else {
            [self.tableView removeErrorOrEmptyTips];
            
            NSArray *data = result[@"data"];
            
            NSMutableArray *temp = [NSMutableArray array];
            
            for (id dict in data) {
                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                item[@"docid"] = dict[@"mid"];
                item[@"title"] = dict[@"title"];
                item[@"area"]  = dict[@"area_name"];
                item[@"scope"] = dict[@"industry_name"];
                item[@"type"] = dict[@"typename"];
                
                NSDictionary *params = [[[[dict[@"url"] description] componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
                
                item[@"addr"]  = params[@"file"] ?: @"";
                item[@"isdoc"] = params[@"isdoc"] ?: @"";
                item[@"docid"] = params[@"fileid"] ?: @"0";
                item[@"filename"] = params[@"filename"] ?: @"";

                
                NSString *time = [dict[@"fwdate"] description];
                time = [[time componentsSeparatedByString:@"T"] firstObject];
                item[@"time"] = time;
                
                item[@"is_read"] = [dict[@"isview"] integerValue] == 0 ? @(NO) : @(YES);
                item[@"host"] = dict[@"serverip"];
                item[@"port"] = dict[@"port"];
                item[@"username"] = dict[@"username"];
                item[@"pwd"] = dict[@"pwd"];
                //item[@"filename"] = dict[@"filename"];
                item[@"fileid"] = dict[@"annexid"];
                item[@"tablename"] = dict[@"tablename"];
                item[@"annexcount"] = dict[@"annexcount"] ?: @"0";
                
                [temp addObject:item];
            }
            
            if ( self.pageIndex == 0 ) {
                self.dataSource.dataSource = temp;
            } else {
                NSMutableArray *oldData = [self.dataSource.dataSource mutableCopy];
                [oldData addObjectsFromArray:temp];
                self.dataSource.dataSource = [oldData copy];
            }
            
            [self.tableView reloadData];
            
            if ([data lastObject] && [data lastObject][@"pageindex"] && [[data lastObject][@"pageindex"] integerValue] != -1) {
                self.tableView.showsInfiniteScrolling = YES;
                self.pageIndex = [[data lastObject][@"pageindex"] integerValue];
            } else {
                self.tableView.showsInfiniteScrolling = NO;
            }
        }
    }
    
}

- (void)loadMore
{
    [self loadDocuments];
}

- (void)loadDocuments
{
//    self.tabTitles = @[@"全部",@"红文",@"制度",@"公告/通知",@"物业",@"商业"];
//    [self.tabStrip reloadData];
    
    if ( self.pageIndex == -1 ) { // 没有更多数据了
        return;
    }
    
    if ( self.pageIndex == 0 ) {
        [HNProgressHUDHelper showHUDAddedTo:self.loadingContainer animated:YES];
        self.dataSource.dataSource = nil;
        [self.tableView reloadData];
    }
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSString *title = self.searchCondition[@"keyword"] ?: @"";
    NSString *area  = self.searchCondition[@"area"][@"value"] ?: @"0";
    NSString *docType = self.searchCondition[@"doc_type"][@"value"] ?: @"-1";
//    if ( [docType isEqualToString:@"-1"] ) {
//        docType = @"0";
//    }
    NSString *beginDate = [self dateStringForKey:@"publish_date.1"];//self.searchCondition[@"publish_date.1"] ?: @"";
    NSString *endDate = [self dateStringForKey:@"publish_date.2"];//self.searchCondition[@"publish_date.2"] ?: @"";
    
    NSString *dataType = [self.searchCondition count] == 0 ? @"1" : @"0";
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"移动端公文查询",
                       @"param1": manID,
                       @"param2": @"10000", // 记录数 //self.industryType ?: @"0",
                       @"param3": docType, //title,
                       @"param4": title, //area,
                       @"param5": @"", // 文档编号 //docType,
                       @"param6": beginDate,
                       @"param7": endDate,
                       @"param8": self.readType ?: @"0",
                       @"param9": self.industryType ?: @"0",
                       @"param10": area,
                       @"param11": dataType,
                       @"param12": [@(self.pageIndex) description],
                       } completion:^(id result, NSError *error) {
                           [me handleResult:result error:error];
                       }];
}

- (NSString *)dateStringForKey:(NSString *)key
{
    if ( !key ) {
        return @"";
    }
    
    if ( self.searchCondition[key] ) {
        NSString *dateString = [self.searchCondition[key] description];
        dateString = [[dateString componentsSeparatedByString:@" "] firstObject];
        return dateString;
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectDocumentBlock ) {
        self.didSelectDocumentBlock(self, self.dataSource.dataSource[indexPath.row]);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        self.tableView.rowHeight = 90;
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView removeBlankCells];
        
//        [_tableView removeCompatibility];
        
        __weak typeof(self) weakSelf = self;
        [_tableView addInfiniteScrollingWithActionHandler:^{
            __strong DocumentView *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf loadMore];
            }
        }];
        
        // 配置加载更多
        DGActivityIndicatorView *view = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:MAIN_THEME_COLOR];
        [view startAnimating];
        [_tableView.infiniteScrollingView setCustomView:view forState:SVInfiniteScrollingStateAll];
        
        _tableView.showsInfiniteScrolling = NO;
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[AWTableViewDataSource alloc] initWithArray:nil cellClass:@"DocumentCell" identifier:@"cell.doc.id"];
    }
    return _dataSource;
}

@end

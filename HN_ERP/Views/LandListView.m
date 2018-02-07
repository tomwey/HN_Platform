//
//  LandListView.m
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandListView.h"
#import "Defines.h"

@interface LandListView () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, assign) NSUInteger pageNo;
@property (nonatomic, assign) NSUInteger pageSize;

@end

@implementation LandListView

- (void)startLoading
{
    self.pageNo = 1;
    self.pageSize = 20;
    [self loadData];
}

- (void)forceRefreshing
{
    self.pageNo = 1;
    self.pageSize = 20;
    
    [self loadData];
}

- (void)loadMoreData
{
    self.pageNo++;
    
    [self loadData];
}

- (NSString *)searchConditionHash
{
    if ( self.searchCondition.count > 0 ) {
        NSUInteger hash = [[self.searchCondition description] hash];
        return [NSString stringWithFormat:@":%@", @(hash)];
    }
    return @"";
}

- (NSString *)getCacheKey
{
    NSString *manID = [[UserService sharedInstance] currentUser][@"man_id"];
    return [NSString stringWithFormat:@"%@:%@:%@", manID, @([[self.item description] hash]), [self searchConditionHash]];
}

- (NSString *)getPaginateCacheKey
{
    NSString *manID = [[UserService sharedInstance] currentUser][@"man_id"];
    return [NSString stringWithFormat:@"%@:%@:page%@", manID, @([[self.item description] hash]), [self searchConditionHash]];
}

- (NSInteger)pageIndex
{
    if ( [[HNCache sharedInstance] objectForKey:[self getPaginateCacheKey]] ) {
        return [[[HNCache sharedInstance] objectForKey:[self getPaginateCacheKey]] integerValue];
    }
    
    return 0;
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

- (void)loadData
{
    NSLog(@"page: %d", self.pageNo);
    
    if ( self.pageNo == 1 ) {
        [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    }
    
    [self.tableView removeErrorOrEmptyTips];
    
    NSString *type = self.item[@"type"] ?: @"0";
    NSString *getType = self.searchCondition[@"get_type"][@"value"] ?: @"";
    NSString *city = self.searchCondition[@"city"][@"value"] ?: @"";
    
    NSString *annBDate = [self dateStringForKey:@"announce_date.1"];
    NSString *annEDate = [self dateStringForKey:@"announce_date.2"];
    
    NSString *sellBDate = [self dateStringForKey:@"sell_date.1"];
    NSString *sellEDate = [self dateStringForKey:@"sell_date.2"];
    
    NSString *signupBDate = [self dateStringForKey:@"signup_date.1"];
    NSString *signupEDate = [self dateStringForKey:@"signup_date.2"];
    
    NSString *pageNo = [@(self.pageNo) description];
    NSString *pageSize = [@(self.pageSize) description];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak LandListView *weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"土地信息查询APP",
              @"param1": type, // type
              @"param2": pageNo, // get type
              @"param3": pageSize, // city
              @"param4": getType, // get type
              @"param5": city, // city
              @"param6": annBDate, // 公告开始时间
              @"param7": annEDate, // 公告结束时间
              @"param8": sellBDate, // 出让开始时间
              @"param9": sellEDate, // 出让结束时间
              @"param10": signupBDate, // 报名截止开始时间
              @"param11": signupEDate, // 报名截止结束时间
              @"param12": manID,
              } completion:^(id result, NSError *error) {
                  __strong LandListView *strongSelf = weakSelf;
                  if ( strongSelf ) {
                      [strongSelf handleResult:result error:error];
                  }
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
    
    [self.tableView.infiniteScrollingView stopAnimating];
    
    if ( error ) {
//        [self showHUDWithText:error.domain offset:CGPointMake(0, 20)];
        if ( self.pageNo == 1 ) {
            [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
            self.tableView.showsInfiniteScrolling = NO;
        } else {
            [self showHUDWithText:error.domain offset:CGPointMake(0, 20)];
        }
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self showHUDWithText:@"无数据显示" offset:CGPointMake(0, 20)];
            if ( self.pageNo == 1 ) {
                [self.tableView showErrorOrEmptyMessage:@"<无数据显示>" reloadDelegate:nil];
                self.dataSource.dataSource = nil;
            } else {
                [self showHUDWithText:@"无更多数据" offset:CGPointMake(0, 0)];
            }
        } else {
            
            NSMutableArray *newArr = [NSMutableArray array];
            for (id item in result[@"data"]) {
                NSMutableDictionary *dict = [item mutableCopy];
                dict[@"need_show_state"]  = @([self.item[@"type"] integerValue] == 0);
                [newArr addObject:dict];
            }
            
            if ( self.pageNo == 1 ) {
                self.dataSource.dataSource = newArr;//result[@"data"];
            } else {
                NSMutableArray *temp = [self.dataSource.dataSource mutableCopy];
                [temp addObjectsFromArray:/*result[@"data"]*/newArr];
                self.dataSource.dataSource = [temp copy];
            }
        }
        
        [self.tableView reloadData];
        
        if ( [result[@"rowcount"] integerValue] < self.pageSize ) {
            self.tableView.showsInfiniteScrolling = NO;
        } else {
            self.tableView.showsInfiniteScrolling = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectItemBlock ) {
        self.didSelectItemBlock(self, self.dataSource.dataSource[indexPath.row]);
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_tableView];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _tableView.dataSource = self.dataSource;

        [_tableView removeBlankCells];
        _tableView.delegate = self;
        _tableView.rowHeight = 88 + 16 + 40;
        
        // 添加加载更多
        __weak typeof(self) weakSelf = self;
        [_tableView addInfiniteScrollingWithActionHandler:^{
            NSLog(@"will load more...");
            __strong LandListView *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf loadMoreData];
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
        _dataSource = AWTableViewDataSourceCreate(nil, @"LandCell", @"land.cell");
    }
    return _dataSource;
}

@end

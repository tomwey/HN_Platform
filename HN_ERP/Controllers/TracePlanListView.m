//
//  Trace&PlanListView.m
//  HN_ERP
//
//  Created by tomwey on 7/28/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "TracePlanListView.h"
#import "Defines.h"

@interface TracePlanListView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, assign) BOOL loading;

@end

@implementation TracePlanListView

- (void)startLoading:(void (^)(void))completionBlock
{
    if (self.loading) return;
    
    self.loading = YES;
    
    [self.tableView removeErrorOrEmptyTips];
    
    __weak typeof(self) me = self;
    
    [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    
//    id user = [[UserService sharedInstance] currentUser];
//    NSString *manID = [user[@"man_id"] description] ?: @"0";
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"跟踪与计划列表APP",
              @"param1": self.id_ ?: @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
                  
                  [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
                  
                  if ( completionBlock ) {
                      completionBlock();
                  }
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    self.loading = NO;
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
    } else {
        if ([result[@"rowcount"] integerValue] == 0) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                     reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {
            self.dataSource.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 110;
        
        _tableView.separatorInset = UIEdgeInsetsZero;
        
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil,
                                                  @"TracePlanCell",
                                                  @"cell.id");
    }
    return _dataSource;
}

@end

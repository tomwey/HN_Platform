//
//  InvestNewsVC.m
//  HN_ERP
//
//  Created by tomwey on 01/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "InvestNewsVC.h"
#import "Defines.h"

@interface InvestNewsVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation InvestNewsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"项目资讯";
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kInvestNewsDidViewNotification"
                                               object:nil];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSString *projID = [self.params[@"proj_id"] description];
    
    __weak typeof(self) me = self;
    if ( [projID isEqualToString:@"0"] ) {
        // 获取全部的项目咨询
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"GetData",
                  @"funname": @"跟投项目咨询列表APP",
                  @"param1": @"0",
                  @"param2": manID,
                  } completion:^(id result, NSError *error) {
                      [me handleResult:result error:error];
                  }];
    } else {
        // 获取某个项目的项目咨询
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"GetData",
                  @"funname": @"跟投项目咨询列表APP",
                  @"param1": projID,
                  @"param2": manID
                  } completion:^(id result, NSError *error) {
                      [me handleResult:result error:error];
                  }];
    }
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            self.dataSource.dataSource = nil;
            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
        } else {
            self.dataSource.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"InvestNewsDetailVC"
                                                                params:self.dataSource.dataSource[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.rowHeight  = 90;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"InvestNewsCell", @"cell.id");
    }
    return _dataSource;
}

@end

//
//  InvestProjectListVC.m
//  HN_ERP
//
//  Created by tomwey on 24/11/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "InvestProjectListVC.h"
#import "Defines.h"

@interface InvestProjectListVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation InvestProjectListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"跟投项目列表";
    
    self.contentView.backgroundColor = AWColorFromRGB(235, 235, 241);
    
    [self loadData];
}

- (void)loadData
{
//    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
//    
//    NSArray *datas = @[@{
//                           @"area_name": @"成都",
//                           @"proj_name": @"双流黄甲",
//                           @"total": @"8000",
//                           @"cost": @"5000",
//                           @"earn": @"3000",
//                           @"state": @"0",
//                           @"time1": @"2018-12-25",
//                           @"time2": @"2018-11-23"
//                           },
//                       @{
//                           @"area_name": @"重庆",
//                           @"proj_name": @"重庆茶园101",
//                           @"total": @"8000",
//                           @"cost": @"5000",
//                           @"earn": @"3000",
//                           @"state": @"1",
//                           @"time1": @"2018-12-25",
//                           @"time2": @"2018-11-23"
//                           },
//                       ];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
        self.dataSource.dataSource = self.params[@"data"];
        [self.tableView reloadData];
//    });
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 190;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.dataSource = self.dataSource;
        
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
        
        _tableView.backgroundColor = self.contentView.backgroundColor;
    }
    
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil,
                                                  @"InvestProjectCell",
                                                  @"project.cell");
        
        __weak typeof(self) me = self;
        _dataSource.itemDidSelectBlock = ^(UIView<AWTableDataConfig> *sender, id selectedData) {
            UIViewController *vc =
                [[AWMediator sharedInstance] openVCWithName:@"InvestProjectDetailVC"
                                                     params:selectedData];
            [me.navigationController pushViewController:vc animated:YES];
        };
    }
    
    return _dataSource;
}

@end

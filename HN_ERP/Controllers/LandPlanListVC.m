//
//  LandPlanListVC.m
//  HN_ERP
//
//  Created by tomwey on 6/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandPlanListVC.h"
#import "Defines.h"

@interface LandPlanListVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation LandPlanListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"工作计划";
    
    [self loadData];
}

- (void)loadData
{
    //
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"土地信息工作计划查询APP",
              @"param1": manID,
              @"param2": [self.params[@"land_id"] ?: @"0" description
                          ],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
        } else {
            self.dataSource.dataSource = result[@"data"];
            
            [self.tableView reloadData];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource.dataSource[indexPath.row];
    
    NSString *memoDesc = HNStringFromObject(item[@"memodesc"], @"无");
    
    memoDesc = [NSString stringWithFormat:@"备注：%@", memoDesc];
    
    CGSize size = [memoDesc boundingRectWithSize:
                   CGSizeMake(self.contentView.width - 30, 10000)
                                         options:
                   NSStringDrawingUsesLineFragmentOrigin
                                      attributes:nil
                                         context:NULL].size;
    return 115 + size.height;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        [_tableView removeBlankCells];
        
    }
    
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"LandPlanCell", @"cell.id");
    }
    return _dataSource;
}

@end

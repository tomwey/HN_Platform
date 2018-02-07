//
//  FlowSearchResultVC.m
//  HN_ERP
//
//  Created by tomwey on 5/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowSearchResultVC.h"
#import "Defines.h"

@interface FlowSearchResultVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation FlowSearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"搜索结果";
    
    [self startSearch:self.params[@"condition"]];
}

- (void)startSearch:(id)searchParams
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:[self prepareParams:searchParams]
     completion:^(id result, NSError *error) {
         [me handleResult:result error:error];
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
            self.dataSource.dataSource = nil;
        } else {
            self.dataSource.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (NSDictionary *)prepareParams:(id)params
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    // 0：全部流程；1：我的待办；2：我的请求；3：我的已办；4：我的归档；5：我的抄送；6：总裁批示；7：授权查询
    
    NSString *beginDate  = [self dateForParams:params forKey:@"create_date.1"];
    NSString *endDate    = [self dateForParams:params forKey:@"create_date.2"];
    NSString *creatorIds = [self creatorIdsForParams:params forKey:@"contacts"];
    NSString *flowNo     = params[@"flow_no"] ?: @""; // 流程编号
    NSString *flowDesc   = params[@"flow_desc"] ?: @""; // 流程说明
    flowNo = [flowNo trim];
    flowDesc = [flowDesc trim];
    NSString *joinMan    = [self creatorIdsForParams:params
                                              forKey:@"contacts2"]; // 参与人
    
    return @{
             @"dotype": @"GetData",
             @"funname": @"流程查询APP",
             @"param1": manID,      // man id
             @"param2": @"0",       // 搜索类型
             @"param3": beginDate,  // 开始日期
             @"param4": endDate,    // 结束日期
             @"param5": creatorIds, // 创建人ID，以逗号分隔
             @"param6": flowNo,     // 流程编号
             @"param7": flowDesc,   // 流程说明
             @"param8": joinMan,    // 参与人
             };
}

- (NSString *)dateForParams:(id)params forKey:(NSString *)key
{
    if (!key) {
        return @"";
    }
    
    if (!params) {
        return @"";
    }
    
    id value = params[key];
    if ( !value ) {
        return @"";
    }
    
    NSString *dateStr = [value description];
    
    return [[[dateStr componentsSeparatedByString:@" "] firstObject] description];
}

- (NSString *)creatorIdsForParams:(id)params forKey:(NSString *)key
{
    if (!key) {
        return @"";
    }
    
    if (!params) {
        return @"";
    }
    
    id object = params[key];
    if ( ![object isKindOfClass:[NSArray class]] ) {
        return @"";
    }
    
    NSArray *employees = (NSArray *)object;
    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:employees.count];
    for (Employ *emp in employees) {
        if ( emp._id ) {
            [ids addObject:[emp._id description]];
        }
    }
    return [ids componentsJoinedByString:@","];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
//        _tableView.delegate   = self;
        
        _tableView.rowHeight = 90;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView removeBlankCells];
        
        _tableView.backgroundColor = [UIColor clearColor];
        
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[AWTableViewDataSource alloc] initWithArray:nil
                                                         cellClass:@"OACell2"
                                                        identifier:@"oa.cell"];
        
        __weak typeof(self) me = self;
        _dataSource.itemDidSelectBlock = ^(UIView<AWTableDataConfig> *sender, id selectedData) {
            [me selectFlow:selectedData];
        };
    }
    return _dataSource;
}

- (void)selectFlow:(id)data
{
    NSMutableArray *temp = [self.params[@"flows"] mutableCopy];
    
    [temp addObject:@{ @"title": data[@"flow_desc"] ?: @"", @"mid": data[@"mid"] }];
    
    id object = @{
                  @"flows": temp ?: @[],
                  @"field_name": self.params[@"field_name"],
                  };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowSearchResultDidSelectNotification"
                                                        object:object];
    
    NSInteger viewControllers = [[self.navigationController viewControllers] count];
    if ( viewControllers >= 3 ) {
        UIViewController *vc = [self.navigationController viewControllers][viewControllers - 3];
        [self.navigationController popToViewController:vc animated:YES];
    }
}

@end

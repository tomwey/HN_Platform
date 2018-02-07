//
//  ContactVC.m
//  HN_ERP
//
//  Created by tomwey on 2/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContactVC.h"
#import "Defines.h"

@interface ContactVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) BOOL needReloadData;

@end

@implementation ContactVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                        image:[UIImage imageNamed:@"tab_contact.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_contact_click.png"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"通讯录";

    [self addLeftItemWithView:nil];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 44)];
    [self.contentView addSubview:self.searchBar];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundImage = AWImageFromColor([UIColor whiteColor]);
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    
    self.tableView.top = self.searchBar.bottom;
    self.tableView.height -= self.searchBar.height;
    
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.rowHeight = 60;
    
    // 添加下拉刷新
    __weak ContactVC *weakSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        __strong ContactVC *strongSelf = weakSelf;
        if ( strongSelf ) {
            [strongSelf loadData];
        }
    }];
    
    // 配置下拉刷新功能
    HNRefreshView *stopView = [[HNRefreshView alloc] init];
    stopView.text = @"下拉刷新";
    
    HNRefreshView *loadingView = [[HNRefreshView alloc] init];
    loadingView.text = @"加载中...";
    loadingView.animated = YES;
    
    HNRefreshView *triggerView = [[HNRefreshView alloc] init];
    triggerView.text = @"松开刷新";
    triggerView.animated = YES;
    
    [_tableView.pullToRefreshView setCustomView:triggerView forState:SVPullToRefreshStateTriggered];
    [_tableView.pullToRefreshView setCustomView:loadingView forState:SVPullToRefreshStateLoading];
    [_tableView.pullToRefreshView setCustomView:stopView forState:SVPullToRefreshStateStopped];
    
//    self.tableView.sectionHeaderHeight = 0.000001;
//    self.tableView.sectionFooterHeight = 0.000001;
    
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.tableView removeBlankCells];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    [self loadData];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"通讯录"
                                    keyMemo:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.needReloadData ) {
        [self loadData];
    }
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{ @"dotype": @"selman",
                        @"orgid": @"0"}
     completion:^(id result, NSError *error) {
         [me handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    id = 1690706;
    //    itype = 0;
    //    level = 99;
    //    name = "\U79d8\U4e66\U7ec4";
    //    pid = 1685007;
    [self.tableView removeErrorOrEmptyTips];
    
    [self.tableView.pullToRefreshView stopAnimating];
    
    if ( error ) {
//        [self.contentView makeToast:error.domain];
//        [self.contentView showHUDWithText:error.domain succeed:NO];
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
        self.needReloadData = YES;
    } else {
        if ( [result[@"rowcount"] integerValue] > 0) {
            self.needReloadData = NO;
//            Breadcrumb * bread = [[Breadcrumb alloc] initWithName:@"合能集团" page:self
//                                  ];
//            NSString *corpID = [[UserService sharedInstance] currentUser][@"corp_id"];
//            bread.deptID = @(1);
            
            NSArray *rootBB = @[
                                [[Breadcrumb alloc] initWithName:@"通讯录" page:self
                                 ],
                                //bread
                                ];
            
            NSMutableArray *temp = [NSMutableArray array];
            NSArray *data = result[@"data"];
            for (id dict in data) {
                if ( [dict[@"level"] integerValue] < 100 ) {
                    
                    NSMutableArray *breadcrumbs = [NSMutableArray arrayWithArray:rootBB];
                    
                    id item = [dict mutableCopy];
                    
                    Breadcrumb * b = [[Breadcrumb alloc] initWithName:item[@"name"] page:nil
                                      ];
                    b.deptID = @([item[@"id"] integerValue]);
                    [breadcrumbs addObject:b];
                    
                    item[@"breadcrumbs"] = breadcrumbs;
                    [temp addObject:item];
                }
            }
            
            self.dataSource = temp;
        } else {
            self.needReloadData = YES;
            self.dataSource = nil;
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                     reloadDelegate:nil];
//            self.tableView
        }
        //        [AppManager sharedInstance].breadcrumbs = breadcrumbs;
        //        NSLog(@"bread: %@", breadcrumbs);
        [self.tableView reloadData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [EmploySearchVC showInPage:AWAppWindow().navController params:@{ @"supports_selecting": @(NO), @"oper_type": @(0) }];
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id item = self.dataSource[indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:item[@"icon"]];
    cell.textLabel.text = item[@"name"];
    
//    if ( [item[@"type"] integerValue] == 0 ) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00000001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = self.dataSource[indexPath.row];
    [AppManager sharedInstance].breadcrumbs = item[@"breadcrumbs"];
    
    NSMutableDictionary *params = [self.params mutableCopy];
    params[@"dept_id"] = [item[@"id"] description];
    params[@"supports_selecting"] = @(NO);
    params[@"oper_type"] = @(0);
    params[@"title"] = item[@"name"] ?: @"联系人";
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
    
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

@end

//
//  SelectContactVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SelectContactVC.h"
#import "Defines.h"

@interface SelectContactVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSMutableDictionary *apiParams;

@end
@implementation SelectContactVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = self.params[@"title"] ?: @"选择联系人";
    
    [self addLeftItemWithView:nil];
    
    NSString *deptID = [[[UserService sharedInstance] currentUser][@"dept_id"] description];
    self.apiParams = [@{ @"dotype": @"selman",
                         @"orgid": deptID} mutableCopy];
    
    __weak typeof(self) me = self;
    [self addLeftItemWithTitle:@"取消" size:CGSizeMake(40, 40) callback:^{
        [me dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.rowHeight = 60;

    [self.tableView removeBlankCells];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 84)];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 44)];
    searchBar.placeholder = @"搜索名字";
    [tableHeader addSubview:searchBar];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.backgroundImage = AWImageFromColor([UIColor whiteColor]);
    searchBar.delegate = self;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:tableHeader];
    line.position = CGPointMake(0, searchBar.bottom);
    
    UILabel *tipLabel = AWCreateLabel(CGRectMake(15, searchBar.bottom,
                                                 120, 40),@"企业通讯录",
                                      NSTextAlignmentLeft, nil,MAIN_THEME_COLOR);
    [tableHeader addSubview:tipLabel];
    
    self.tableView.tableHeaderView = tableHeader;
    
    [self loadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:self.apiParams
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
   
    NSString *corpID = [[UserService sharedInstance] currentUser][@"corp_id"];
    NSString *deptID = [[UserService sharedInstance] currentUser][@"dept_id"];
    if ( error ) {
        self.dataSource = @[@{
                                @"id": corpID,
                                @"icon": @"contact_icon_logo.png",
                                @"name": @"合能集团",
                                @"type": @"0",
                                }];
    } else {
        Breadcrumb * bread = [[Breadcrumb alloc] initWithName:@"合能集团" page:nil
                              ];
        bread.deptID = @(0);
        
        NSArray *rootBB = @[
                            [[Breadcrumb alloc] initWithName:@"联系人" page:self
                             ],
                            bread
                            ];
        id comp = @{
                    @"id": @"0",
                    @"icon": @"contact_icon_logo.png",
                    @"name": @"合能集团",
                    @"type": @"0",
                    @"breadcrumbs": rootBB,
                    };
        
        if ( [result[@"rowcount"] integerValue] > 0) {
            NSMutableArray *temp = [NSMutableArray array];
            
            NSMutableArray *breadcrumbs = [NSMutableArray arrayWithArray:rootBB];
            
            NSMutableArray *depts = [NSMutableArray array];
            
            for (int i=0; i < [result[@"data"] count]; i++) {
                id item = result[@"data"][i];
                NSLog(@"name: %@", item[@"name"]);
                if ( [item[@"itype"] integerValue] == 0 &&
                    [item[@"level"] integerValue] > 99 ) {
                    
                    [depts addObject:item];
//                    
//                    Breadcrumb * b = [[Breadcrumb alloc] initWithName:item[@"name"] page:nil
//                                          ];
//                    b.deptID = @([item[@"id"] integerValue]);
//                    [breadcrumbs addObject:b];
//                    
//                    [temp addObject:item[@"name"]];
                }
            }
            
            [depts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1[@"level"] integerValue] < [obj2[@"level"] integerValue];
            }];
            
            for (id item in depts) {
                
                Breadcrumb * b = [[Breadcrumb alloc] initWithName:item[@"name"] page:nil
                                  ];
                b.deptID = @([item[@"id"] integerValue]);
                [breadcrumbs addObject:b];
                
                [temp addObject:item[@"name"]];

            }
            
            id newItem = @{
                           @"id": deptID,
                           @"icon": @"create_sub_dept_line.png",
                           @"name": [temp componentsJoinedByString:@"-"],
                           @"type": @"0",
                           @"breadcrumbs": breadcrumbs,
                           };
            self.dataSource = @[comp, newItem];
        } else {
            self.dataSource = @[comp];
        }
//        [AppManager sharedInstance].breadcrumbs = breadcrumbs;
//        NSLog(@"bread: %@", breadcrumbs);
    }
    
    [self.tableView reloadData];
    
    [self gotoEmpList:1 animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSMutableDictionary *newParams = [self.params mutableCopy];
    newParams[@"supports_selecting"] = @([self.params[@"oper_type"] integerValue] == 2 ? YES : NO);
    newParams[@"oper_type"] = self.params[@"oper_type"] ?: @"0";
    
    [EmploySearchVC showInPage:self params:[newParams copy]];
    
    return NO;
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
        
    }
    
    if ( indexPath.row == 0 ) {
        cell.imageView.layer.cornerRadius = 20;
        cell.imageView.clipsToBounds = YES;
    }
    
    id item = self.dataSource[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:item[@"icon"]];
    cell.textLabel.text = item[@"name"];
    
    if ( [item[@"type"] integerValue] == 0 ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = self.dataSource[indexPath.row];
    
    if ( indexPath.row == 0 ) {
        
        [AppManager sharedInstance].breadcrumbs = item[@"breadcrumbs"];
        // 集团总部
        NSMutableDictionary *params = [self.params mutableCopy];
        params[@"dept_id"] = @"0";//[[[UserService sharedInstance] currentUser][@"corp_id"] description];
        params[@"supports_selecting"] = @(YES);
        params[@"title"] = item[@"name"] ?: @"";
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 个人所在用户组
        [self gotoEmpList:indexPath.row animated:YES];
    }
}

- (void)gotoEmpList:(NSInteger)index animated:(BOOL)animated
{
    if (index < self.dataSource.count) {
        id item = self.dataSource[index];
        
        [AppManager sharedInstance].breadcrumbs = item[@"breadcrumbs"];
        
        NSMutableDictionary *params = [self.params mutableCopy];
        params[@"dept_id"] = item[@"id"];
        params[@"supports_selecting"] = @([self.params[@"oper_type"] integerValue] == 2 ? YES : NO);
        params[@"title"] = item[@"name"] ?: @"";
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

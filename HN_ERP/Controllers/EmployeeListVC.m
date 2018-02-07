//
//  EmployeeListVC.m
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "EmployeeListVC.h"
#import "Defines.h"
#import "EmployCell.h"
#import "Employ.h"
#import "AddContactsModel.h"

@interface EmployeeListVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) EmployeeOperType operType;

//@property (nonatomic, strong) NSArray *selectedPeople;

@property (nonatomic, strong) NSMutableDictionary *apiParams;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) BOOL supportsSelectingPerson;

@property (nonatomic, strong) UIScrollView *breadcrumbContainer;

@property (nonatomic, strong, readonly) AddContactsModel *contactsModel;

@end

@implementation EmployeeListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = self.params[@"title"] ?: @"选择联系人";
    
    self.operType = [self.params[@"oper_type"] integerValue];
    
    self.supportsSelectingPerson = [self.params[@"supports_selecting"] boolValue];
    
    self.apiParams = [@{ @"dotype": @"selman",
                         @"orgid": [self.params[@"dept_id"] description]} mutableCopy];
    self.dataSource = [[NSMutableArray alloc] init];
    
    if (self.operType != EmployeeOperTypeView) {
        __weak typeof(self) me = self;
        [self addRightItemWithTitle:@"确定" size:CGSizeMake(40, 40) callback:^{
            [me dismiss];
        }];
    }
    
    CGFloat height = [self addSearchBarAndBreadcrumb];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    self.tableView.top = height - 1;
    self.tableView.height -= height;
    
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
//    self.tableView.sectionFooterHeight = 0;
//    self.tableView.sectionHeaderHeight = 10;
    
    self.tableView.rowHeight = 60;
    
    [self.tableView removeBlankCells];
    
    [self loadData];
}

- (CGFloat)addSearchBarAndBreadcrumb
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 88)];
    [self.contentView addSubview:container];
    container.backgroundColor = [UIColor whiteColor];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, container.width, 44)];
    [container addSubview:self.searchBar];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
    
    self.breadcrumbContainer = [[UIScrollView alloc] initWithFrame:self.searchBar.frame];
    self.breadcrumbContainer.top = self.searchBar.bottom;
    self.breadcrumbContainer.showsHorizontalScrollIndicator = NO;
//    self.breadcrumbContainer.backgroundColor = [UIColor redColor];
    [container addSubview:self.breadcrumbContainer];
    
    CGFloat posX = 20;
    UIButton *lastBtn = nil;
    for (int i = 0; i< [AppManager sharedInstance].breadcrumbs.count; i++) {
        Breadcrumb *b = [AppManager sharedInstance].breadcrumbs[i];
        
        UIButton *btn = AWCreateTextButton(CGRectZero,
                                           b.name,
                                           MAIN_THEME_COLOR,
                                           self,
                                           @selector(breadcrumbClick:));
        [self.breadcrumbContainer addSubview:btn];
        [btn sizeToFit];
//        btn.width += 20;
//        btn.backgroundColor = [UIColor blackColor];
        
        btn.position = CGPointMake(posX - 10,
                                   self.breadcrumbContainer.height / 2 - btn.height / 2);
        
        posX = btn.right + 50;
        
        btn.tag = 1000 + i;
        
        if ( i == [AppManager sharedInstance].breadcrumbs.count - 1 ) {
            lastBtn = btn;
            [btn setTitleColor:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR forState:UIControlStateNormal];
            btn.userInteractionEnabled = NO;
        } else {
            UIImageView *arrowView = AWCreateImageView(@"icon_arrow-right.png");
            [self.breadcrumbContainer addSubview:arrowView];
            arrowView.center = CGPointMake(btn.right + 10 + arrowView.width / 2, btn.midY);
        }
    }
    
    self.breadcrumbContainer.contentSize = CGSizeMake(posX, self.breadcrumbContainer.height);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame = lastBtn.frame;
        frame.origin.x += 50;
        [self.breadcrumbContainer scrollRectToVisible: frame animated:YES];
    });
    
    return container.height;
}

- (void)breadcrumbClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 1000;
    Breadcrumb *b = [AppManager sharedInstance].breadcrumbs[index];
    if ( b.page ) {
        UIViewController *vc = [[self.navigationController viewControllers] firstObject];
        if ( [NSStringFromClass([vc class]) isEqualToString:@"LoginVC"] ) {
            [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
//        [self.navigationController popToViewController:b.page animated:YES];
    } else {
        [self updateBreadcrumbsForIndex:index];
        
        // 跳转
        NSMutableDictionary *params = [self.params mutableCopy];
        params[@"dept_id"] = [b.deptID description];
        params[@"supports_selecting"] = @(YES);
        params[@"title"] = b.name ?: @"联系人";
        UINavigationController *navControl = self.navigationController;
        
        UIViewController *rootVC = [[self.navigationController viewControllers] firstObject];
        if ( [NSStringFromClass([rootVC class]) isEqualToString:@"LoginVC"] ) {
            [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:NO];
        } else {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        
//        [navControl popToRootViewControllerAnimated:NO];
        
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
        
        [navControl pushViewController:vc animated:YES];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [EmploySearchVC showInPage:self params:self.params];
    return NO;
}

- (void)updateBreadcrumbsForIndex:(NSInteger)index
{
    NSMutableArray *temp = [[AppManager sharedInstance].breadcrumbs mutableCopy];
    NSInteger count = temp.count;
    
    [temp removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, count - index - 1)]];
    [AppManager sharedInstance].breadcrumbs = [temp copy];
}

- (void)loadData
{
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:self.apiParams
     completion:^(id result, NSError *error) {
         [me handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    if ( error ) {
//        [self.contentView makeToast:error.domain];
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.contentView makeToast:@"暂时没有数据"];
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                     reloadDelegate:nil];
        } else {
            NSArray *results = result[@"data"];
            NSMutableArray *employs = [NSMutableArray array];
            NSMutableArray *employees = [NSMutableArray array];
            for (int i=0; i<results.count; i++) {
//                id: 1685007,
//                itype: 0,
//                level: 100,
//                name: "运营管理部",
//                pid: 1679537
                id item = results[i];
                
                if ( ![[item[@"pid"] description] isEqualToString:self.apiParams[@"orgid"]] ) {
                    continue;
                }
                
                if ( [item[@"itype"] integerValue] == 0 ) {
                    // 部门
                    [employs addObject:item];
                } else {
                    // 人
                    
                    Employ *employ = [[Employ alloc] initWithDictionary:item];
                    employ.avatar = @"default_avatar.png";
                    employ.supportsSelecting = [self.params[@"oper_type"] integerValue] == 2 ? @(YES) : @(NO);
                    //@(self.supportsSelectingPerson);
                    employ.job = item[@"station_name"];//@"经理";
                    
                    /////////////// 新增的补丁
                    if ( self.contactsModel ) {
                        employ.checked = @([self.contactsModel.selectedPeople containsObject:employ]);
                    }
                    ///////////////
                    
                    [employees addObject:employ];
                }
            }
            
            if ( employs.count > 0 ) {
                [self.dataSource addObject:employs];
            }
            
            if ( employees.count > 0 ) {
                [self.dataSource addObject:employees];
            }
            
            if ( [self.dataSource count] == 0 ) {
                [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                         reloadDelegate:nil];
            } else {
                [self.tableView removeErrorOrEmptyTips];
            
                [self.tableView reloadData];
            }
        }
    }
}

- (AddContactsModel *)contactsModel
{
    id obj = self.params[@"contacts.model"];
    if ( !obj ) {
        return nil;
    }
    
    if ( [obj isKindOfClass:[AddContactsModel class]] ) {
        return (AddContactsModel *)obj;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = self.dataSource[section];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.section][indexPath.row];
    if ( [item isKindOfClass:[NSDictionary class]] ) {
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
        if ( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell.id"];
    //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = item[@"name"];
        cell.detailTextLabel.text = item[@"job"];
        cell.detailTextLabel.textColor = AWColorFromRGB(201,201,201);
        cell.detailTextLabel.font = AWSystemFontWithSize(14, NO);
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    // 员工
    EmployCell *cell = (EmployCell *)[tableView dequeueReusableCellWithIdentifier:@"employ.cell"];
    if ( !cell ) {
        cell = [[EmployCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"employ.cell"];
//        cell.separatorInset = UIEdgeInsetsMake(0, 105, 0, 0);
    }
    
    cell.employ = item;
    cell.checked = [cell.employ.checked boolValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.operType != EmployeeOperTypeView ) {
        if ( self.operType == EmployeeOperTypeRadio ) {
            [self handleRadioSelectForIndexPath:indexPath];
        } else if ( self.operType == EmployeeOperTypeCheckbox ) {
            [self handleCheckboxSelectForIndexPath:indexPath];
        }
    } else {
        id item = self.dataSource[indexPath.section][indexPath.row];
        if ( [item isKindOfClass:[NSDictionary class]] ) {
            // 部门
            
            [self updateBreadcrumb:item];
            
            NSMutableDictionary *params = [self.params mutableCopy];
            params[@"dept_id"] = item[@"id"];
            params[@"supports_selecting"] = @(NO);
            params[@"title"] = item[@"name"] ?: @"";
            //        params[@"selected"] = self.selectedPeople ?: @[];
            
            UINavigationController *navControl = self.navigationController;
//            [navControl popToRootViewControllerAnimated:NO];
            UIViewController *rootVC = [[self.navigationController viewControllers] firstObject];
            if ( [NSStringFromClass([rootVC class]) isEqualToString:@"LoginVC"] ) {
                [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:NO];
            } else {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
            [navControl pushViewController:vc animated:YES];
        } else {
            // 人员
            EmployCell *cell = (EmployCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            Employ *emp = cell.employ;
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MancardVC" params:@{ @"manid": [emp._id description]}];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return 0.00001;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (void)updateBreadcrumb:(id)item
{
    NSMutableArray *breadcrumbs = [[AppManager sharedInstance].breadcrumbs mutableCopy];
    Breadcrumb *b = [[Breadcrumb alloc] initWithName:item[@"name"] page:nil];
    b.deptID = @([item[@"id"] integerValue]);
    [breadcrumbs addObject:b];
    
    [AppManager sharedInstance].breadcrumbs = [breadcrumbs copy];
}

- (void)handleRadioSelectForIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.section][indexPath.row];
    if ( [item isKindOfClass:[NSDictionary class]] ) {
        // 部门
        
        [self updateBreadcrumb:item];
        
        NSMutableDictionary *params = [self.params mutableCopy];
        params[@"dept_id"] = item[@"id"];
        params[@"title"] = item[@"name"] ?: @"";
//        params[@"selected"] = self.selectedPeople ?: @[];
        UINavigationController *navControl = self.navigationController;
//        [navControl popToRootViewControllerAnimated:NO];
        UIViewController *rootVC = [[self.navigationController viewControllers] firstObject];
        if ( [NSStringFromClass([rootVC class]) isEqualToString:@"LoginVC"] ) {
            [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:NO];
        } else {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
        [navControl pushViewController:vc animated:YES];
        
//        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
//        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 人员
//        EmployCell *cell = (EmployCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        self.selectedPeople = @[item];
        
        self.contactsModel.selectedPeople = @[item];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kContactDidSelectNotification" object:self.contactsModel];
        
        [self dismiss];
    }
}

- (void)handleCheckboxSelectForIndexPath:(NSIndexPath *)indexPath
{

    id item = self.dataSource[indexPath.section][indexPath.row];
    if ( [item isKindOfClass:[NSDictionary class]] ) {
        // 部门
        
        [self updateBreadcrumb:item];
        
        NSMutableDictionary *params = [self.params mutableCopy];
        params[@"dept_id"] = item[@"id"];
//        params[@"selected"] = self.selectedPeople ?: @[];
        params[@"title"] = item[@"name"] ?: @"";
        
        UINavigationController *navControl = self.navigationController;
//        [navControl popToRootViewControllerAnimated:NO];
        UIViewController *rootVC = [[self.navigationController viewControllers] firstObject];
        if ( [NSStringFromClass([rootVC class]) isEqualToString:@"LoginVC"] ) {
            [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:NO];
        } else {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
        [navControl pushViewController:vc animated:YES];
        
//        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmployeeListVC" params:params];
//        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 人员
        EmployCell *cell = (EmployCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.checked = !cell.checked;
        cell.employ.checked = @(cell.checked);
        
        // 后期新增代码
        NSMutableArray *temp2 = [(self.contactsModel.selectedPeople ?: @[]) mutableCopy];
        if ( cell.checked ) {
            [temp2 addObject:cell.employ];
        } else {
            [temp2 removeObject:cell.employ];
        }
        self.contactsModel.selectedPeople = [temp2 copy];
        ////////////////////////////////////////////////////////
        
        NSLog(@"selected: %@", self.contactsModel);
    }
}

- (void)dismiss
{
    if ( self.operType == EmployeeOperTypeCheckbox ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kContactDidSelectNotification" object:self.contactsModel];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kContactDidSelect2Notification" object:self.contactsModel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

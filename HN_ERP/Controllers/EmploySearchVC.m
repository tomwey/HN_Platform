//
//  EmploySearchVC.m
//  HN_ERP
//
//  Created by tomwey on 2/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "EmploySearchVC.h"
#import "Defines.h"
#import "Employ.h"
#import "EmployCell.h"
#import "AddContactsModel.h"

@interface EmploySearchVC () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView    *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong, readonly) AddContactsModel *contactsModel;

@property (nonatomic, weak) UISearchBar *searchBar;

@end

@implementation EmploySearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    headerView.backgroundColor = MAIN_THEME_COLOR;
    [self.view addSubview:headerView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *closeBtn = HNCloseButton(34, self, @selector(back));
    [headerView addSubview:closeBtn];
    closeBtn.center = CGPointMake(2 + closeBtn.width / 2, 42);
    
    CGFloat width = 0;
    if ( [self.params[@"oper_type"] integerValue] == 2 ) {
        UIButton *rightBtn = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
                                                @"确定",
                                                [UIColor whiteColor],
                                                self,
                                                @selector(done));
        [headerView addSubview:rightBtn];
        rightBtn.center = CGPointMake(headerView.width - 9 - rightBtn.width / 2, 42);
        
        width = rightBtn.width + 10;
    } else {
        
    }
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, headerView.bottom, self.view.width, 44)];
//    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.backgroundImage = AWImageFromColor([UIColor clearColor]);
    searchBar.placeholder  = @"输入姓名";
    searchBar.frame = CGRectMake(0,
                                 0, self.view.width - closeBtn.right - 15 - width - 15, 44);
    
    searchBar.center = CGPointMake(self.view.width / 2, closeBtn.midY);
    
    [self.view addSubview:searchBar];
    
    self.searchBar = searchBar;
    
    searchBar.delegate = self;
    
    self.dataSource = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.top = headerView.bottom;
    self.tableView.height -= headerView.height;
    
    self.tableView.rowHeight = 60;
    
    [self.tableView removeBlankCells];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    self.moveContentView = [[UIView alloc] initWithFrame:CGRectMake(0, searchBar.bottom, self.view.width, self.view.height - searchBar.bottom)];
//    [self.view addSubview:self.moveContentView];
    
//    [self addContents];
    
//    [UIView animateWithDuration:.3 animations:^{
//        searchBar.frame = CGRectMake(0,
//                                     0, self.view.width - backBtn.right - 10 - 15, 44);
//        searchBar.center = CGPointMake(self.view.width / 2, backBtn.midY);
//        
////        self.moveContentView.top -= 44;
////        self.moveContentView.height += 44;
//        
//    } completion:^(BOOL finished) {
////        searchBar.searchBarStyle = UISearchBarStyleDefault;
//        [searchBar becomeFirstResponder];
//    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [searchBar becomeFirstResponder];
    });
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

- (void)done
{
    if (self.contactsModel.selectedPeople.count == 0) return;
    
    [self.searchBar resignFirstResponder];
    
//    if ( self.operType == EmployeeOperTypeCheckbox ) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kContactDidSelectNotification" object:self.contactsModel];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kContactDidSelect2Notification" object:self.contactsModel];
//    }
    if ( self.params[@"is_just_remove"] ) {
        [self dismiss];
    } else {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect rect = [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    self.tableView.height = self.view.height - rect.size.height - 64;
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    self.tableView.height = self.view.height - 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployCell *cell = (EmployCell *)[tableView dequeueReusableCellWithIdentifier:@"employ.cell"];
    if ( !cell ) {
        cell = [[EmployCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"employ.cell"];
    }
    
    if ( indexPath.row < self.dataSource.count) {
        cell.employ = self.dataSource[indexPath.row];
        if ( [cell.employ.supportsSelecting boolValue] ) {
            cell.checked = [cell.employ.checked boolValue];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger type = [self.params[@"oper_type"] integerValue];
    
    if ( type == 0 ) {
        // 查看
        EmployCell *cell = (EmployCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        Employ *emp = cell.employ;
        
        UINavigationController *navController = self.parentViewController.navigationController;
        if ( !navController ) {
            navController = AWAppWindow().navController;
        }
        
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MancardVC" params:@{ @"manid": [emp._id description]}];
        [navController pushViewController:vc animated:YES];
    } else if ( type == 1 ) {
        // 单选
        [self.searchBar resignFirstResponder];
        
        self.contactsModel.selectedPeople = @[self.dataSource[indexPath.row]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kContactDidSelectNotification" object:self.contactsModel];
        
        if ( self.params[@"is_just_remove"] ) {
            [self dismiss];
        } else {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if ( type == 2 ) {
        // 多选
        EmployCell *cell = (EmployCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.checked = !cell.checked;
        cell.employ.checked = @(cell.checked);
        
        NSMutableArray *temp = [([AppManager sharedInstance].selectedPeople ?: @[]) mutableCopy];
        if ( cell.checked ) {
            [temp addObject:cell.employ];
        } else {
            [temp removeObject:cell.employ];
        }
        
        //        self.selectedPeople = [temp copy];
        [AppManager sharedInstance].selectedPeople = [temp copy];
        
        // 后期新增代码
        NSMutableArray *temp2 = [(self.contactsModel.selectedPeople ?: @[]) mutableCopy];
        if ( cell.checked ) {
            [temp2 addObject:cell.employ];
        } else {
            [temp2 removeObject:cell.employ];
        }
        self.contactsModel.selectedPeople = [temp2 copy];
        ////////////////////////////////////////////////////////
    }
}

- (void)back
{
    [self dismiss];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self dismiss];
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if ( [searchBar.text trim].length == 0 ) {
//        return;
//    }
//    
//    [self doSearch:[searchBar.text trim]];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ( [searchBar.text trim].length == 0 ) {
        return;
    }
    
    [searchBar resignFirstResponder];
    [self doSearch:[searchBar.text trim]];
}

- (void)doSearch:(NSString *)keyword
{
    [HNProgressHUDHelper hideHUDForView:self.tableView animated:YES];
    
    [HNProgressHUDHelper showHUDAddedTo:self.tableView animated:YES];
    
    [self.dataSource removeAllObjects];
//    [self.tableView removeErrorOrEmptyTips];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"selman",
                       @"manname": keyword,
                       } completion:^(id result, NSError *error) {
                           [me handleResult:result error:error];
                       }];
}

+ (void)showInPage:(UIViewController *)page params:(NSDictionary *)params
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"EmploySearchVC" params:params];
    [page addChildViewController:vc];
    
    [page.view addSubview:vc.view];
    
    vc.view.frame = CGRectMake(0, 64, page.view.width, page.view.height);
    vc.view.alpha = 0.0;
    //    vc.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:.3 animations:^{
        vc.view.frame = page.view.bounds;
        vc.view.alpha = 1.0;
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.tableView animated:YES];
    
    if ( error ) {
//        [self.view makeToast:error.domain];
//        [self.tableView showErrorOrEmptyToast:error.domain];
        self.tableView.hidden = YES;
        
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            NSArray *data = result[@"data"];
            for (id dict in data) {
                
                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                item[@"checked"] = @(NO);
                item[@"icon"] = @"default_avatar.png";
                item[@"id"]   = dict[@"man_id"] ?: @"";
                item[@"itype"] = @"0";
                item[@"job"] = dict[@"station_name"] ?: @"";
                item[@"level"] = dict[@"safelevel"] ?: @"";
                item[@"name"] = dict[@"man_name"] ?: @"";
                item[@"pid"] = dict[@"topdept_id"] ?: @"";
                item[@"supports_selecting"] = [self.params[@"oper_type"] integerValue] == 2 ? @(YES) : @(NO);
                
                Employ *emp = [[Employ alloc] initWithDictionary:item];
                if ( [self.params[@"oper_type"] integerValue] == 2 ) {
                    emp.checked = @([[AppManager sharedInstance].selectedPeople containsObject:emp]);
                    
                    /////////////// 新增的补丁
                    if ( self.contactsModel ) {
                        emp.checked = @([self.contactsModel.selectedPeople containsObject:emp]);
                    }
                    ///////////////
                    
                } else {
                    emp.checked = @(NO);
                }
                
                [self.dataSource addObject:emp];
            }
            
            [self.tableView removeErrorOrEmptyTips];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        } else {
            self.tableView.hidden = YES;
            
            [self.tableView reloadData];
            
            [self.tableView showErrorOrEmptyMessage:@"<未搜索到结果>"
                                     reloadDelegate:nil];
//            [self.view makeToast:@"未找到记录"];
        }
    }
}

- (void)dismiss
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end

//
//  FlowbackListVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowbackListVC.h"
#import "Defines.h"

@interface FlowbackListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) NSInteger selectedIndex;

@end
@implementation FlowbackListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"节点列表";
    
    self.selectedIndex = NSNotFound;
    
//    [self loadData];
//    [self handleResult: error:<#(NSError *)#>]
    self.dataSource = self.params[@"nodes"];
    
    [self.tableView reloadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"flowbacklist",
              @"manid": manID,
              @"mid": self.params[@"mid"],
              } completion:^(id result, NSError *error) {
                  [me handleResult: result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
//        [self.contentView makeToast:error.domain];
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            self.dataSource = result[@"data"];
            [self.tableView reloadData];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    id item = self.dataSource[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%@）",
                           item[@"node_name"],
                           item[@"domanname"]];
    
    if ( self.selectedIndex == indexPath.row ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 取消以前选中的
    if ( self.selectedIndex != NSNotFound &&
        self.selectedIndex != indexPath.row ) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:previousIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // 勾选当前行
    self.selectedIndex = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 跳转到退回操作页面
    id action = @{@"name": @"退回", @"action": @"back"};
    UIViewController *vc =
    [[AWMediator sharedInstance] openVCWithName:@"BackVC"
                                         params:@{
                                                    @"action": action,
                                                    @"node": self.dataSource[self.selectedIndex],
                                                    @"mid": self.params[@"mid"],
                                                    @"did": self.dataSource[self.selectedIndex][@"did"],
                                                    @"item": self.params[@"item"],
                                                    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView removeBlankCells];
        
//        _tableView.rowHeight = 60;
    }
    return _tableView;
}

@end

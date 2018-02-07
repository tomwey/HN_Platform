//
//  LandAnnexListVC.m
//  HN_ERP
//
//  Created by tomwey on 6/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandAnnexListVC.h"
#import "Defines.h"

@interface LandAnnexListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation LandAnnexListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"相关附件列表";
    
    [self loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id item = self.dataSource[indexPath.row];
    
    cell.textLabel.text = item[@"annex_name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = self.dataSource[indexPath.row];
    
    NSString *url = HNStringFromObject(item[@"url"], @"");
    NSDictionary *params = [[[url componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *newItem = [params mutableCopy];
    newItem[@"addr"] = params[@"file"] ?: @"";
    newItem[@"docid"] = params[@"fileid"] ?: @"0";
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": newItem }];
    [self.navigationController pushViewController:vc animated:YES];
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
              @"funname": @"土地信息相关附件查询APP",
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
            self.dataSource = result[@"data"];
            
            [self.tableView reloadData];
        }
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 50;
    }
    
    return _tableView;
}

@end

//
//  DocAttachmentListVC.m
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DocAttachmentListVC.h"
#import "Defines.h"

@interface DocAttachmentListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation DocAttachmentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"相关附件列表";
    
    [self loadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"移动端公文相关附件查询",
              @"param1": self.params[@"item"][@"docid"] ?: @"",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
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
    cell.textLabel.text = item[@"filename"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *url = self.dataSource[indexPath.row][@"url"];
    NSDictionary *params = [[[url componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
    
    id item = @{
                @"isdoc": params[@"isdoc"] ?: @"",
                @"docid": params[@"fileid"] ?: @"0",
                @"addr": params[@"file"] ?: @"",
                @"filename": self.dataSource[indexPath.row][@"filename"] ?: @"",
                };
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": item }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            self.dataSource = result[@"data"];
        } else {
            
        }
        [self.tableView reloadData];
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
    }
    return _tableView;
}

@end

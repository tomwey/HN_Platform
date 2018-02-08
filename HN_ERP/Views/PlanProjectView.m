//
//  PlanProjectView.m
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanProjectView.h"
#import "Defines.h"

@interface PlanProjectView () <UITableViewDelegate>

@property (nonatomic, strong) UILabel *coomingSoonLabel;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation PlanProjectView

- (void)startLoading
{
//    self.coomingSoonLabel.text = @"敬请期待...";
    [HNProgressHUDHelper showHUDAddedTo:self.superview animated:YES];
    id user = [[UserService sharedInstance] currentUser];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"工作计划APP",
              @"param1": [self.userData description],
              @"param2": [user[@"man_id"] ?: @"0" description]
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.superview animated:YES];
    
    if (error) {
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
        } else {
            [self.tableView removeErrorOrEmptyTips];
            
            NSArray *data = result[@"data"];
            
            NSMutableArray *temp = [NSMutableArray array];
            
            for (id dict in data) {
                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                item[@"docid"] = dict[@"mid"];
                item[@"title"] = dict[@"filename"];
                item[@"area"]  = dict[@"area_name"];
                item[@"scope"] = dict[@"project_name"] ?: @"";
                item[@"type"] = dict[@"plansubtype"];
                
                NSDictionary *params = [[[[dict[@"url"] description] componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
                
                item[@"addr"]  = params[@"file"] ?: @"";
                item[@"isdoc"] = params[@"isdoc"] ?: @"";
                item[@"docid"] = params[@"fileid"] ?: @"0";
                item[@"filename"] = params[@"filename"] ?: @"";
                
                
                NSString *time = [dict[@"fwdate"] description];
                time = [[time componentsSeparatedByString:@"T"] firstObject];
                item[@"time"] = time;
                
                item[@"is_read"] = [dict[@"isview"] integerValue] == 0 ? @(NO) : @(YES);
                item[@"host"] = dict[@"serverip"];
                item[@"port"] = dict[@"port"];
                item[@"username"] = dict[@"username"];
                item[@"pwd"] = dict[@"pwd"];
                //item[@"filename"] = dict[@"filename"];
                item[@"fileid"] = dict[@"annexid"];
                item[@"tablename"] = dict[@"tablename"];
                item[@"annexcount"] = dict[@"annexcount"] ?: @"0";
                
                [temp addObject:item];
            }
            
            self.dataSource.dataSource = temp;
            
            [self.tableView reloadData];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectItem ) {
        self.didSelectItem(self, self.dataSource.dataSource[indexPath.row]);
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        self.tableView.rowHeight = 90;
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView removeBlankCells];
        
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[AWTableViewDataSource alloc] initWithArray:nil cellClass:@"DocumentCell" identifier:@"cell.doc.id"];
    }
    return _dataSource;
}

- (UILabel *)coomingSoonLabel
{
    if ( !_coomingSoonLabel ) {
        _coomingSoonLabel = AWCreateLabel(CGRectZero,
                                          nil,
                                          NSTextAlignmentCenter,
                                          nil,
                                          [UIColor blackColor]);
        [self addSubview:_coomingSoonLabel];
        
        _coomingSoonLabel.frame = CGRectMake(0, 60, self.width, 30);
    }
    return _coomingSoonLabel;
}

@end

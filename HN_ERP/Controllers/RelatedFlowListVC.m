//
//  RelatedFlowListVC.m
//  HN_ERP
//
//  Created by tomwey on 6/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "RelatedFlowListVC.h"
#import "Defines.h"

@interface RelatedFlowListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL needReload;

@end

@implementation RelatedFlowListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"已选流程";
    
    self.dataSource = [self.params[@"flows"] ?: @[] mutableCopy];
    
    UIImage *image = [[UIImage imageNamed:@"contact_icon_add.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:image forState:UIControlStateNormal];
    addBtn.tintColor = [UIColor whiteColor];
    [addBtn sizeToFit];
    
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self addRightItemWithView:addBtn];
    
//    self.dataSource.dataSource = self.params[@"flows"] ?: @[];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFlow:) name:@"kFlowSearchResultDidSelectNotification"
                                               object:nil];
}

- (void)updateFlow:(NSNotification *)noti
{
    if ( self.needReload ) {
        self.dataSource = [noti.object[@"flows"] mutableCopy];
        
        [self.tableView reloadData];
    }
}

- (void)add
{
    self.needReload = YES;
    
//    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"FlowSearchVC" params:@{ @"field_name": self.params[@"field_name"] ?: @"related_flow", @"flows": self.dataSource ?: @[] }];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OAListVC" params:@{ @"from": self.params[@"field_name"] ?: @"related_flow" }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)remove:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除提示" message:@"您确定要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger row = [self.dataSource indexOfObject:sender.userData];
        if ( row != NSNotFound ) {
            [self.dataSource removeObject:sender.userData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            
            self.needReload = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowSearchResultDidSelectNotification" object:@{ @"field_name": self.params[@"field_name"] ?: @"related_flow", @"flows": self.dataSource ?: @[] }];
        }
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        _tableView.rowHeight  = 50;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
    }
    
    id item = self.dataSource[indexPath.row];
    
    FAKIonIcons *cancelIcon = [FAKIonIcons androidRemoveCircleIconWithSize:24];
    [cancelIcon addAttributes:@{
                                NSForegroundColorAttributeName: MAIN_THEME_COLOR
                                }];
    
    UIImage *image = [cancelIcon imageWithSize:CGSizeMake(40, 40)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    button.exclusiveTouch = YES;
    [button addTarget:self
               action:@selector(remove:)
     forControlEvents:UIControlEventTouchUpInside];
    
    button.userData = item;
    
    cell.accessoryView = button;
    
    cell.textLabel.text = item[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = self.dataSource[indexPath.row];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OADetailVC" params:@{ @"item": @{ @"mid": [item[@"mid"] description] ?: @"" }, @"has_action": @(NO),
                                                                                               @"state": @"done"}];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

@end

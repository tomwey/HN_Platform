//
//  AddSignVC.m
//  HN_ERP
//
//  Created by tomwey on 3/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AddSignVC.h"
#import "Defines.h"

@interface AddSignVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *needRemoveData;

@property (nonatomic, strong) SignToolbar    *signToolbar;

//@property (nonatomic, strong) NSArray        *selectedPeople;

@property (nonatomic, strong) UIView *tableHeaderView;

@property (nonatomic, strong) AddContactsModel *contactModel;

@end

@implementation AddSignVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"加签";
    
//    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:1];
    
    __weak typeof(self) weakSelf = self;
    
//    [self addLeftItemWithImage:@"btn_close.png" leftMargin: 5  callback:^{
//        [weakSelf dismissViewControllerAnimated:YES completion:nil];
//    }];
    UIButton *closeBtn = HNCloseButton(34, self, @selector(close));
    [self addLeftItemWithView:closeBtn leftMargin:2];
    
    [self addRightItemWithTitle:@"确定"
                titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(40, 40)
                    rightMargin:10
                       callback:^{
                           [weakSelf doSign];
                       }];
    
//    [self.tableView reloadData];
    self.tableView.rowHeight = 60;
//    self.signToolbar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addContact:)
                                                 name:@"kContactDidSelectNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCheckbox:)
                                                 name:@"kCheckboxDidSelectNotification"
                                               object:nil];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [AppManager sharedInstance].selectedPeople = nil;
}

- (void)handleCheckbox:(NSNotification *)noti
{
    id object = noti.object;
    if ( [object isKindOfClass:[SignData class]] ) {
        SignData *sd = (SignData *)object;
        if ( sd.checked ) {
            [self.needRemoveData addObject:sd];
        } else {
            [self.needRemoveData removeObject:sd];
        }
        
        NSLog(@"remove: %@", self.needRemoveData);
        
        self.signToolbar.enableDeleteButton = self.needRemoveData.count > 0;
        self.signToolbar.selectedCheckAll   = (self.needRemoveData.count > 0 && self.needRemoveData.count == self.dataSource.count);
    }
}

- (void)addContact:(NSNotification *)noti
{
//    NSLog(@"%@", noti.object);
    if ( [noti.object isKindOfClass:[AddContactsModel class]] ) {
        
        [self.dataSource removeAllObjects];
        
        for (Employ *emp in self.contactModel.selectedPeople) {
            SignData *sd = [[SignData alloc] initWithName:emp.name
                                                       ID:[emp._id description]
                                                     sort:0];
            sd.checked = [self.needRemoveData containsObject:sd];
            [self.dataSource addObject:sd];
        }

        self.signToolbar.enableDeleteButton = self.needRemoveData.count > 0;
        self.signToolbar.selectedCheckAll   = (self.needRemoveData.count > 0 && self.needRemoveData.count == self.dataSource.count);
        
        [self updateTableView];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ( self.dataSource.count == 0 ) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal.cell"];
//        if ( !cell ) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                          reuseIdentifier:@"normal.cell"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//        
//        cell.imageView.image = [UIImage imageNamed:@"contact_icon_add.png"];
//        cell.textLabel.text  = @"添加操作人";
//        
//        return cell;
//    }
    
    SignCell *cell = (SignCell *)[tableView dequeueReusableCellWithIdentifier:@"sign.cell"];
    if ( !cell ) {
        cell = [[SignCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sign.cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SignData *signData = [self signDataFromIndexPath:indexPath];
    
    cell.signData = signData;
    
    return cell;
}

- (SignData *)signDataFromIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section < self.dataSource.count ) {
        return self.dataSource[indexPath.section];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.dataSource.count == 0 ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self addSignMan];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00000001;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ( [cell isKindOfClass:[SignCell class]] ) {
            SignCell *sCell = (SignCell *)cell;
            [sCell hideKeyboard];
        }
    }
}

- (void)doSign
{
    NSLog(@"%@", self.dataSource);
    
    if ( self.dataSource.count == 0 ) {
        [self.contentView showHUDWithText:@"至少需要一个操作者" offset:CGPointMake(0,20)];
        return;
    }
    
    [self hideKeyboard];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSMutableArray *IDs = [NSMutableArray array];
    NSMutableArray *sorts = [NSMutableArray array];
    for (SignData *sd in self.dataSource) {
        [IDs addObject:sd.ID];
        [sorts addObject:[@(sd.sort) description]];
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"流程加签APP",
              @"param1": self.params[@"mid"],
              @"param2": self.params[@"nodeid"],
              @"param3": @"2",
              @"param4": manID,
              @"param5": [IDs componentsJoinedByString:@","],
              @"param6": [sorts componentsJoinedByString:@","],
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // 通知刷新流程图
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kRefreshFlowPictureNotification" object:nil];
    }
}

- (void)addSignMan
{
    UIViewController *vc =
    [[AWMediator sharedInstance] openNavVCWithName:@"SelectContactVC"
                                            params:@{ @"oper_type": @(2),
                                                      @"contacts.model": self.contactModel,
                                                      //@"title": @"添加加签操作人",
                                                      }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)removeSignMan
{
    // 更新选中的人员列表
    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];
    
    NSMutableArray *temp = [self.contactModel.selectedPeople mutableCopy];
    for (id obj in self.needRemoveData) {
        NSInteger index = [self.dataSource indexOfObject:obj];
        if ( index != NSNotFound ) {
            [sections addIndex:index];
        }
        if ( index < temp.count ) {
            [temp removeObjectAtIndex:index];
        }
    }
    
    self.contactModel.selectedPeople = [temp copy];
    
    // 移除数据源
    [self.dataSource removeObjectsInArray:self.needRemoveData];
    
    [self.needRemoveData removeAllObjects];
    
    // 移除行
    [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationTop];
    
    if ( self.dataSource.count == 0 ) {
        
        self.contactModel.selectedPeople = @[];
        
        self.signToolbar.selectedCheckAll = NO;
        self.signToolbar.hidden = YES;
        
        self.tableView.height = self.contentView.height;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.tableHeaderView = self.tableHeaderView;
            self.tableView.contentInset = UIEdgeInsetsZero;
        });
    }
    
//    [self updateTableView];
}

- (void)updateTableView
{
    if ( self.dataSource.count > 0 ) {
        self.tableView.tableHeaderView = nil;
        
        self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        
        self.signToolbar.hidden = NO;
        
        self.tableView.height = self.contentView.height - self.signToolbar.height;
    } else {
        self.tableView.tableHeaderView = self.tableHeaderView;
        self.tableView.contentInset = UIEdgeInsetsZero;
        
        self.signToolbar.hidden = YES;
        self.tableView.height = self.contentView.height;
    }
    
    [self.tableView reloadData];
}

- (void)doCheckAll:(BOOL)checked
{
    if ( checked ) {
        for (SignData *data in self.dataSource) {
            data.checked = YES;
        }
        
        [self.needRemoveData removeAllObjects];
        
        [self.needRemoveData addObjectsFromArray:self.dataSource];
        
    } else {
        for (SignData *data in self.dataSource) {
            data.checked = NO;
        }
        
        [self.needRemoveData removeAllObjects];
    }
    
    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
        [self.contentView addSubview:_tableView];
        
//        _tableView.backgroundColor = [UIColor redColor];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 1;
        
        [_tableView removeBlankCells];
        
        self.tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

- (UIView *)tableHeaderView
{
    if ( !_tableHeaderView ) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 60)];
//        _tableHeaderView.backgroundColor = [UIColor ];
        
//        _tableHeaderView.backgroundColor = [UIColor greenColor];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, self.contentView.width, 44)];
        [_tableHeaderView addSubview:contentView];
        contentView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = AWCreateLabel(CGRectMake(0, 0, 120, 44), @"添加操作人",
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       [UIColor blackColor]);
        [contentView addSubview:label];
        [label sizeToFit];
        
        label.center = CGPointMake(contentView.width / 2,
                                   contentView.height / 2);
        
        UIImageView *iconView = AWCreateImageView(@"contact_icon_add.png");
        [contentView addSubview:iconView];
        iconView.center = CGPointMake(label.left - iconView.width / 2 - 5,
                                      label.midY);
        
        [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addSignMan)]];
    }
    return _tableHeaderView;
}

- (SignToolbar *)signToolbar
{
    if ( !_signToolbar ) {
        _signToolbar = [[SignToolbar alloc] init];
        [self.contentView addSubview:_signToolbar];
        _signToolbar.position = CGPointMake(0, self.contentView.height - self.signToolbar.height);
        _signToolbar.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        _signToolbar.didCheckAllBlock = ^(SignToolbar *sender, BOOL checked) {
            [weakSelf doCheckAll:checked];
        };
        
        _signToolbar.didClickBlock = ^(SignToolbar *sender, ButtonType type) {
            if ( type == ButtonTypeAdd ) {
                [weakSelf addSignMan];
            } else if ( type == ButtonTypeDelete ) {
                [weakSelf removeSignMan];
            }
        };
    }
    
//    [self.contentView bringSubviewToFront:_signToolbar];
    
    return _signToolbar;
}

- (NSMutableArray *)needRemoveData
{
    if ( !_needRemoveData ) {
        _needRemoveData = [[NSMutableArray alloc] init];
    }
    return _needRemoveData;
}

- (AddContactsModel *)contactModel
{
    if ( !_contactModel ) {
        _contactModel = [[AddContactsModel alloc] initWithFieldName:@"contacts" selectedPeople:@[]];
    }
    return _contactModel;
}

@end

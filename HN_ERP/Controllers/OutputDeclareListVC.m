//
//  OutputDeclareListVC.m
//  HN_ERP
//
//  Created by tomwey on 25/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "OutputDeclareListVC.h"
#import "Defines.h"
#import "OutputDeclareCell.h"

@interface OutputDeclareListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *rooms;
@property (nonatomic, strong) NSMutableDictionary *roomNodes;

@end

@implementation OutputDeclareListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"待申报节点列表";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))];
    
    [self initCommitButtons];
    
//    __weak typeof(self) me = self;
//    [self addRightItemWithTitle:@"确认申报"
//                titleAttributes:@{
//                                  NSFontAttributeName: AWSystemFontWithSize(15, NO),
//                                  NSForegroundColorAttributeName: [UIColor whiteColor],
//                                  } size:CGSizeMake(78, 40)
//                    rightMargin:5
//                       callback:^{
//                           [me commit];
//                       }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kOutputDidConfirmNotification"
                                               object:nil];
    
    [self prepareData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [self.tableView removeErrorOrEmptyTips];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] ?: @"0" description];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"产值确认获取待申报列表APP",
                       @"param1": [self.params[@"item"][@"contractid"] description] ?: @"",
                       @"param2": @"2",
                       @"param3": manID,
                       } completion:^(id result, NSError *error) {
                           [me handleResult2:result error:error];
                       }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription reloadDelegate:nil];
        
        self.rooms = @[];
        
        self.roomNodes = [@{} mutableCopy];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
            
            self.rooms = @[];
            
            self.roomNodes = [@{} mutableCopy];
            
            [self.tableView reloadData];
        } else {
            [self fillData:result[@"data"]];
        }
    }
}

- (void)prepareData
{
//    appcomplete = 1;
//    confirmbase = 50;
//    contractid = 2220895;
//    contractpaynodeid = 5594217;
//    hasoutvalue = 0;
//    moneytypeid = 30;
//    moneytypename = "\U9a8c\U6536\U6b3e";
//    nodeamount = "154012.8"; //  应付金额
//    nodecompletestatusdesc = "\U5f85\U7533\U62a5";
//    nodecompletestatusnum = 2;
//    nodecurendvalue = 100;
//    nodename = "\U9a8c\U6536\U5b8c\U6bd5\U652f\U4ed8\U81f3\U5408\U540c\U91d1\U989d\U768480%\Uff08\U7269\U7ba1\U7528\U623f\Uff09";
//    outamount = 192516;      // 产值金额
//    outnodeid = NULL;
//    pricebase = 50;
//    roomids = 1166;
//    roomname = "9#";
    
    NSArray *data = self.params[@"data"];
    
    [self fillData:data];
}

- (void)fillData:(NSArray *)data
{
    NSMutableArray *rooms = [NSMutableArray array];
    
    self.roomNodes = [@{} mutableCopy];
    
    for (id item in data) {
        NSString *roomName = [item[@"roomname"] description];
        NSMutableArray *arr = self.roomNodes[roomName];
        if ( !arr ) {
            [rooms addObject:roomName];
            
            arr = [@[] mutableCopy];
            
            [arr addObject:item];
            
            self.roomNodes[roomName] = arr;
        } else {
            [arr addObject:item];
        }
    }
    
    self.rooms = rooms;
    
    [self.tableView reloadData];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)commit
//{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定要提交吗？"
//                                                                   message:@"\n提交成功后会生成一条ERP流程待办"
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    
//    
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
//                                              style: UIAlertActionStyleCancel
//                                            handler:^(UIAlertAction * _Nonnull action) {
//        
//    }]];
//    
//    __weak typeof(self) me = self;
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
//                                              style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * _Nonnull action) {
//                                                [me doCommit];
//                                            }]];
//    
//    [self presentViewController:alert animated:YES completion:nil];
//}

- (void)doCommit
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] ?: @"0" description];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认提交待申报列表APP",
              @"param1": [self.params[@"contractid"] ?: @"0" description],
              @"param2": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error: error];
              }];
}

- (void)initCommitButtons
{
    UIButton *saveBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                      50),
                                           @"保存到ERP待办",
                                           MAIN_THEME_COLOR,
                                           self,
                                           @selector(save2Todo));
    [self.contentView addSubview:saveBtn];
    
    //    self.save2TodoBtn = saveBtn;
    
    saveBtn.backgroundColor = [UIColor whiteColor];
    saveBtn.position = CGPointMake(0, self.contentView.height - 50);
    
    UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                        50),
                                             @"确认提交",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(commit));
    [self.contentView addSubview:commitBtn];
    
    //    self.commitBtn = commitBtn;
    
    commitBtn.backgroundColor = MAIN_THEME_COLOR;
    commitBtn.position = CGPointMake(saveBtn.right, self.contentView.height - 50);
    
    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:saveBtn.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:saveBtn];
    hairLine.position = CGPointMake(0,0);
    
    commitBtn.titleLabel.font = AWSystemFontWithSize(15, NO);
    saveBtn.titleLabel.font   = AWSystemFontWithSize(15, NO);
}

- (void)save2Todo
{
    NSMutableDictionary *dict = [self.params mutableCopy];
    [dict setObject:@"0" forKey:@"flow_type"];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputCommitVC"
                                                                params:dict];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)commit
{
    NSMutableDictionary *dict = [self.params mutableCopy];
    [dict setObject:@"1" forKey:@"flow_type"];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputCommitVC"
                                                                params:dict];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:@"服务器出错了！" succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"未知原因提交失败" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            
            if ( [item[@"hinttype"] integerValue] == 1 ) {
                [AWAppWindow() showHUDWithText:item[@"hint"] succeed:YES];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"kOutputDeclareDidCommitNotification"
                               object:nil];
                
                [self close];
            } else {
                [self.contentView showHUDWithText:item[@"hint"] succeed:NO];
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%@", self.rooms);
    return [self.rooms count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.rooms[section];
    return [self.roomNodes[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OutputDeclareCell *cell = (OutputDeclareCell *)[tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[OutputDeclareCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *key = self.rooms[indexPath.section];
    id item = self.roomNodes[key][indexPath.row];
    
    [cell configData:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.rooms[indexPath.section];
    id item = self.roomNodes[key][indexPath.row];
    
    NSString *vcName = [self fetchVCNameForItem:item];
    if ( !vcName ) {
        return;
    }
    
    NSMutableDictionary *dict = [self.params mutableCopy];
    [dict setObject:item forKey:@"floor"];
    [dict setObject:@{ @"building_id": item[@"roomids"] ?: @"0", @"building_name": item[@"roomname"] ?: @"" } forKey:@"building"];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:vcName
                                                                params:dict];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)fetchVCNameForItem:(id)item
{
    BOOL isNew = [self.params[@"isNew"] boolValue];
    if ( isNew ) {
        return @"OutputConfirmCommitVC";
    } else {
        
        NSInteger value = [item[@"confirmbase"] integerValue];
        
        if ( value == 10 ) {
            return @"OutputRoomConfirmVC";
        } else if ( value == 50 ) {
            return @"OutputValueConfirmVC";
        }
        
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.rooms[section];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.000001;
//}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.height -= 50;
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 95;
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
    }
    return _tableView;
}

@end

//
//  MeetingNotesListView.m
//  HN_ERP
//
//  Created by tomwey on 7/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingNotesListView.h"
#import "Defines.h"

@interface MeetingNotesListView ()

@property (nonatomic, strong) UIView *btnContainer;

@property (nonatomic, assign) NSInteger selectedButtonIndex;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) NSArray *meetingTypes;

@end

@implementation MeetingNotesListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.btnContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth(), 64)];
        [self addSubview:self.btnContainer];
        
        self.meetingTypes = @[@{
                               @"name": @"近一个月",
                               @"value": @"1",
                               },
                           @{
                               @"name": @"上周",
                               @"value": @"2",
                               },
                           @{
                               @"name": @"本周",
                               @"value": @"3",
                               },
                           @{
                               @"name": @"全部",
                               @"value": @"0",
                               },
                           ];
        
        CGFloat height = 34;
        CGFloat spacing = self.btnContainer.height / 2 - height / 2;
        
        CGFloat width = ( AWFullScreenWidth() - ( self.meetingTypes.count + 1 ) * spacing ) / self.meetingTypes.count;
        for (int i = 0; i<[self.meetingTypes count]; i++) {
            UIButton *btn = AWCreateTextButton(CGRectZero,
                                               self.meetingTypes[i][@"name"],
                                               AWColorFromRGB(58, 58, 58),
                                               self,
                                               @selector(btnClicked:));
            [self.btnContainer addSubview:btn];
            btn.titleLabel.font = AWSystemFontWithSize(14, NO);
            btn.userData = self.meetingTypes[i];
            
            btn.tag = 100 + i;
            
            btn.frame = CGRectMake(spacing + ( width + spacing ) * i,
                                   spacing, width, height);
            
            btn.backgroundColor = [UIColor whiteColor];
        }
        
        self.selectedButtonIndex = 0;
    }
    
    return self;
}

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex
{
    _selectedButtonIndex = selectedButtonIndex;
    
    for (UIButton *btn in self.btnContainer.subviews) {
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:AWColorFromRGB(58, 58, 58) forState:UIControlStateNormal];
//        btn.titleLabel.textColor = AWColorFromRGB(58, 58, 58);
        
        btn.userInteractionEnabled = YES;
    }
    
    UIButton *currentBtn = [self.btnContainer viewWithTag:100 + selectedButtonIndex];
    
    currentBtn.backgroundColor = MAIN_THEME_COLOR;
    [currentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    currentBtn.userInteractionEnabled = NO;
    
    [self loadData];
}

- (void)btnClicked:(UIButton *)sender
{
    self.selectedButtonIndex = sender.tag - 100;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(0, self.btnContainer.bottom,
                                      self.width,
                                      self.height - self.btnContainer.height);
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    [self.tableView removeErrorOrEmptyTips];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description] ?: @"0";
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"会议纪要列表APP",
              @"param1": manID,
              @"param2": self.meetingTypes[self.selectedButtonIndex][@"value"] ?: @"0",
              @"param3": @"0",
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult:result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self animated:YES];
        
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                     reloadDelegate:nil];
            
            self.dataSource.dataSource = nil;
        } else {
            self.dataSource.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        
        _tableView.rowHeight = 83;
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"MeetingNotesCell", @"meeting.notes.cell");
        
        __weak typeof(self) me = self;
        _dataSource.itemDidSelectBlock = ^(UIView<AWTableDataConfig> *sender, id selectedData) {
            if ( me.itemDidSelectBlock ) {
                me.itemDidSelectBlock(me, selectedData);
            }
        };
    }
    return _dataSource;
}

@end

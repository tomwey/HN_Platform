//
//  MessageVC.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MessageVC.h"
#import "Defines.h"

@interface MessageVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation MessageVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                        image:[UIImage imageNamed:@"tab_message.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_message_click.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"消息";
    
    [self addLeftItemWithView:nil];
    
    NSArray *data = @[@{ @"icon": @"msg_icon_todo.png",
                           @"name": @"待办",
                           @"body": @"今天您没有待审批和待办事项",
                           @"time": @"09:21",
                           @"count": @"3",
                           },
                        @{ @"icon": @"msg_icon_ann.png",
                           @"name": @"公告",
                           @"body": @"公告消息",
                           @"time": @"09:21",
                           @"count": @"0",
                           },
                        @{ @"icon": @"msg_icon_document.png",
                           @"name": @"文档",
                           @"body": @"文档通知",
                           @"time": @"09:21",
                           @"count": @"101",
                           },
                        ];
    
    self.dataSource = AWTableViewDataSourceCreate(data, @"MessageCell", @"msg.cell");
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self.dataSource;
    
    self.tableView.rowHeight = 80;
    
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
//    self.tableView.backgroundColor = [UIColor redColor];
    
    [self.tableView removeBlankCells];
    
}

@end

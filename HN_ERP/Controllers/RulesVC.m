//
//  RulesVC.m
//  HN_ERP
//
//  Created by tomwey on 4/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "RulesVC.h"
#import "Defines.h"

@interface RulesVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataSource;
@property (nonatomic, strong) NSMutableDictionary *searchConditions;

@end

@implementation RulesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"公司制度";
    
    self.searchConditions = [@{} mutableCopy];
    
    __weak typeof(self) me = self;
    [self addRightItemWithImage:@"btn_search.png" rightMargin:2 callback:^{
        [me doSearch];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearch:) name:@"kNeedSearchNotification" object:nil];
    
    [self startLoading];
}

- (void)handleSearch:(NSNotification *)noti
{
    self.searchConditions = noti.object;
    
    [self startLoading];
}

- (void)doSearch
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"RulesSearchVC" params:@{ @"title": @"搜索", @"search_conditions": self.searchConditions }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)startLoading
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    self.dataSource = @[@{
                            @"title": @"组织手册.docx",
                            @"time":  @"2017-04-05",
                            @"proj_name": @"组织手册",
                            @"size":  @"130",
                            },
                        @{
                            @"title": @"权责手册.xlsx",
                            @"time":  @"2017-04-05",
                            @"proj_name": @"权责手册",
                            @"size":  @"82",
                            },
                        @{
                            @"title": @"制度清单（2017-03-29）.xlsx",
                            @"time":  @"2017-04-01",
                            @"proj_name": @"制度文件清单",
                            @"size":  @"35",
                            },
                        @{
                            @"title": @"ZT-B02 土地信息收集管理制度.docx",
                            @"proj_name": @"制度-投资类",
                            @"time":  @"2017-04-01",
                            @"size":  @"230",
                            },
                        @{
                            @"title": @"ZT-B03 招拍挂投资管理办法.docx",
                            @"time":  @"2017-04-01",
                            @"proj_name": @"制度-投资类",
                            @"size":  @"62",
                            },
                        @{
                            @"title": @"CW-A03 资金管理制度.docx",
                            @"time":  @"2017-04-01",
                            @"proj_name": @"制度-财务类",
                            @"size":  @"125",
                            },
                        ];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        [self.tableView reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell.id"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id item = self.dataSource[indexPath.row];
    
    // 设置图标
    NSString *title = [item[@"title"] description];
    NSString *imageName = [NSString stringWithFormat:@"icon_%@.png",
                           [title pathExtension]];
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    // 设置标题
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@",item[@"title"]];
    //    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    //    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = AWSystemFontWithSize(15, NO);
    cell.textLabel.text = [title stringByDeletingPathExtension];
    
    // 设置描述
    NSString *size = [item[@"size"] integerValue] < 1000 ?
    [NSString stringWithFormat:@"%@KB", item[@"size"]] :
    [NSString stringWithFormat:@"%.1fMB", [item[@"size"] integerValue] / 1024.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"\n%@ %@ %@",
                                 item[@"proj_name"],size, item[@"time"]];
    
    cell.detailTextLabel.textColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR;
    cell.detailTextLabel.font = AWSystemFontWithSize(14, NO);
    cell.detailTextLabel.numberOfLines = 2;
    
    return cell;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.rowHeight = 90;
        
        [_tableView removeBlankCells];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
    }
    return _tableView;
}

@end

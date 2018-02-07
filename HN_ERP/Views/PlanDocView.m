//
//  PlanDocView.m
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanDocView.h"
#import "Defines.h"

@interface PlanDocView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataSource;

@end

@implementation PlanDocView

- (void)startLoading
{
    [HNProgressHUDHelper showHUDAddedTo:self animated:YES];
    
    self.dataSource = @[@{
                            @"title": @"合运营字【2017】005号关于集团2017年1月月度考核计划下达的通知.docx",
                            @"time":  @"2017-01-10",
                            @"proj_name": @"集团管理",
                            @"size":  @"30",
                            },
                        @{
                            @"title": @"成都永进合能资质升级专项计划ERP(调整版).xlsx",
                            @"time":  @"2017-01-20",
                            @"proj_name": @"集团管理",
                            @"size":  @"62",
                            },
                        @{
                            @"title": @"合运营字【2017】020号关于集团2017年2月月度考核计划下达的通知.docx",
                            @"time":  @"2017-02-17",
                            @"proj_name": @"集团管理",
                            @"size":  @"35",
                            },
                        @{
                            @"title": @"JT-ZXJH-2017-01公司资质专项计划V.xlsx",
                            @"proj_name": @"集团管理",
                            @"time":  @"2017-03-13",
                            @"size":  @"1011",
                            },
                        @{
                            @"title": @"合运营字【2017】024号关于集团2017年3月月度考核计划下达的通知V.docx",
                            @"time":  @"2017-03-13",
                            @"proj_name": @"集团管理",
                            @"size":  @"62",
                            },
                        @{
                            @"title": @"合运营字【2017】095号关于下达成都公司温江项目运营计划的决定.docx",
                            @"time":  @"2016-11-16",
                            @"proj_name": @"西悦",
                            @"size":  @"125",
                            },
                        ];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HNProgressHUDHelper hideHUDForView:self animated:YES];
        
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
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.rowHeight = 90;
        
        [_tableView removeBlankCells];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
    }
    return _tableView;
}

@end

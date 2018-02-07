//
//  PlanDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 3/2/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanDetailVC.h"
#import "Defines.h"

@interface PlanDetailVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, copy) NSString *mid;

@property (nonatomic, weak) UIButton *commitBtn;
@property (nonatomic, weak) UIButton *moreBtn;

@end

@implementation PlanDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"计划详情";
    
    self.mid = HNStringFromObject(self.params[@"icurdoflowid"], @"");
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    // 项目名称
    [self.dataSource addObject:@{ @"label": @"项目名称",
                                  @"value": HNStringFromObject(self.params[@"project_name"], nil),
                                  }];
    
    // 计划名称
    [self.dataSource addObject:@{ @"label": @"计划名称",
                                  @"value":
                                      HNStringFromObject(self.params[@"itemname"],@"无") }];
    
    // 计划层级
    [self.dataSource addObject:@{ @"label": @"计划层级", @"value": HNStringFromObject(self.params[@"plangrade"],@"无") }];
    
    // 责任部门
    [self.dataSource addObject:@{ @"label": @"责任部门", @"value": HNStringFromObject(self.params[@"liabledeptname"],@"无") }];
    
    // 第一责任人

    [self.dataSource addObject:@{ @"label": @"第一责任人", @"value": HNStringFromObject(self.params[@"liablemanname"],@"无") }];
    
    // 第二责任人
    [self.dataSource addObject:@{ @"label": @"第二责任人", @"value": HNStringFromObject(self.params[@"otherliablemannamelist"],@"无") }];

    // 经办人
    [self.dataSource addObject:@{ @"label": @"经办人", @"value": HNStringFromObject(self.params[@"domanname"],@"无") }];
    
    // 计划开始日期
    [self.dataSource addObject:@{ @"label": @"计划开始日期", @"value": HNDateFromObject(self.params[@"planbegindate"], @"T") }];
    
    // 计划结束日期
    [self.dataSource addObject:@{ @"label": @"计划结束日期", @"value": HNDateFromObject(self.params[@"planoverdate"], @"T") }];
    
    // 实际完成日期
    [self.dataSource addObject:@{ @"label": @"实际完成日期", @"value": HNDateFromObject(self.params[@"actualoverdate"], @"T") }];
    
    // 是否完成
    NSString *val = [self.params[@"isover"] boolValue] ? @"已完成" : @"未完成";
    if ( self.mid.length > 0 && [self.mid integerValue] != 0 ) {
        NSString *prefix = @"";
        NSInteger state = [self.params[@"icurdotypeid"] integerValue];
        if ( state == 2 ) {
            prefix = @"调整";
        } else if ( state == 1 ) {
            prefix = @"完成确认";
        }
        val = [NSString stringWithFormat:@"%@审批中",prefix];
    }
    
    [self.dataSource addObject:@{ @"label": @"计划状态", @"value": val }];
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    if ( [self.params[@"isover"] boolValue] == NO && [self.mid integerValue] == 0  ) {
        UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                            50),
                                                 @"完成确认",
                                                 [UIColor whiteColor],
                                                 self,
                                                 @selector(done));
        [self.contentView addSubview:commitBtn];
        commitBtn.backgroundColor = MAIN_THEME_COLOR;
        commitBtn.position = CGPointMake(0, self.contentView.height - 50);
        
//        self.doneBtn = commitBtn;
        self.commitBtn = commitBtn;
        
        UIButton *moreBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                          50),
                                               @"调整",
                                               IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
                                               self,
                                               @selector(adjust));
        [self.contentView addSubview:moreBtn];
        moreBtn.backgroundColor = [UIColor whiteColor];
        moreBtn.position = CGPointMake(commitBtn.right, self.contentView.height - 50);
        
        self.moreBtn = moreBtn;
//        self.resetBtn = moreBtn;
        
        UIView *hairLine = [AWHairlineView horizontalLineWithWidth:moreBtn.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:moreBtn];
        hairLine.position = CGPointMake(0,0);
        
        moreBtn.left = 0;
        commitBtn.left = moreBtn.right;
        
        self.tableView.height -= moreBtn.height;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flowDidCommit:)
                                                 name:@"kPlanFlowDidCommitNotification"
                                               object:nil];
}

- (void)flowDidCommit:(NSNotification *)noti
{
    self.mid = [noti.object[@"mid"] description];
    NSString *from = [noti.object[@"from"] description];
    
    if (self.mid.length > 0 && [self.mid integerValue] != 0) {
        self.moreBtn.hidden = self.commitBtn.hidden = YES;
        self.tableView.height = self.contentView.height;
        
        [self.dataSource removeLastObject];
        
        NSString *val = [from isEqualToString:@"adjust"] ? @"调整审批中" : @"完成确认审批中";
        [self.dataSource addObject:@{ @"label": @"计划状态", @"value": val }];
        
        [self.tableView reloadData];
//        NSMutableArray *temp = [self.dataSource mutableCopy]
    }
}

- (void)done
{
    if ( [self.mid integerValue] != 0 ) {
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OADetailVC" params:@{ @"item": @{ @"mid": self.mid }, @"has_action": @(NO),
                                                                                                   @"state": @"done"}];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc =
            [[AWMediator sharedInstance] openNavVCWithName:@"PlanConfirmVC" params:self.params];
        //[[AWMediator sharedInstance] openVCWithName:@"PlanConfirmVC" params:self.params];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)adjust
{
    if ( [self.mid integerValue] != 0 ) {
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OADetailVC" params:@{ @"item": @{ @"mid": self.mid }, @"has_action": @(NO),
                                                                                                   @"state": @"done"}];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"PlanAdjustVC" params:self.params];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id data = self.dataSource[indexPath.row];
    
    if ( [data[@"label"] isEqualToString:@"计划名称"] ) {
        cell.textLabel.font = AWSystemFontWithSize(14, NO);
        cell.textLabel.textColor = AWColorFromRGB(133, 133, 133);
        
        cell.textLabel.numberOfLines = 0;
        
        NSString *tempStr = [NSString stringWithFormat:@"%@\n\n%@", data[@"label"], data[@"value"]];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:tempStr];
        
        [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(16, NO),
                                 NSForegroundColorAttributeName: [UIColor blackColor]}
                        range:NSMakeRange(0, 4)];
        
        cell.textLabel.attributedText = string;
        
        cell.detailTextLabel.text = nil;
    } else {
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.font = AWSystemFontWithSize(16, NO);
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.textLabel.text = data[@"label"];
        
        cell.detailTextLabel.font = AWSystemFontWithSize(14, NO);
        cell.detailTextLabel.textColor = AWColorFromRGB(133, 133, 133);
        
        cell.detailTextLabel.text = data[@"value"];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if ( [data[@"label"] isEqualToString:@"计划状态"] ) {
        cell.detailTextLabel.textColor = MAIN_THEME_COLOR;
    }
    
    if (indexPath.row == self.dataSource.count - 1 &&
        self.mid.length != 0 && [self.mid integerValue] != 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
//    cell.detailTextLabel.font = AWSystemFontWithSize(16, NO);
//    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.dataSource[indexPath.row];
    
    if ( [data[@"label"] isEqualToString:@"计划名称"] ) {
        NSString *string = [data[@"value"] description];
        CGFloat height = [string boundingRectWithSize:
            CGSizeMake(self.contentView.width - 30,
                                                1000)
                             options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{ NSFontAttributeName: AWSystemFontWithSize(14, NO) } context:NULL].size.height;
        return height + 62;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.dataSource.count - 1 == indexPath.row &&
        self.mid.length != 0 && [self.mid integerValue] != 0) {
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OADetailVC" params:@{ @"item": @{ @"mid": self.mid }, @"has_action": @(NO),
                                                                                                   @"state": @"todo"}];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        [_tableView removeBlankCells];
        _tableView.delegate = self;
    }
    
    return _tableView;
}

@end

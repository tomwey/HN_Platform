//
//  WorkVC.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "WorkVC.h"
#import "Defines.h"

@interface WorkVC () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) HNBadge *badge;
@property (nonatomic, strong) NSMutableArray *modules;

@property (nonatomic, strong) NSMutableArray *tempModules;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSArray *badges;

@end

@implementation WorkVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
//        self.modules = [[NSMutableArray alloc] init];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                        image:[UIImage imageNamed:@"tab_work.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_work_click.png"]];
    }
    return self;
}

- (void)dealloc
{
    [[HNBadgeService sharedInstance] unregisterAllObservers];
    
//    [[HNNewFlowCountService sharedInstance] unregisterObserver:self.badge];
}

- (void)initBadges
{
    HNBadge *b1 = [[HNBadge alloc] initWithBadge:0 inView:nil];
    HNBadge *b2 = [[HNBadge alloc] initWithBadge:0 inView:nil];
    
    [[HNBadgeService sharedInstance] registerObserver:b1 forKey:@"flows"];
    [[HNBadgeService sharedInstance] registerObserver:b2 forKey:@"plans"];
    
    self.badges = @[b1,b2];
    
    [[HNBadgeService sharedInstance] startMonitor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navBar.title = @"合能地产";
    [self initBadges];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.contentView.backgroundColor = AWColorFromRGB(239, 239, 239);
    
    UIImageView *header = AWCreateImageView(nil);
    header.image = AWImageNoCached(@"work-header.jpg");
    header.frame = CGRectMake(0, 0, self.contentView.width,
                              self.contentView.width * header.image.size.height /
                              header.image.size.width);
    header.userInteractionEnabled = YES;
    [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(gotoGuide)]];
    //    header.contentMode = UIViewContentModeScaleAspectFill
    [self.contentView addSubview:header];
    
    self.dataSource = @[
                        @[@{
                            @"icon": @"tab_flow_1.png",
                            @"name": @"流程待办",
                            @"page": @"OAListVC",
                            },
                        @{
                            @"icon": @"tab_plan.png",
                            @"name": @"计划",
                            @"page": @"PlanVC",
                            },
                        @{
                            @"icon": @"work_icon_bi.png",
                            @"name": @"经营分析",
                            @"page": @"BIVC",
                            }],
                        @[
                            @{
                                @"icon": @"work_icon_setting.png",
                                @"name": @"个人中心",
                                @"page": @"SettingVC",
                                },
                            @{
                                @"icon": @"icon_feedback.png",
                                @"name": @"意见反馈",
                                @"page": @"FeedbackVC",
                                },
                            ]
                        ];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, header.bottom,
                                                                   self.contentView.width,
                                                                   self.contentView.height - header.height)
                                                  style:UITableViewStyleGrouped];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    [self.tableView removeBlankCells];
    
    self.tableView.rowHeight = 58;
    
//    self.tableView.scrollEnabled = NO;
    
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, header.height,
//                                                                     self.contentView.width, self.contentView.height - 49 - header.height)];
//    [self.contentView addSubview:self.scrollView];
////    self.scrollView.backgroundColor = [UIColor redColor];
//
//
////    self.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
//
//    self.scrollView.backgroundColor = [UIColor clearColor];
//    self.scrollView.showsVerticalScrollIndicator = NO;
//
//    NSArray *sections = @[@{
//                              @"label": @"变更申报",
//                              @"icon": @"work_icon_biangeng.png",
//                              @"action": @"gotoDeclare",
//                              @"has_badge": @(YES),
//                              @"badge_name": @"declares",
//                              },
//                          @{
//                              @"label": @"合同执行",
//                              @"icon": @"work_icon_hetong.png",
//                              @"action": @"gotoContract",
//                              @"has_badge": @(YES),
//                              @"badge_name": @"contracts",
//                              },
////                          @{
////                              @"label": @"支付查询",
////                              @"icon": @"work_icon_pay.png",
////                              @"action": @"gotoPayments",
////                              @"has_badge": @(YES),
////                              @"badge_name": @"payments",
////                              },
//                          @{
//                              @"label": @"投诉建议",
//                              @"icon": @"work_icon_plan.png",
//                              @"action": @"gotoReport",
//                              @"has_badge": @(NO),
//                              @"badge_name": @"",
//                              },
//                          ];
//
//    self.modules = [sections mutableCopy];
//
//    self.tempModules = [NSMutableArray array];
//
//    [self initModules];
    
//    self.scrollView.hidden = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadManPower)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
//
//    [self loadManPower];
    
    // 获取新的待办流程
//    [self fetchNewFlowCounts];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id item = self.dataSource[indexPath.section][indexPath.row];
    
    cell.imageView.image = [[UIImage imageNamed:item[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = AWColorFromHex(@"#999999");
    
    cell.textLabel.text  = item[@"name"];
    cell.textLabel.font  = AWSystemFontWithSize(16, NO);
    
    cell.textLabel.textColor = AWColorFromHex(@"#333333");
    
    if ( indexPath.section == 0 && indexPath.row != 2 ) {
        HNBadge *badge = self.badges[indexPath.row];
        
        badge.badgeContainer = cell.contentView;
        
        badge.badge = 100;
        
        badge.position = CGPointMake(self.contentView.width - 30 - badge.badgeSize.width,
                                     self.tableView.rowHeight / 2.0 - 9);
        
        badge.badge = 0;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *vcName = self.dataSource[indexPath.section][indexPath.row][@"page"];
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:vcName params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return 0.000001;
    }
    
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if ( section == 0 ) {
//        return 0.000001;
//    }
    
    return 0.000001;
}

- (void)gotoDeclare
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DeclareListVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoContract
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"ContractListVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoPayments
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PaymentsVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoReport
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"ReportVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)initModules
{
    for (UIView *view in self.tempModules) {
        [view removeFromSuperview];
    }
    
    NSUInteger numberOfCell = 3;
    CGFloat dtw = ceilf(( self.contentView.width ) / numberOfCell);
    
    CGFloat maxY = 0;
    for (int i=0; i<self.modules.count; i++) {
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dtw, dtw)];
        //        container.backgroundColor = [UIColor redColor];
        [self.scrollView addSubview:container];
        
        [self.tempModules addObject:container];
        
        int m = i % numberOfCell;
        int n = i / numberOfCell;
        
        CGFloat dtx = (dtw) * m;
        CGFloat dty = /*header.bottom + */(dtw) * n;
        container.position = CGPointMake(dtx, dty);
        
        id item = self.modules[i];
        
        UIImageView *iconView = AWCreateImageView(nil);
        iconView.frame = CGRectMake(0, 0, 50, 50);
        iconView.contentMode = UIViewContentModeCenter;
        //        iconView.backgroundColor = MAIN_THEME_COLOR;
        
        [container addSubview:iconView];
        iconView.center = CGPointMake(container.width / 2,
                                      container.height / 2 - 10);
        //        iconView.cornerRadius = iconView.height / 2;
        
        UILabel *label = AWCreateLabel(CGRectMake(0, 0, container.width, 30),
                                       item[@"label"],
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(137, 137, 137));
        [container addSubview:label];
        label.center = CGPointMake(container.width / 2, iconView.bottom + label.height / 2);
        if ( [item[@"label"] isEqualToString:@"会议"] ) {
            label.textColor = AWColorFromRGB(33, 144, 228);
        } else {
            label.textColor = MAIN_THEME_COLOR;
        }
        
        if ( [item[@"icon"] hasSuffix:@".png"] ) {
            iconView.image = [[UIImage imageNamed:item[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iconView.tintColor = MAIN_THEME_COLOR;
        } else {
            
            NSArray *colors = @[MAIN_THEME_COLOR,AWColorFromRGB(33, 144, 228)];
            iconView.backgroundColor = [UIColor whiteColor];
            
            UIColor *color = colors[i % colors.count];
            
            iconView.layer.borderColor = color.CGColor;
            iconView.layer.borderWidth = 0.8;
            
            FAKIonIcons *icon = [FAKIonIcons iconWithIdentifier:[item[@"icon"] description]
                                                           size:30
                                                          error:nil];
            [icon addAttributes:@{ NSForegroundColorAttributeName: color }];
            UIImage *image = [icon imageWithSize:CGSizeMake(50, 50)];
            
            iconView.image = image;
            
            if ( ![item[@"label"] isEqualToString:@"会议"] ) {
                label.textColor = color;
            }
        }
        
        label.textColor = AWColorFromRGB(133, 133, 133);
        
        maxY = container.bottom;
        
        SEL selector = NSSelectorFromString(item[@"action"]);
        if ( [self respondsToSelector:selector] ) {
            UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
            [container addGestureRecognizer:tap];
        }
        
        BOOL hasBadge = [item[@"has_badge"] boolValue];
        if ( hasBadge ) {
            HNBadge *badge = [[HNBadge alloc] initWithBadge:0 inView:container];
            badge.position = CGPointMake(iconView.right - 18,
                                         iconView.top + 5);
            [[HNBadgeService sharedInstance] registerObserver:badge forKey:item[@"badge_name"] ?: @"hn_erp"];
        }
        //        if ( i == 0 ) {
        //            CGPoint point =
        //                [self.scrollView convertPoint:CGPointMake(iconView.right - 18,
        //                                                          iconView.top + 5)
        //                                     fromView:container];
        //            self.badge.position = point;
        //        }
    }
    
    //    self.badge.badge = 6;
    
    //    UIView *splitSection = [[UIView alloc] initWithFrame:CGRectMake(0, maxY + 25, self.contentView.width, 20)];
    //    splitSection.backgroundColor = AWColorFromRGB(242, 241, 241);
    //    [self.scrollView addSubview:splitSection];
    //
    //    maxY = splitSection.bottom;
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width,
                                             maxY);
    
    [[HNBadgeService sharedInstance] startMonitor];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loadManPower];
}

- (void)loadManPower
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"移动端权限控制APP",
              @"param1": manID,
              }
     completion:^(id result, NSError *error) {
         [me handleResult:result error: error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"加载失败，请重试"
                                   message:@""
                                  delegate:self
                         cancelButtonTitle:@"重试"
                          otherButtonTitles:nil] show];
    } else {
        if ([result[@"rowcount"] integerValue] == 0) {
            [self.contentView showHUDWithText:@"没有找到数据" offset:CGPointMake(0,20)];
        } else {
            NSMutableArray *temp = [NSMutableArray array];
            NSArray *data = result[@"data"];
            
            [[AppManager sharedInstance] removeAllAbilities];
            
            for (id dict in data) {
                [[AppManager sharedInstance] addAbility:dict forKey:dict[@"funcname"]];
            }
            
            for (id obj in self.modules) {
                for (id dict in data) {
                    if ([dict[@"funcname"] isEqualToString:obj[@"label"]] &&
                        [dict[@"pi_id"] integerValue] == 1) {
                        [temp addObject:obj];
                        break;
                    }
                }
            }
            
            self.modules = temp;
            
            [self initModules];
        }
    }
    
    
//    self.scrollView.hidden = NO;
}

//- (void)fetchNewFlowCounts
//{
//    [[HNNewFlowCountService sharedInstance] registerObserver:self.badge];
//    [[HNNewFlowCountService sharedInstance] resetNewFlowCount];
//    [[HNNewFlowCountService sharedInstance] startFetching:nil];
//}

- (void)gotoGuide
{
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [app showGuide:YES];
}

- (void)gotoTodo
{
    
}

- (void)gotoChanzhi
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputCatalogVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoRules
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"KnowledgeTypeVC" params:@{ @"title": @"知识库", @"mid": @"0" }];
    
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoSetting
{
    
}

- (void)gotoNews
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewsListVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoFeedback
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"FeedbackVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (void)gotoMapBI
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"CityMapBIVC" params:nil];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)gotoFlow
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBar = (UITabBarController *)app.appRootController;
    tabBar.selectedIndex = 1;
}

- (void)gotoMeeting
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MeetingVC" params:nil];
    [[AWAppWindow() navController] pushViewController:vc animated:YES];
}

- (void)gotoDocument
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DocumentVC" params:nil];
    [[AWAppWindow() navController] pushViewController:vc animated:YES];
}

- (void)gotoPlan
{
//    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PlanVC" params:nil];
//    [[AWAppWindow() navController] pushViewController:vc animated:YES];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBar = (UITabBarController *)app.appRootController;
    tabBar.selectedIndex = 2;
}

- (void)gotoBI
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"BIHomeVC" params:nil];
    [[AWAppWindow() navController] pushViewController:vc animated:YES];
}

- (void)gotoLand
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"LandListVC" params:nil];
    [[AWAppWindow() navController] pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//- (HNBadge *)badge
//{
//    if ( !_badge ) {
//        _badge = [[HNBadge alloc] initWithBadge:0 inView:self.scrollView];
//    }
//    return _badge;
//}

@end

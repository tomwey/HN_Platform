//
//  LandDetailVC.m
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "LandDetailVC.h"
#import "Defines.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

@interface LandDetailVC () <UITableViewDataSource, UITableViewDelegate, SwipeViewDataSource, SwipeViewDelegate, JTSImageViewControllerOptionsDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) UILabel *pagerLabel;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSMutableArray *specialKeys;

@end

@implementation LandDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"土地详情";
    
    self.specialKeys = [@[] mutableCopy];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStyleGrouped];
    
    [self.contentView addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    [self prepareDataSource];
    
    // 添加顶部滚动图片
    [self addImagesScroller];
    
}

- (NSString *)decoValForValue:(id)val suffix:(NSString *)suffix
{
    if ( !val || [[val description] length] == 0 ||
        [[val description] isEqualToString:@"NULL"]) {
        return @"无";
    }
    
    if ( [[val description] rangeOfString:@"."].location != NSNotFound ) {
        val = [NSString stringWithFormat:@"%.2f", [[val description] floatValue]];
    }
    
    return [NSString stringWithFormat:@"%@%@", val, suffix];
}

- (void)prepareDataSource
{
    NSMutableDictionary *data1 = [@{} mutableCopy];
    
    data1[@"key"] = @"土地基本信息";
    
    NSMutableArray *arr1 = [NSMutableArray array];
    
    data1[@"data"] = arr1;
    
    [arr1 addObject:@{
                      @"label": @"地块编号",
                      @"value": [NSString stringWithFormat:@"%@",self.params[@"item"][@"landno"]]
                      }];
    [arr1 addObject:@{
                      @"label": @"所属公司",
                      @"value": [NSString stringWithFormat:@"%@",self.params[@"item"][@"corpname"]]
                      }];
    
    [arr1 addObject:@{
                      @"label": @"用地性质",
                      @"value": [NSString stringWithFormat:@"%@",self.params[@"item"][@"usenature"]]
                      }];
    [arr1 addObject:@{
                      @"label": @"用地面积",
                      @"value": [NSString stringWithFormat:@"%.2f亩 %.2f平米",
                                 [self.params[@"item"][@"usearea_mu"] floatValue],
                                 [self.params[@"item"][@"usearea_meter"] floatValue]]
                      }];
    [arr1 addObject:@{
                      @"label": @"容积率",
                      @"value": [NSString stringWithFormat:@"%@",self.params[@"item"][@"plan_plotrate"]]
                      }];
    [arr1 addObject:@{
                      @"label": @"总建面",
                      @"value": [self decoValForValue:self.params[@"item"][@"plan_totalbuildarea"]
                                               suffix:@" 万平米"]//[NSString stringWithFormat:@"%@ 万平米", self.params[@"item"][@"plan_totalbuildarea"]]
                      }];
    
    [arr1 addObject:@{
                      @"label": @"建筑密度",
                      @"value": [self decoValForValue:self.params[@"item"][@"plan_builddensity"]
                                               suffix:@"%"]//[NSString stringWithFormat:@"%@%%", self.params[@"item"][@"plan_builddensity"]]
                      }];
    [arr1 addObject:@{
                      @"label": @"建筑高度",
                      @"value": [self decoValForValue:self.params[@"item"][@"plan_buildheight"]
                                               suffix:@"米"]//[NSString stringWithFormat:@"%@米", self.params[@"item"][@"plan_buildheight"]]
                      }];
    [arr1 addObject:@{
                      @"label": @"出让方式",
                      @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"selltype"]]
                      }];
    
    // 土地立项信息
    NSMutableDictionary *data_2 = [@{} mutableCopy];
    
    data_2[@"key"] = @"土地立项信息";
    
    NSMutableArray *arr_2 = [NSMutableArray array];
    
    data_2[@"data"] = arr_2;
    
    [arr_2 addObject:@{
                      @"label": @"立项时间",
                      @"value": HNDateFromObject(self.params[@"item"][@"projectapprovaldate"], @"T")
                      }];
    [arr_2 addObject:@{
                      @"label": @"立项状态",
                      @"value": HNStringFromObject(self.params[@"item"][@"sprojectapproval"], @"无")
                      }];
    
    // 土地交易信息
    NSMutableDictionary *data2 = [@{} mutableCopy];
    
    data2[@"key"] = @"土地交易信息";
    
    NSMutableArray *arr2 = [NSMutableArray array];
    
    data2[@"data"] = arr2;
    
    if ( [self.params[@"item"][@"gettype"] isEqualToString:@"协议"] ) {
//        [arr2 addObject:@{
//                          @"label": @"地块现状",
//                          @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"landpresentsituation"]]
//                          }];
        
        NSMutableDictionary *data3 = [@{} mutableCopy];
        
        data3[@"key"] = @"地块现状";
        data3[@"data"] = @[@{
                               @"label": @"地块现状",
                               @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"landpresentsituation"]]
                               }];
        
        NSMutableDictionary *data4 = [@{} mutableCopy];
        
        data4[@"key"] = @"地块背景说明";
        data4[@"data"] = @[@{
                               @"label": @"地块背景说明",
                               @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"landbackgroundinfo"]]
                               }];
        
        [arr2 addObject:@{
                          @"label": @"项目报价",
                          @"value": [self decoValForValue:self.params[@"item"][@"proprice_totallandprice"]
                                                   suffix:@" 万"]//[NSString stringWithFormat:@"%@ 万", self.params[@"item"][@"proprice_totallandprice"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"有票成本",
                          @"value": [self decoValForValue:self.params[@"item"][@"proprice_billcost"]
                                                   suffix:@" 万"]//[NSString stringWithFormat:@"%@ 万", self.params[@"item"][@"proprice_billcost"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"楼面价",
                          @"value": [self decoValForValue:self.params[@"item"][@"proprice_roomfaceprice"]
                                                   suffix:@" 元/平米"]//[NSString stringWithFormat:@"%@ 元/平米", self.params[@"item"][@"proprice_roomfaceprice"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"地块来源",
                          @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"landcomefrom"]]
                          }];
//        [arr2 addObject:@{
//                          @"label": @"地块背景说明",
//                          @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"landbackgroundinfo"]]
//                          }];
        self.dataSource = @[data1, data_2, data2, data3, data4];
    } else {
        
        // 招拍挂
        
        NSMutableDictionary *data3 = [@{} mutableCopy];
        
        data3[@"key"] = @"特殊要求";
        data3[@"data"] = @[@{
                               @"label": @"特殊要求",
                               @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"specialrequirements"]]
                               }];
        
        [arr2 addObject:@{
                          @"label": @"起拍总地价",
                          @"value": [self decoValForValue:self.params[@"item"][@"startprice_totalland"]
                                                   suffix:@" 万"]//[NSString stringWithFormat:@"%@ 万", self.params[@"item"][@"startprice_totalland"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"起拍楼面价",
                          @"value": [self decoValForValue:self.params[@"item"][@"startprice_roomface"]
                                                   suffix:@" 元/平米"]//[NSString stringWithFormat:@"%@ 元/平米", self.params[@"item"][@"startprice_roomface"]]
                          }];
        
        [arr2 addObject:@{
                          @"label": @"预估成交总价",
                          @"value": [self decoValForValue:self.params[@"item"][@"estimatedprice_totalland"]
                                                   suffix:@" 万"]//[NSString stringWithFormat:@"%@ 万", self.params[@"item"][@"startprice_totalland"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"预估楼面价",
                          @"value": [self decoValForValue:self.params[@"item"][@"estimatedprice_roomface"]
                                                   suffix:@" 元/平米"]//[NSString stringWithFormat:@"%@ 元/平米", self.params[@"item"][@"startprice_roomface"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"保证金",
                          @"value": [self decoValForValue:self.params[@"item"][@"securitydeposit"]
                                                   suffix:@" 万"]//[NSString stringWithFormat:@"%@ 万", self.params[@"item"][@"securitydeposit"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"报名及保证金截止时间",
                          @"value": [NSString stringWithFormat:@"%@", [[self.params[@"item"][@"signupclosingtime"] componentsSeparatedByString:@"T"] firstObject]]
                          }];
        [arr2 addObject:@{
                          @"label": @"保证金退回时间",
                          @"value": [NSString stringWithFormat:@"%@", [[self.params[@"item"][@"securitybackdate"] componentsSeparatedByString:@"T"] firstObject]]
                          }];
        [arr2 addObject:@{
                          @"label": @"保证金特殊要求",
                          @"value": HNStringFromObject(self.params[@"item"][@"securityothermemo"], @"无")
                          }];
        [arr2 addObject:@{
                          @"label": @"经验退回时间",
                          @"value": HNDateFromObject(self.params[@"item"][@"securityrealbackdate"], @"T")
                          }];
        [arr2 addObject:@{
                          @"label": @"成交总地价",
                          @"value": [self decoValForValue:self.params[@"item"][@"deal_totallandprice"]
                                                   suffix:@" 万"]//[NSString stringWithFormat:@"%@ 万", self.params[@"item"][@"deal_totallandprice"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"成交楼面价",
                          @"value": [self decoValForValue:self.params[@"item"][@"deal_roomfaceprice"]
                                                   suffix:@" 元/平米"]//[NSString stringWithFormat:@"%@ 元/平米", self.params[@"item"][@"deal_roomfaceprice"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"成交溢价率",
                          @"value": [self decoValForValue:self.params[@"item"][@"deal_pricerate"] suffix:@""]//[NSString stringWithFormat:@"%@", self.params[@"item"][@"deal_pricerate"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"成交竞得人",
                          @"value": [NSString stringWithFormat:@"%@", self.params[@"item"][@"deal_buyman"]]
                          }];
        [arr2 addObject:@{
                          @"label": @"公告时间",
                          @"value": [NSString stringWithFormat:@"%@", [[self.params[@"item"][@"announcetime"] componentsSeparatedByString:@"T"] firstObject]]
                          }];
        [arr2 addObject:@{
                          @"label": @"出让时间",
                          @"value": [NSString stringWithFormat:@"%@", [[self.params[@"item"][@"selltime"] componentsSeparatedByString:@"T"] firstObject]]
                          }];
        
        // 拍卖规则
        NSMutableDictionary *data_3 = [@{} mutableCopy];
        data_3[@"key"] = @"拍卖规则";
        
        NSMutableArray *arr_3 = [@[] mutableCopy];
        data_3[@"data"] = arr_3;
        
        [arr_3 addObject:@{
                          @"label": @"熔断价",
                          @"value": [self decoValForValue:self.params[@"item"][@"rule_fusingprice"]
                                                   suffix:@" 元/平米"]
                          }];
        [arr_3 addObject:@{
                           @"label": @"指导价",
                           @"value": [self decoValForValue:self.params[@"item"][@"rule_guidprice"]
                                                    suffix:@" 元/平米"]
                           }];
        [arr_3 addObject:@{
                           @"label": @"拍卖方式",
                           @"value": HNStringFromObject(self.params[@"item"][@"rule_selltype"], @"无")
                           }];
        [arr_3 addObject:@{
                           @"label": @"拍卖规则描述",
                           @"value": HNStringFromObject(self.params[@"item"][@"rule_memodesc"], @"无")
                           }];
        [arr_3 addObject:@{
                           @"label": @"预售条件说明",
                           @"value": HNStringFromObject(self.params[@"item"][@"rule_sellmemo"], @"无")
                           }];
        
        [arr_3 addObject:@{
                           @"label": @"拍卖文件计划上传时间",
                           @"value": HNDateFromObject(self.params[@"item"][@"sellfileputtime"], @"T")
                           }];
        [arr_3 addObject:@{
                           @"label": @"拍卖文件是否上传",
                           @"value": [self.params[@"item"][@"sellfilehaveput"] boolValue] ? @"已上传" : @"未上传"
                           }];
        
        self.dataSource = @[data1, data_2, data2, data_3, data3];
    }
    
//    if ( [self.params[@"item"][@"url"] length] > 0 ) {
        NSMutableArray *temp = [self.dataSource mutableCopy];
        
        NSMutableDictionary *data = [@{} mutableCopy];
        
        data[@"key"] = @"attachment";
        data[@"data"] = @[@{
                              @"label": @"相关附件",
                              @"value": @"",
                              }];
    
    [self.specialKeys addObject:@"attachment"];
        
//        data[@"key"] = @"相关附件";
//        
//        NSMutableArray *arr = [NSMutableArray array];
//        
//        data[@"data"] = arr;
//        
//        NSArray *urls = [self.params[@"item"][@"url"] componentsSeparatedByString:@","];
//        for (NSString *url in urls) {
//            NSDictionary *params = [[[url componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
//            
//            [arr addObject:@{
//                             @"label": params[@"filename"] ?: @"",
//                             @"value": params[@"file"] ?: @"",
//                             @"isdoc": params[@"isdoc"] ?: @"",
//                             @"docid": params[@"fileid"] ?: @"0",
//                             }];
//        }
//        
        [temp addObject:data];
        
        self.dataSource = temp;
//    }
    
    // 工作计划以及付款方式
    if (![self.params[@"item"][@"gettype"] isEqualToString:@"协议"]) {
        NSMutableArray *temp = [self.dataSource mutableCopy];
        
        // 工作计划
        NSMutableDictionary *data = [@{} mutableCopy];
        
        data[@"key"] = @"workplan";
        data[@"data"] = @[@{
                              @"label": @"工作计划",
                              @"value": @"",
                              }];
        
        [temp addObject:data];
        
        [self.specialKeys addObject:@"workplan"];
        
        // 付款方式
        data = [@{} mutableCopy];
        data[@"key"] = @"pay";
        data[@"data"] = @[@{
                              @"label": @"付款方式",
                              @"value": @"",
                              }];
        
        [temp addObject:data];
        
        [self.specialKeys addObject:@"pay"];
        
        self.dataSource = temp;
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id item = self.dataSource[section];
    
    return [item[@"data"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell.id"];
    }
    
    id data = self.dataSource[indexPath.section];
    id item = [data[@"data"] objectAtIndex:indexPath.row];
    
    if ( [self.specialKeys indexOfObject:[data[@"key"] description]] != NSNotFound ) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
    
    if ( [self.specialKeys indexOfObject:[data[@"key"] description]] != NSNotFound ) {
        cell.textLabel.text = item[@"label"];
        cell.textLabel.numberOfLines = 1;
        cell.detailTextLabel.text = nil;
    } else if ( [data[@"key"] isEqualToString:item[@"label"]] ) {
        cell.textLabel.text = HNStringFromObject(item[@"value"], @"无");//item[@"value"];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = nil;
    } else {
        cell.textLabel.text = item[@"label"];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = HNStringFromObject(item[@"value"], @"无");
        
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.minimumScaleFactor = 0.5;
    }
    
    cell.detailTextLabel.textColor = AWColorFromRGB(188,188,188);
    
    if ([data[@"key"] isEqualToString:@"土地立项信息"] &&
        [item[@"label"] isEqualToString:@"立项状态"] && [item[@"value"] isEqualToString: @"立项"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.detailTextLabel.textColor = MAIN_THEME_COLOR;
    } else {
        
//        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.dataSource[indexPath.section];
    id item = [data[@"data"] objectAtIndex:indexPath.row];
    
    if ( [data[@"key"] isEqualToString:item[@"label"]] ) {
        NSString *itemValue = item[@"value"];
//        NSLog(@"%@", itemValue);
        CGSize size = [itemValue boundingRectWithSize:CGSizeMake(self.contentView.width - 30, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : AWSystemFontWithSize(17, NO) } context:nil].size;
        if ( size.height > 44 ) {
            return size.height + 40;
        } else {
            if ( [itemValue rangeOfString:@"\n"].location != NSNotFound ) {
                return 44 + 30;
            } else if ( size.width < self.contentView.width - 30 ) {
                return 44;
            } else {
                return 44 + 20;
            }
        }
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    id data = self.dataSource[section];
    
    if ([self.specialKeys indexOfObject:[data[@"key"] description]] != NSNotFound) {
        return 10;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.font = AWSystemFontWithSize(17, NO);
    headerView.textLabel.textColor = AWColorFromRGB(121, 121, 121);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id data = self.dataSource[section];
    
    if ([self.specialKeys indexOfObject:[data[@"key"] description]] != NSNotFound) {
        return nil;
    }
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"cell.header"];
    if ( !view ) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"cell.header"];
        view.contentView.backgroundColor = AWColorFromRGB(245, 245, 245);
    }
    
    id item = self.dataSource[section];
    
    view.textLabel.text = item[@"key"];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id data = self.dataSource[indexPath.section];
    id item = [data[@"data"] objectAtIndex:indexPath.row];
    
    if ([item[@"label"] isEqualToString:@"立项状态"] && [item[@"value"] isEqualToString: @"立项"]) {
        // 查看立项流程
        NSString *mid = HNStringFromObject(self.params[@"item"][@"projectapprovalflowmid"], @"0");
        
        if (![mid isEqualToString:@"0"]) {
            UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OADetailVC" params:@{ @"item": @{ @"mid": mid }, @"has_action": @(NO),
                                                                                                       @"state": @"todo"}];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        if ( [self.specialKeys indexOfObject:[data[@"key"] description]] != NSNotFound ) {
            // 跳到下一页查看
            if ( [item[@"label"] isEqualToString:@"相关附件"] ) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"LandAnnexListVC" params:@{ @"land_id": self.params[@"item"][@"id"] ?: @"0" }];
                [self.navigationController pushViewController:vc animated:YES];
            } else if ( [item[@"label"] isEqualToString:@"付款方式"] ) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"LandPayListVC" params:@{ @"land_id": self.params[@"item"][@"id"] ?: @"0" }];
                [self.navigationController pushViewController:vc animated:YES];
            } else if ( [item[@"label"] isEqualToString:@"工作计划"] ) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"LandPlanListVC" params:@{ @"land_id": self.params[@"item"][@"id"] ?: @"0" }];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    
    
    
//    if ( [data[@"key"] isEqualToString:@"相关附件"] ) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        NSMutableDictionary *aItem = [item mutableCopy];
//        aItem[@"addr"] = aItem[@"value"];
//        
//        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": aItem }];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}

- (void)addImagesScroller
{
    self.images = [[NSMutableArray alloc] init];
    
    if ( self.params[@"item"][@"pic1_url"] ) {
        [self.images addObject:self.params[@"item"][@"pic1_url"]];
    }
    
    if ( self.params[@"item"][@"pic2_url"] ) {
        [self.images addObject:self.params[@"item"][@"pic2_url"]];
    }
    
    // 添加水平滚动视图
    if ( self.images.count > 0 ) {
        
        NSString *address = self.params[@"item"][@"address"];
        CGSize size = [address boundingRectWithSize:CGSizeMake(self.contentView.width - 30, 10000)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{ NSFontAttributeName: AWSystemFontWithSize(16, NO) } context:NULL].size;
        
        UIView *tableHeaderView = [[UIView alloc] init];
        tableHeaderView.frame   = CGRectMake(0, 0, self.contentView.width,
                                             self.contentView.width * 0.5625 + 40 + size.height + 15);
        
        self.tableView.tableHeaderView = tableHeaderView;
        
        tableHeaderView.backgroundColor = [UIColor whiteColor];
        
        CGRect frame = tableHeaderView.bounds;
        
        SwipeView *swipeView = [[SwipeView alloc] initWithFrame:frame];
        [tableHeaderView addSubview:swipeView];
        swipeView.height = self.contentView.width * 0.5625;
        
        swipeView.dataSource = self;
        swipeView.delegate   = self;
        
        self.pagerLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(14, NO),
                                        [UIColor whiteColor]);
        self.pagerLabel.backgroundColor = [UIColor blackColor];
        self.pagerLabel.alpha = 0.6;
        
        [swipeView addSubview:self.pagerLabel];
        
        self.pagerLabel.text = [NSString stringWithFormat:@"%@ / %@",
                                @(1), @(self.images.count)];
        [self.pagerLabel sizeToFit];
        
        self.pagerLabel.width += 20;
        self.pagerLabel.height += 6;
        
        self.pagerLabel.cornerRadius = self.pagerLabel.height / 2;
        
        self.pagerLabel.position = CGPointMake(swipeView.width - 10 - self.pagerLabel.width,
                                               swipeView.height - 10 - self.pagerLabel.height);
        
        // 添加地块名
        UILabel *landName = AWCreateLabel(CGRectZero,
                                          nil,
                                          NSTextAlignmentLeft,
                                          AWSystemFontWithSize(16, NO),
                                          AWColorFromRGB(0, 0, 0));
        [tableHeaderView addSubview:landName];
        landName.text = self.params[@"item"][@"address"];
        landName.numberOfLines = 0;
        
        landName.frame = CGRectMake(15, swipeView.bottom + 10,
                                    tableHeaderView.width - 15 * 2,
                                    40);
        
        landName.height = size.height;
        
        // 添加区域
        UILabel *posLabel = AWCreateLabel(CGRectZero,
                                          nil,
                                          NSTextAlignmentLeft,
                                          AWSystemFontWithSize(14, NO),
                                          AWColorFromRGB(137, 137, 137));
        [tableHeaderView addSubview:posLabel];
        posLabel.text = [NSString stringWithFormat:@"%@ %@",
                         self.params[@"item"][@"city"],
                         self.params[@"item"][@"subarea"]];
        
        [posLabel sizeToFit];
        
        posLabel.position = CGPointMake(landName.left, landName.bottom + 10);
        
        // 添加获取方式
        UILabel *getType = AWCreateLabel(CGRectZero,
                                         nil,
                                         NSTextAlignmentCenter,
                                         AWSystemFontWithSize(12, NO),
                                         MAIN_THEME_COLOR);
        [tableHeaderView addSubview:getType];
        getType.text = self.params[@"item"][@"gettype"];
        [getType sizeToFit];
        
        getType.width += 10;
        getType.height  += 6;
        
        getType.cornerRadius = 4;
        getType.layer.borderColor = MAIN_THEME_COLOR.CGColor;
        getType.layer.borderWidth = .5;
        
        getType.center = CGPointMake(posLabel.right + 10 + getType.width / 2,
                                     posLabel.midY);
        
//        tableHeaderView.height = getType.bottom + 30;
        
        AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:tableHeaderView.width
                                                                 color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                                inView:tableHeaderView];
        line.position = CGPointMake(0, tableHeaderView.height - 1);
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.images.count;
}
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = (UIImageView *)view;
    if ( !imageView ) {
        imageView = AWCreateImageView(nil);
        imageView.backgroundColor = [UIColor blackColor];//AWColorFromRGB(245, 245, 245);
        imageView.frame = swipeView.bounds;
        view = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    imageView.image = nil;
    
    [imageView setImageWithProgressIndicatorForURL:[NSURL URLWithString:[self imageUrlForIndex:index]]];
//    [imageView setImageWithURL:[NSURL URLWithString:[self imageUrlForIndex:index]]];
    
    return imageView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    self.pagerLabel.text = [NSString stringWithFormat:@"%@ / %@",
                            @(swipeView.currentPage+1), @(self.images.count)];
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    
    imageInfo.imageURL = [NSURL URLWithString:[self imageUrlForIndex:index]];
    
    UIImageView *imageView = (UIImageView *)[swipeView currentItemView];
    imageInfo.image = imageView.image;
    
    imageInfo.referenceRect = swipeView.frame;
    imageInfo.referenceView = swipeView;
//    imageInfo.referenceContentMode = swipeView.contentMode;
    
    JTSImageViewController *imageViewer =
    [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                 mode:JTSImageViewControllerMode_Image
                                      backgroundStyle:JTSImageViewControllerBackgroundOption_None];
    imageViewer.optionsDelegate = self;
    [imageViewer showFromViewController:self
                             transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (CGFloat)alphaForBackgroundDimmingOverlayInImageViewer:(JTSImageViewController *)imageViewer
{
    return 1.0;
}

- (NSString *)imageUrlForIndex:(NSInteger)index
{
    if ( index < self.images.count ) {
        NSString *imgUrl = self.images[index];
        imgUrl = [[imgUrl componentsSeparatedByString:@"file="] lastObject];
        imgUrl = [[imgUrl componentsSeparatedByString:@"&"] firstObject];
        imgUrl = [NSString stringWithFormat:@"%@/contents", imgUrl];
        return imgUrl;
    }
    
    return nil;
}

@end

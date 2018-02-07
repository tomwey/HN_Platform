//
//  OutputContractListVC.m
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputContractListVC.h"
#import "Defines.h"

@interface OutputContractListVC () <UISearchBarDelegate>

@property (nonatomic, strong) DMButton *areaButton;
@property (nonatomic, strong) DMButton *projButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIButton *unconfirmButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, weak) UIView *captionView;

@property (nonatomic, strong) UIView *contractView;

@property (nonatomic, strong) OutputQueryParams *queryParams;

@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) NSMutableArray *outputAreas;
@property (nonatomic, strong) NSMutableDictionary *outputProjects;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation OutputContractListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"合同清单";
    
    self.contentView.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.queryParams = self.params[@"queryParams"];
    
    self.outputAreas = self.params[@"areas"];
    self.outputProjects = self.params[@"projects"];
    
//    __weak OutputContractListVC *weakSelf = self;
//    [self addRightItemWithImage:@"btn_search2.png" rightMargin:5 callback:^{
//        [weakSelf openSearchVC];
//    }];
    
//    [self addLeftItemWithView:nil];
    
    // 添加一个返回按钮，返回到最开始的流程详情
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
    [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
    
    [self initBreadcrumb];
//    [self initHeaderCaption];
    
//    [self initContractView];
    
    [self startLoad];
    
    [self setDefaultAreaProjects];
}

- (void)initBreadcrumb
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:view];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
    [view addSubview:scrollView];
    scrollView.showsHorizontalScrollIndicator = NO;
    
    NSArray *breadcrumbs = self.params[@"breadcrumbs"];
    
    CGFloat posX = 15;
    NSInteger index = 0;
    for (NSString *item in breadcrumbs) {
        UILabel *label = AWCreateLabel(CGRectZero,
                                       item,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromHex(@"#999999"));
        [scrollView addSubview:label];
        
        [label sizeToFit];
        
        label.position = CGPointMake(posX, view.height / 2 - label.height / 2);
        
        posX = label.right + 30;
        
        if (index != breadcrumbs.count - 1) {
            UIImageView *arrowView = AWCreateImageView(@"icon_arrow-right.png");
            [scrollView addSubview:arrowView];
            arrowView.center = CGPointMake(label.right + 5 + arrowView.width / 2, label.midY);
        }
        
        index ++;
    }
    
    scrollView.contentSize = CGSizeMake(posX - 30 + 15, view.height);
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60,
                                                                   self.contentView.width,
                                                                   self.contentView.height - 60)
                                     style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
//        self.dataSource.tableView = tableView;
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 220 - 15;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (void)backToPage
{
    NSArray *controllers = [self.navigationController viewControllers];
    if ( controllers.count > 1 ) {
        [self.navigationController popToViewController:controllers[1] animated:YES];
    }
}

- (void)openSearchVC
{
    
}

- (void)setDefaultAreaProjects
{
    OutputArea *defaultArea = self.params[@"currentArea"];
    
    if ( !defaultArea ) {
        defaultArea = [self.outputAreas firstObject];
    }
    
    OutputProject *project = self.params[@"currentProject"];
    if ( !project ) {
        project = [self.outputProjects[defaultArea.areaId] firstObject];
    }

//    self.areaButton.userData = defaultArea;
//    self.projButton.userData = project;
//    
//    self.areaButton.title = defaultArea.areaName;
//    self.projButton.title = project.projectName;
    
    self.queryParams.projID = project.projectId;
    
    NSLog(@"project: %@, type: %@", project, project.projectType);
}

- (void)startLoad
{
//    [self.searchBar resignFirstResponder];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同APP",
              @"param1": self.queryParams.queryType ?: @"",
              @"param2": self.queryParams.projID,
              @"param3": self.queryParams.manID,
              @"param4": self.queryParams.catalogID,
              @"param5": self.queryParams.where,
              @"param6": self.queryParams.year,
              @"param7": self.queryParams.month,
              @"param8": self.queryParams.isFeeType,
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error: error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        self.contractView.hidden = YES;
        
//        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
        
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription reloadDelegate:nil];
        self.navBar.title = @"合同清单";
        
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.contentView showHUDWithText:@"没有找到合同数据" offset:CGPointMake(0,20)];
             [self.tableView showErrorOrEmptyMessage:@"没有找到合同数据" reloadDelegate:nil];
            
            self.navBar.title = @"合同清单";
//            self.contractView.hidden = YES;
        } else {
//            self.contractView.hidden = NO;
            
            [self.tableView removeErrorOrEmptyTips];
            
            self.dataSource.dataSource = result[@"data"];
            
            [self.tableView reloadData];
            
            self.navBar.title = [NSString stringWithFormat:@"合同清单(%d)", self.dataSource.dataSource.count];
            
//            [self.dataSource notifyDataChanged];
        }
    }
    NSLog(@"result: %@", result);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.queryParams.queryType = @"0";
    self.queryParams.where = [searchBar.text trim];
    
    [self startLoad];
//    [self gotoConstract];
}

- (void)initContractView
{
    self.contractView = [[UIView alloc] initWithFrame:CGRectMake(0, self.captionView.bottom + 10,
                                                                 self.contentView.width,
                                                                 self.contentView.height - self.captionView.bottom - 10)];
    
    [self.contentView addSubview:self.contractView];
    self.contractView.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectInset(self.contractView.bounds,
                                                                            0, 15)
                                                          style:UITableViewStylePlain];
    [self.contractView addSubview:tableView];
    
    tableView.dataSource = self.dataSource;
    self.dataSource.tableView = tableView;
    
    [tableView removeBlankCells];
    
    tableView.rowHeight = 220 - 15;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil,
                                                  @"ContractCell",
                                                  @"cell.id.contract");
        
        __weak typeof(self) me = self;
        
        OutputArea *defaultArea = self.params[@"currentArea"];
        
        if ( !defaultArea ) {
            defaultArea = [self.outputAreas firstObject];
        }
        
        OutputProject *project = self.params[@"currentProject"];
        if ( !project ) {
            project = [self.outputProjects[defaultArea.areaId] firstObject];
        }

        _dataSource.itemDidSelectBlock = ^(UIView<AWTableDataConfig> *sender, id selectedData) {
            if ( [project.projectType isEqualToString:@"1"] ) {
                // 按楼栋
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputConfirmVC"
                                                                            params:@{ @"item": selectedData ?: [NSNull null],
                                                                                      @"area": defaultArea?: [NSNull null],
                                                                                      @"project": project?: [NSNull null]
                                                                                      }];
                [me.navigationController pushViewController:vc animated:YES];

            } else if ( [project.projectType isEqualToString:@"2"] ) {
                // 按节点
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputConfirmListVC"
                                                                            params:@{ @"item": selectedData ?: [NSNull null],
                                                                                      @"area": defaultArea?: [NSNull null],
                                                                                      @"project": project?: [NSNull null]
                                                                                      }];
                [me.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _dataSource;
}

- (void)initHeaderCaption
{
    self.areaButton.frame = self.projButton.frame = CGRectMake(0, 0, self.contentView.width / 2,40);
    self.projButton.left = self.areaButton.right;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:AWColorFromRGB(201, 201, 201)
                                                            inView:self.contentView];
    line.position = CGPointMake(0, self.areaButton.bottom - 1);
    
    line = [AWHairlineView verticalLineWithHeight:self.areaButton.height
                                            color:AWColorFromRGB(201, 201, 201)
                                           inView:self.contentView];
    line.position = CGPointMake(self.areaButton.right, 0);
    
    UIView *captionView = [[UIView alloc] init];
    [self.contentView addSubview:captionView];
    
    self.captionView = captionView;
    
    captionView.backgroundColor = [UIColor whiteColor];
    captionView.frame = CGRectMake(0, self.areaButton.bottom, self.contentView.width, 108);
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(15, 10, self.contentView.width - 30, 44)];
    [captionView addSubview:self.searchBar];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundImage = AWImageFromColor([UIColor whiteColor]);
    self.searchBar.placeholder = @"输入合同名称、编号、单位名称搜索";
    self.searchBar.delegate = self;
    
    self.unconfirmButton = AWCreateTextButton(CGRectZero,
                                              @"当月未确认产值合同",
                                              MAIN_THEME_COLOR,
                                              self,
                                              @selector(btnClicked:));
    self.confirmButton = AWCreateTextButton(CGRectZero,
                                            @"当月已确认产值合同",
                                            MAIN_THEME_COLOR,
                                            self,
                                            @selector(btnClicked:));
    [captionView addSubview:self.unconfirmButton];
    [captionView addSubview:self.confirmButton];
    
    self.unconfirmButton.tag = 10011;
    self.confirmButton.tag   = 10012;
    
    CGFloat width = (self.contentView.width - 15 * 3) / 2.0;
    
    self.unconfirmButton.frame = self.confirmButton.frame = CGRectMake(0, 0, width, 37);
    
    self.unconfirmButton.position = CGPointMake(15, self.searchBar.bottom + 5);
    self.confirmButton.position   = CGPointMake(self.unconfirmButton.right + 15,
                                                self.unconfirmButton.top);
    
    self.unconfirmButton.layer.cornerRadius = 6;
    self.unconfirmButton.layer.borderColor = [MAIN_THEME_COLOR CGColor];
    self.unconfirmButton.layer.borderWidth = 1;
    self.unconfirmButton.clipsToBounds = YES;
    self.unconfirmButton.backgroundColor = [UIColor whiteColor];
    
    self.confirmButton.layer.cornerRadius = 6;
    self.confirmButton.layer.borderColor = [MAIN_THEME_COLOR CGColor];
    self.confirmButton.layer.borderWidth = 1;
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.backgroundColor = [UIColor whiteColor];
    
    self.unconfirmButton.titleLabel.font = AWSystemFontWithSize(14, NO);
    self.confirmButton.titleLabel.font = AWSystemFontWithSize(14, NO);
}

- (void)btnClicked:(id)sender
{
    NSInteger tag = [sender tag];
    if ( tag == 10011 ) {
        self.queryParams.queryType = @"2";
    } else if (tag == 10012) {
        self.queryParams.queryType = @"3";
    }
    
    [self startLoad];
}

- (void)openPickerForData:(NSArray *)data sender:(DMButton *)sender
{
    if ( data.count == 0 ) {
        return;
    }
    
    UIView *superView = self.contentView;
    
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = superView.bounds;
    
    id currentOption = [sender.userData performSelector:@selector(shortItem) withObject:nil];
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        [temp addObject:[dict performSelector:@selector(shortItem) withObject:nil]];
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:superView];
    
    //    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *inSender, id selectedOption, NSInteger index) {
        
        if ( sender == self.areaButton ) {
            
            if ( ![selectedOption isEqualToDictionary:[self.areaButton.userData performSelector:@selector(shortItem) withObject:nil]] ) {
                sender.userData = data[index];
                self.projButton.title = @"选择项目";
            }
            
        } else if ( sender == self.projButton ) {
            
            if ( ![selectedOption isEqualToDictionary:[self.projButton.userData performSelector:@selector(shortItem) withObject:nil]] ) {
                sender.userData = data[index];
                
                self.queryParams.projID = [self.projButton.userData projectId];
                
                [self startLoad];
            }
        }
        
        sender.title = selectedOption[@"name"];
        
    };
}

- (DMButton *)areaButton
{
    if ( !_areaButton ) {
        _areaButton = [[DMButton alloc] init];
        [self.contentView addSubview:_areaButton];
        
        __weak typeof(self) me = self;
        _areaButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.outputAreas sender:sender];
        };
        
//        _areaButton.title = @"成都";
    }
    return _areaButton;
}

- (DMButton *)projButton
{
    if ( !_projButton ) {
        _projButton = [[DMButton alloc] init];
        [self.contentView addSubview:_projButton];
        
        __weak typeof(self) me = self;
        _projButton.selectBlock = ^(DMButton *sender) {
            OutputArea *area = me.areaButton.userData;
            [me openPickerForData:me.outputProjects[area.areaId] sender:sender];
        };
//        _projButton.title = @"枫丹一期";
    }
    return _projButton;
}


@end

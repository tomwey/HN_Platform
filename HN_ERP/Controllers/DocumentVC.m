//
//  DocumentVC.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DocumentVC.h"
#import "Defines.h"
//#import "AttachmentOperator.h"

@interface DocumentVC () <AWPagerTabStripDataSource, AWPagerTabStripDelegate, SwipeViewDataSource, SwipeViewDelegate, UISearchBarDelegate>

//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) AWTableViewDataSource *dataSource;
//
////@property (nonatomic, strong) UISearchController *searchController;
//@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;
@property (nonatomic, strong) NSArray         *tabTitles;

@property (nonatomic, strong) SwipeView *swipeView;

/** 保存搜索条件 */
@property (nonatomic, strong) NSMutableDictionary *searchConditions;
@property (nonatomic, strong) NSMutableDictionary *readTypes;

//@property (nonatomic, strong) AttachmentOperator *attachmentOperator;

@property (nonatomic, weak) UIButton *clearBtn;

@property (nonatomic, weak) Checkbox *checkbox;

@end

@implementation DocumentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"公文";
    
    __weak DocumentVC *weakSelf = self;
    [self addRightItemWithImage:@"btn_search.png" rightMargin:5 callback:^{
        [weakSelf openSearchVC];
    }];
    
//    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    // 创建滚动标签
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    self.tabStrip.dataSource = self;
    self.tabStrip.delegate   = self;
    [self.contentView addSubview:self.tabStrip];
//    self.tabStrip.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.tabStrip.titleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: AWColorFromRGB(137,137,137) };
    self.tabStrip.selectedTitleAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: MAIN_THEME_COLOR };
    
    // 添加底部工具条
    CGFloat height = [self addBottomItems];
    
    // 添加内容试图
    self.swipeView = [[SwipeView alloc] initWithFrame:
                      CGRectMake(0, self.tabStrip.bottom,
                                 self.contentView.width, self.contentView.height - self.tabStrip.bottom - height)];
    [self.contentView addSubview:self.swipeView];
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate   = self;
//
//    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
//                                                             color:AWColorFromRGB(229, 229, 231) inView:self.contentView];
//    line.position = CGPointMake(0, self.searchBar.bottom);
    
    // 加载数据
    self.tabTitles = @[ @{ @"label": @"全部", @"type": @"0" },
                        @{ @"label": @"地产", @"type": @"1" },
                        @{ @"label": @"物业", @"type": @"2" },
                        @{ @"label": @"商业", @"type": @"3" }
                        ];
    
    self.tabStrip.tabWidth = self.contentView.width / self.tabTitles.count;
    
    [self.tabStrip reloadData];
    
    [self.swipeView reloadData];
    
    // 加载第一页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DocumentView *docView = (DocumentView *)[self.swipeView currentItemView];
        [docView startLoadingForType:self.tabTitles[0][@"type"]];
    });
    
    [self addNotifications];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"公文"
                                    keyMemo:nil];
}

- (void)openSearchVC
{
    id item = self.tabTitles[self.swipeView.currentPage];
    NSString *type = item[@"type"];
    NSString *title = item[@"label"];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DocSearchVC" params:@{ @"title": title ?: @"公文搜索", @"search_conditions" : [self searchConditionForType:type] ?: @{} }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (CGFloat)addBottomItems
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 50)];
    [self.contentView addSubview:toolbar];
    toolbar.top = self.contentView.height - toolbar.height;
    
    toolbar.backgroundColor = [UIColor whiteColor];//AWColorFromRGB(249, 249, 249);
    
    // 添加checkbox
    Checkbox *checkbox = [[Checkbox alloc] initWithNormalImage:[UIImage imageNamed:@"icon_checkbox.png"]
                                                 selectedImage:[UIImage imageNamed:@"icon_checkbox_click.png"]];
    [toolbar addSubview:checkbox];
    self.checkbox = checkbox;
    
    checkbox.position = CGPointMake(10, toolbar.height / 2 - checkbox.height / 2);
    checkbox.label = @"只看未读";
    checkbox.labelAttributes = @{NSFontAttributeName: AWSystemFontWithSize(15, NO)};
    checkbox.didChangeBlock = ^(Checkbox *sender) {
        NSString *type = self.tabTitles[self.swipeView.currentPage][@"type"];
        [self changeReadType: sender.checked ? @"0" : @"-1" forType:type];
    };
    
    // 添加清除搜索按钮
    UIButton *clearBtn = AWCreateTextButton(CGRectMake(0, 0, 120, 50),
                                            @"清除搜索",
                                            [UIColor whiteColor],
                                            self, @selector(clearSearch));
    [toolbar addSubview:clearBtn];
    clearBtn.backgroundColor = MAIN_THEME_COLOR;
    
    self.clearBtn = clearBtn;
    
    clearBtn.userInteractionEnabled = NO;
    clearBtn.backgroundColor = AWColorFromRGB(201, 201, 201);
    
    clearBtn.titleLabel.font = AWSystemFontWithSize(15, NO);
    
    CGFloat top = toolbar.height / 2 - clearBtn.height / 2;
    clearBtn.position = CGPointMake(toolbar.width - top - clearBtn.width, top);
    
    return toolbar.height;
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNoti:) name:@"kNeedSearchNotification" object:nil];
}

//- (AttachmentOperator *)attachmentOperator
//{
//    if ( !_attachmentOperator ) {
//        _attachmentOperator = [[AttachmentOperator alloc] init];
//        _attachmentOperator.previewController = self;
//    }
//    return _attachmentOperator;
//}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.tabTitles.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    DocumentView *docView = nil;//(DocumentView *)view;
    if ( !docView ) {
        docView = [[DocumentView alloc] initWithFrame:self.swipeView.bounds];
        view = docView;
    }
    
    id item = self.tabTitles[index];
    
    docView.loadingContainer = nil;//self.contentView;
    
    docView.readType = [self readTypeForType:item[@"type"]];
    docView.searchCondition  = [self searchConditionForType:item[@"type"]];
    docView.industryType     = item[@"type"];
    
    __weak typeof(self) me = self;
    docView.didSelectDocumentBlock = ^(DocumentView *sender, id inItem){

        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": inItem }];
        [me.navigationController pushViewController:vc animated:YES];
    };
    
    return docView;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    NSString *type = self.tabTitles[self.swipeView.currentPage][@"type"];
    
    self.checkbox.checked = [[self readTypeForType:type] isEqualToString:@"0"] ? YES : NO;
    
    [self addResetSearchButtonForType:type];
    
    DocumentView *view = (DocumentView *)[self.swipeView currentItemView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view startLoadingForType:type];
    });
    
//    [view startLoadingDocuments:@{ @"typeID": [@(self.swipeView.currentPage) description],
//                                   @"keyword": [self.searchBar.text trim] ?: @""
//                                   }];
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return [self.tabTitles count];
}

- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index][@"label"];
}

- (void)pagerTabStrip:(AWPagerTabStrip *)tabStrip didSelectTabAtIndex:(NSInteger)index
{
    self.swipeView.currentPage = index;
//    [self.swipeView scrollToPage:index duration:.3];
}

- (NSDictionary *)searchConditionForType:(NSString *)type
{
    if ( !type ) return nil;
    id object = self.searchConditions[type];
    if ( !object ) {
        object = @{};
        self.searchConditions[type] = object;
    }
    
    if ( [object isKindOfClass:[NSDictionary class]] ) {
        return (NSDictionary *)object;
    }
    
    return nil;
}

- (void)handleNoti:(NSNotification *)noti
{
    id object = noti.object;
    if ( [object isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *currentSearchCondition = [object copy];
        
        NSString *type = nil;
        if ( self.swipeView.currentPage < self.tabTitles.count ) {
            type = self.tabTitles[self.swipeView.currentPage][@"type"];
            
            // 保存当前的搜索条件
            [self saveSearchCondition:currentSearchCondition forType:type];
            
            // 开始搜索
            [self startSearchCondition:currentSearchCondition forType:type];
        }
    }
}

- (void)saveSearchCondition:(NSDictionary *)searchCondition
                    forType:(NSString *)type
{
    if ( type ) {
        self.searchConditions[type] = searchCondition ?: @{};
    }
}

- (void)startSearchCondition:(NSDictionary *)condition forType:(NSString *)type
{
    // 添加清除按钮
    [self addResetSearchButtonForType:type];
    
    UIView *view = self.swipeView.currentItemView;
    if ( [view isKindOfClass:[DocumentView class]] ) {
        DocumentView *listView = (DocumentView *)view;
        listView.searchCondition = condition;
        listView.industryType    = type;
        listView.readType = [self readTypeForType:type];
        
        [listView forceRefreshForType:type];
    }
}

- (void)clearSearch
{
    [self resetSearchConditionForType:self.tabTitles[self.swipeView.currentPage][@"type"]];
}

// 重置搜索
- (void)resetSearchConditionForType:(NSString *)type
{
    [self.searchConditions removeObjectForKey:type];
    
    [self startSearchCondition:@{} forType:type];
}

- (void)addResetSearchButtonForType:(NSString *)type
{
    NSDictionary *dict = [self searchConditionForType:type];
    if ( dict.count == 0 ) {
        self.clearBtn.userInteractionEnabled = NO;
        self.clearBtn.backgroundColor = AWColorFromRGB(201, 201, 201);
    } else {
        self.clearBtn.userInteractionEnabled = YES;
        self.clearBtn.backgroundColor = MAIN_THEME_COLOR;
    }
}

- (void)changeReadType:(NSString *)readType forType:(NSString *)type
{
    self.readTypes[type] = readType ?: @"-1";
    
    [self startSearchCondition:[self searchConditionForType:type] forType:type];
}

- (NSString *)readTypeForType:(NSString *)type
{
    if (!type) return nil;
    
    NSString *readType = self.readTypes[type];
    if ( !readType ) {
        readType = @"-1";
        self.readTypes[type] = readType;
    }
    return readType;
}

- (NSMutableDictionary *)readTypes
{
    if ( !_readTypes ) {
        _readTypes = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _readTypes;
}

- (NSMutableDictionary *)searchConditions
{
    if ( !_searchConditions ) {
        _searchConditions = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _searchConditions;
}

@end

//
//  NewsListVC.m
//  HN_ERP
//
//  Created by tomwey on 4/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "NewsListVC.h"
#import "Defines.h"
#import "BannerView.h"

@interface NewsListVC () <UITableViewDelegate, BannerViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) NSArray    *bannerDataSource;

@property (nonatomic, assign) BOOL needResumeBanner;

@end

@implementation NewsListVC

- (void)dealloc
{
    [self.bannerView stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"新闻";
    
    self.needResumeBanner = NO;
    
    [self loadTopNews];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"新闻"
                                    keyMemo:nil];
    
//    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.needResumeBanner ) {
        self.needResumeBanner = NO;
        [self.bannerView resume];
    }
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.needResumeBanner = YES;
    
    [self.bannerView pause];
}

- (void)loadTopNews
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] ?: @"0" description];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"最热新闻查询APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        [self.contentView showHUDWithText:error.domain succeed:NO];
        self.tableView.tableHeaderView = nil;
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.contentView showHUDWithText:@"<无数据显示>"];
            self.tableView.tableHeaderView = nil;
        } else {
            [self showTableHeader:result];
//            self.dataSource = result[@"data"];
//            [self.tableView reloadData];
        }
    }
}

- (void)showTableHeader:(id)result
{
    self.bannerDataSource = result[@"data"];
    
    self.tableView.tableHeaderView = self.bannerView;
    
//    self.bannerView.pageControl.frame =
//        CGRectMake(self.bannerView.width - 80,
//                   self.bannerView.height - 30,
//                   60, 30);
    
    [self.bannerView reloadData];
//    [self.contentView addSubview:self.bannerView];
}

- (void)loadData
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] ?: @"0" description];

    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) weakSelf = self;

    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"新闻查询APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [weakSelf handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        [self.contentView showHUDWithText:error.domain succeed:NO];
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            [self.contentView showHUDWithText:@"<无数据显示>"];
            [self.tableView showErrorOrEmptyMessage:@"<无数据显示>" reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {
            self.dataSource.dataSource = result[@"data"];
        }
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self forwardToNewsDetail:self.dataSource.dataSource[indexPath.row]];
}

- (void)forwardToNewsDetail:(id)item
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewsDetailVC" params:@{ @"item": item ?: @{} }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.rowHeight  = 90;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"NewsCell", @"cell.id");
    }
    return _dataSource;
}

- (BannerView *)bannerView
{
    if ( !_bannerView ) {
        _bannerView = [[BannerView alloc] init];
        _bannerView.frame = CGRectMake(0, 0, self.contentView.width,
                                       self.contentView.width * 0.5625);
        _bannerView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        _bannerView.didSelectItemBlock = ^(BannerView *sender, NSInteger index) {
            [weakSelf forwardToNewsDetail:weakSelf.bannerDataSource[index]];
        };
        
        _bannerView.pageControl.currentPageIndicatorTintColor = MAIN_THEME_COLOR;
        _bannerView.pageControl.pageIndicatorTintColor = AWColorFromRGBA(254,254,254,0.9);
    }
    return _bannerView;
}

- (NSInteger)numberOfItemsInBannerView:(BannerView *)bannerView
{
    return self.bannerDataSource.count;
}

- (UIView *)bannerView:(BannerView *)bannerView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = (UIImageView *)view;
    if ( !imageView ) {
        imageView = AWCreateImageView(nil);
        view = imageView;
        imageView.backgroundColor = AWColorFromRGB(221, 221, 221);
        imageView.frame = bannerView.bounds;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        
        UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bannerView.width, 30)];
        [imageView addSubview:banner];
        banner.backgroundColor = AWColorFromRGBA(0, 0, 0, 0.7);
        banner.top = imageView.height - banner.height;
    }
    
    UILabel *label = (UILabel *)[imageView viewWithTag:100];
    if ( !label ) {
        label = AWCreateLabel(CGRectZero,
                              nil,
                              NSTextAlignmentLeft,
                              AWSystemFontWithSize(14, NO),
                              self.bannerView.pageControl.pageIndicatorTintColor);
        [imageView addSubview:label];
        label.tag = 100;
        label.frame = CGRectMake(15, 0, imageView.width - 80, 30);
        label.top = imageView.height - label.height;
    }
    
    label.textColor = self.bannerView.pageControl.pageIndicatorTintColor;
    
    label.text = self.bannerDataSource[index][@"title"];
    
    imageView.image = nil;
    
    NSString *imageUrl = self.bannerDataSource[index][@"image"];
    imageUrl = [[imageUrl componentsSeparatedByString:@"?"] lastObject];
    imageUrl = [[imageUrl queryDictionaryUsingEncoding:NSUTF8StringEncoding][@"file"] stringByAppendingPathComponent:@"contents"];
    
    [imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    return imageView;
}

@end

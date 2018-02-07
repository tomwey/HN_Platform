//
//  KnowledgeDocListVC.m
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "KnowledgeDocListVC.h"
#import "Defines.h"
#import "DocBreadcrumbView.h"

@interface KnowledgeDocListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataSource;
@property (nonatomic, strong) DocBreadcrumbView *breadcrumbView;

@end

@implementation KnowledgeDocListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = self.params[@"title"];
    
//    self.searchConditions = [@{} mutableCopy];
    
    if ( ![self.params[@"from_search"] boolValue] ) {
        __weak typeof(self) me = self;
        [self addRightItemWithImage:@"btn_search.png" rightMargin:2 callback:^{
            [me doSearch];
        }];
    }
    
    NSArray *breadcrumbs = self.params[@"breadcrumbs"];
    if ( ![self.params[@"from_search"] boolValue] && breadcrumbs.count > 0 ) {
        self.breadcrumbView.frame = CGRectMake(0, 0, self.contentView.width, 60);

        NSMutableArray *temp = [breadcrumbs mutableCopy];
        [temp addObject:[[DocBreadcrumb alloc] initWithName:self.navBar.title
                                                       data:nil
                                                       page:self]];
        self.breadcrumbView.breadcrumbs = [temp copy];

        self.tableView.height -= self.breadcrumbView.height;
        self.tableView.top     = self.breadcrumbView.height;
    }
    
    [self startLoading];
    
}

- (void)doSearch
{
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"KnowledgeDocSearchVC" params:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)startLoading
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
              @"funname": @"知识库文档查询APP",
              @"param1": manID,
              @"param2": [self.params[@"mid"] description],
              @"param3": self.params[@"level"] ?: @"",
              @"param4": self.params[@"doc_no"] ?: @"",
              @"param5": self.params[@"doc_name"] ?: @"",
              @"param6": @"",
              @"param7": @"",
              @"param8": @"1",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (DocBreadcrumbView *)breadcrumbView
{
    if ( !_breadcrumbView ) {
        _breadcrumbView = [[DocBreadcrumbView alloc] init];
        [self.contentView addSubview:_breadcrumbView];
        _breadcrumbView.backgroundColor = [UIColor whiteColor];
        
        AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:_breadcrumbView];
        line.position = CGPointMake(0, 59);
        
        __weak typeof(self) me = self;
        _breadcrumbView.breadcrumbClickCallback =
        ^(DocBreadcrumbView *sender, DocBreadcrumb *b) {
            [me forwardForBreadcrumb:b];
        };
    }
    return _breadcrumbView;
}

- (void)forwardForBreadcrumb:(DocBreadcrumb *)b
{
    [self.navigationController popToViewController:b.page animated:YES];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT
                                     reloadDelegate:nil];
            self.dataSource = nil;
        } else {
            self.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell.id"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id item = self.dataSource[indexPath.row];
    
    // 设置图标
    NSString *title = [item[@"docname"] description];
    NSString *imageName = [NSString stringWithFormat:@"icon_%@.png",
                           [item[@"filename"] pathExtension]];
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    // 设置标题
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@",item[@"title"]];
    //    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    //    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = AWSystemFontWithSize(15, NO);
    cell.textLabel.text = [title stringByDeletingPathExtension];
    
    // 设置描述
//    NSString *size = [item[@"size"] integerValue] < 1000 ?
//    [NSString stringWithFormat:@"%@KB", item[@"size"]] :
//    [NSString stringWithFormat:@"%.1fMB", [item[@"size"] integerValue] / 1024.0];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"\n%@ %@ %@",
//                                 item[@"proj_name"],size, item[@"time"]];
//    
//    cell.detailTextLabel.textColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR;
//    cell.detailTextLabel.font = AWSystemFontWithSize(14, NO);
//    cell.detailTextLabel.numberOfLines = 2;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id dict = self.dataSource[indexPath.row];
    
    if ( [[dict[@"url"] description] length] == 0 ) {
        [self.contentView showHUDWithText:@"附件地址为空" offset:CGPointMake(0,20)];
        return;
    }
    
    NSDictionary *params = [[[[dict[@"url"] description] componentsSeparatedByString:@"?"] lastObject] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
    
    id item = [dict mutableCopy];
    
    item[@"addr"]  = params[@"file"] ?: @"";
    item[@"isdoc"] = params[@"isdoc"] ?: @"";
    item[@"docid"] = params[@"fileid"] ?: @"0";
    item[@"filename"] = params[@"filename"] ?: @"";
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"AttachmentPreviewVC" params:@{ @"item": item }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.rowHeight = 60;
        
        [_tableView removeBlankCells];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
    }
    return _tableView;
}


@end

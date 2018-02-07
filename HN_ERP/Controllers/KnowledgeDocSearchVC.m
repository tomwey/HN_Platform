//
//  KnowledgeDocSearchVC.m
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "KnowledgeDocSearchVC.h"
#import "Defines.h"

@interface KnowledgeDocSearchVC ()

@property (nonatomic, weak) UIButton *doneBtn;
@property (nonatomic, weak) UIButton *resetBtn;

@end

@implementation KnowledgeDocSearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"文档搜索";
    
    [self addRightItemWithView:nil];
    
    UIButton *closeBtn = HNCloseButton(34, self, @selector(close));
    [self addLeftItemWithView:closeBtn leftMargin:2];
    
    UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                        50),
                                             @"搜索",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(done));
    [self.contentView addSubview:commitBtn];
    commitBtn.backgroundColor = MAIN_THEME_COLOR;
    commitBtn.position = CGPointMake(0, self.contentView.height - 50);
    
    self.doneBtn = commitBtn;
    
    UIButton *moreBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                      50),
                                           @"重置",
                                           IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
                                           self,
                                           @selector(reset));
    [self.contentView addSubview:moreBtn];
    moreBtn.backgroundColor = [UIColor whiteColor];
    moreBtn.position = CGPointMake(commitBtn.right, self.contentView.height - 50);
    
    self.resetBtn = moreBtn;
    
    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:moreBtn.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:moreBtn];
    hairLine.position = CGPointMake(0,0);
    
    moreBtn.left = 0;
    commitBtn.left = moreBtn.right;
    
    self.tableView.height -= moreBtn.height;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self prepareFormObjects];
}

- (void)prepareFormObjects
{
    NSDictionary *searchConditions = self.params[@"search_conditions"];
    if ( searchConditions.count > 0 ) {
        for (id key in searchConditions) {
            id value = searchConditions[key];
            self.formObjects[key] = value;
        }
        [self.tableView reloadData];
    }
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    CGRect frame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.doneBtn.top =
        self.resetBtn.top =
        self.contentView.height - CGRectGetHeight(frame) - self.doneBtn.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.doneBtn.top =
        self.resetBtn.top =
        self.contentView.height - self.doneBtn.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)doSearch
{
    UIViewController *vc =
    [[AWMediator sharedInstance]  openVCWithName:@"KnowledgeDocListVC"
                                          params:@{ @"title": @"搜索结果",
                                                    @"mid": @"0",
                                                    @"level": self.formObjects[@"level"][@"value"] ?:@"",
                                                    @"doc_no": self.formObjects[@"doc_no"] ?: @"",
                                                    @"doc_name": self.formObjects[@"doc_name"] ?: @"",
                                                    @"from_search": @"1"}];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)close
{
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    [self hideKeyboard];
    
    [self doSearch];
}

- (void)reset
{
    [self resetForm];
}

- (BOOL)supportsTextArea
{
    return NO;
}


- (NSArray *)formControls
{
    return @[@{
                 @"data_type": @"9",
                 @"datatype_c": @"下拉选",
                 @"describe": @"级别",
                 @"field_name": @"level",
                 @"item_name": @"全部,一级,二级,三级",
                 @"item_value": @",一,二,三",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"文档编号",
                 @"field_name": @"doc_no",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"文档名称",
                 @"field_name": @"doc_name",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             ];
}


@end

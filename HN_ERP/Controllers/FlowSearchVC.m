//
//  FlowSearchVC.m
//  HN_ERP
//
//  Created by tomwey on 5/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowSearchVC.h"
#import "Defines.h"
#import "AddContactsModel.h"

@interface FlowSearchVC ()

@property (nonatomic, strong) NSMutableDictionary *contactsModels;

@property (nonatomic, weak) UIButton *doneBtn;
@property (nonatomic, weak) UIButton *resetBtn;

@end

@implementation FlowSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"流程搜索";
    
    [self addRightItemWithView:nil];
    
    UIButton *closeBtn = HNBackButton(24, self, @selector(close));
    [self addLeftItemWithView:closeBtn leftMargin:0];
    
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
    
//    [self prepareFormObjects];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    [super keyboardWillShow:noti];
    
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
    [super keyboardWillHide:noti];
    
    NSDictionary *userInfo = noti.userInfo;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.doneBtn.top =
        self.resetBtn.top =
        self.contentView.height - self.doneBtn.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)close
{
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    [self hideKeyboard];
    
    if ( self.formObjects.count == 0 ) {
        
        [self.contentView showHUDWithText:@"至少需要一个搜索条件"
                                   offset:CGPointMake(0,20)];
        
        return;
    }
    NSDictionary *params =
    @{ @"condition": self.formObjects ?: @{},
       @"field_name": self.params[@"field_name"] ?: @"",
       @"flows": self.params[@"flows"] ?: @[],
       };
    UIViewController *vc =
    [[AWMediator sharedInstance] openVCWithName:@"FlowSearchResultVC"
                                         params:params];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reset
{
    //    [self hideKeyboard];
    
    [self resetForm];
}

- (AddContactsModel *)contactsModelForKey:(NSString *)key
{
    AddContactsModel *model = self.contactsModels[key];
    if ( !model ) {
        model = [[AddContactsModel alloc] initWithFieldName:key
                                             selectedPeople:@[]];
        self.contactsModels[key] = model;
    }
    return model;
}

- (NSMutableDictionary *)contactsModels
{
    if ( !_contactsModels ) {
        _contactsModels = [@{} mutableCopy];
    }
    return _contactsModels;
}

- (BOOL)supportsTextArea
{
    return NO;
}

- (NSArray *)formControls
{
    return @[@{
                     @"data_type": @"1",
                     @"datatype_c": @"文本框",
                     @"describe": @"流程说明",
                     @"field_name": @"flow_desc",
                     @"item_name": @"",
                     @"item_value": @"",
                     },
                 @{
                     @"data_type": @"1",
                     @"datatype_c": @"文本框",
                     @"describe": @"流程编号",
                     @"field_name": @"flow_no",
                     @"item_name": @"",
                     @"item_value": @"",
                     },
                 @{
                     @"data_type": @"6",
                     @"datatype_c": @"添加多个人",
                     @"describe": @"创建人",
                     @"field_name": @"contacts",
                     @"item_name": @"",
                     @"item_value": @"",
                     },
                 @{
                     @"data_type": @"13",
                     @"datatype_c": @"日期范围选择框",
                     @"describe": @"创建时间",
                     @"field_name": @"create_date",
                     @"sub_describe": @"开始时间,结束时间",
                     @"split_desc": @"至",
                     @"item_name": @"",
                     @"item_value": @"",
                     },];
}

@end

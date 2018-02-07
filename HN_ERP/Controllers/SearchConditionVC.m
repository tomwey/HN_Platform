//
//  SearchConditionVC.m
//  HN_ERP
//
//  Created by tomwey on 2/27/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SearchConditionVC.h"
#import "Defines.h"
#import "AddContactsModel.h"

@interface SearchConditionVC ()

@property (nonatomic, strong) NSMutableDictionary *contactsModels;

@property (nonatomic, weak) UIButton *doneBtn;
@property (nonatomic, weak) UIButton *resetBtn;

@end

@implementation SearchConditionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = self.params[@"title"];
    
    [self addRightItemWithView:nil];
    
    UIButton *closeBtn = HNCloseButton(34, self, @selector(close));
    [self addLeftItemWithView:closeBtn leftMargin:2];
    
//    __weak typeof(self) weakSelf = self;
//    [self addLeftItemWithImage:@"btn_close.png"
//                    leftMargin:5
//                      callback:^{
//        [weakSelf hideKeyboard];
//        [weakSelf dismissViewControllerAnimated:YES completion:nil];
//    }];
//    UIButton *closeBtn = HNCloseButton(34, self, @selector(close));
//    [self addLeftItemWithView:closeBtn leftMargin:5];
//    
//    UIButton *searchBtn = (UIButton *)[self addRightItemWithTitle:@"搜索" size:CGSizeMake(40, 40) callback:^{
//        [weakSelf done];
//    }];
    
//    searchBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    searchBtn.layer.borderWidth = 0.8;
//    searchBtn.layer.cornerRadius = 6;
//    searchBtn.clipsToBounds = YES;

//    searchBtn.titleLabel.font = AWSystemFontWithSize(15, NO);
//    
//    UIButton *moreBtn = AWCreateTextButton(CGRectMake(0, 0, 40, 40),
//                                           @"重置",
//                                           [UIColor whiteColor],
//                                           self,
//                                           @selector(reset));
//    moreBtn.titleLabel.font = AWSystemFontWithSize(15, NO);
//    [self.navBar addFluidBarItem:moreBtn
//                      atPosition:FluidBarItemPositionTitleRight];
    
    
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
        
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification
//                                               object:nil];
    
    
    [self prepareFormObjects];
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
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSDictionary *searchCondition = self.params[@"search_conditions"];
    if ( ![searchCondition isEqualToDictionary:self.formObjects] ) {
        NSLog(@"search conditions: %@", self.formObjects);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kSearchConditionDidSaveNotification" object:self.formObjects];
    }
}

- (void)done
{
    [self hideKeyboard];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if ( [self.params[@"search_type"] integerValue] == 0 ) {
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
    return @[@{
                 @"data_type": @"9",
                 @"datatype_c": @"下拉选",
                 @"describe": @"我的流程",
                 @"field_name": @"flow_state",
                 @"item_name": @"全部流程,总裁批示,我的请求,我的已办,我的归档,授权查阅",
                 @"item_value": @"0,6,2,3,4,7",
                 },// 0：全部流程；1：我的待办；2：我的请求；3：我的已办；4：我的归档；5：我的抄送；6：总裁批示；7：授权查询
             @{
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
                 @"data_type": @"6",
                 @"datatype_c": @"添加多个人",
                 @"describe": @"流程参与人",
                 @"field_name": @"contacts2",
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

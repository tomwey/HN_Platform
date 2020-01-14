//
//  FormVC.m
//  HN_ERP
//
//  Created by tomwey on 1/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FormVC.h"
#import "Defines.h"
#import "SelectControl.h"
#import "SelectPicker.h"
#import "DatePicker.h"
#import "EmploySearchView.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "RadioButton.h"

#import "UIView+TYAlertView.h"
// if you want blur efffect contain this
#import "TYAlertController+BlurEffects.h"

@interface FormVC () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,TZImagePickerControllerDelegate>

@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

// 保存表单的数据
@property (nonatomic, strong, readwrite) NSMutableDictionary *formObjects;

@property (nonatomic, strong) NSMutableArray *contactsButtons;

// 记录当前第一响应者
@property (nonatomic, weak) UIView *firstResponder;

@property (nonatomic, strong) CustomOpinionView *opinionView;

@property (nonatomic, weak) UITextView *textView;

@property (nonatomic, strong) NSArray *opinions;

// 添加联系人
@property (nonatomic, strong) NSMutableDictionary<NSString *, AddContactsModel *> *contactModels;

// 员工搜索提示框
@property (nonatomic, strong) EmploySearchView *empSearchView;

@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) AFHTTPRequestOperation *uploadOperation;
@property (nonatomic, strong) NSMutableArray *attachmentIDs;

@property (nonatomic, copy) NSString *currentAttachmentFieldName;
@property (nonatomic, weak) id currentAttachmentFormControl;

@end

@interface UITextField (CustomData)

@property (nonatomic, strong) id data;

@end

@implementation UITextField (CustomData)

- (void)setData:(id)data
{
    objc_setAssociatedObject(self, &@selector(setData:), data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)data
{
    return objc_getAssociatedObject(self, &@selector(setData:));
}

@end

@implementation FormVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( [self supportsCustomOpinion] ) {
        [self loadCustomOpinions];
    }
    
    self.navBar.title = [self.params[@"item"][@"flow_desc"] description];
    
    __weak typeof(self) me = self;
    NSString *action = self.params[@"action"][@"name"];
    
    NSDictionary *titleAttributes = @{ NSFontAttributeName: AWSystemFontWithSize(16, NO) };
    CGSize size = [action sizeWithAttributes:titleAttributes];
    size.width += 20;
    size.height = 40;
    
    [self addRightItemWithTitle:action
                titleAttributes:titleAttributes
                           size:size
                    rightMargin:5
                       callback:^{
        [me doSend];
    }];
    
    self.formObjects = [NSMutableDictionary dictionary];
    self.contactsButtons = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    [self.contentView addSubview:self.tableView];
    
    self.tableView.sectionFooterHeight = 0;
    self.tableView.sectionHeaderHeight = 1;
    
    self.tableView.delegate = self;
    
    self.dataSource = [NSMutableArray array];
    
    if ( [[self formControls] count] > 0 ) {
        [self.dataSource addObjectsFromArray:[self formControls]];
    }
    
    if ( [self supportsTextArea] ) {
        [self.dataSource addObject:@{
                                     @"data_type": @"10",
                                     @"datatype_c": @"多行文本",
                                     @"describe": @"签字意见",
                                     @"field_name": @"opinion",
                                     @"item_name": @"",
                                     @"item_value": @"",
                                     }];
    }
    
    self.tableView.dataSource = self;
    
    [self.tableView removeBlankCells];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsDidAdd:)
                                                 name:
     @"kContactDidSelectNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFlows:) name:@"kFlowSearchResultDidSelectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addFlow:) name:@"kFlowDidSelectNotification" object:nil];
    
}

- (void)setDisableFormInputs:(BOOL)disableFormInputs
{
    _disableFormInputs = disableFormInputs;
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.userInteractionEnabled = !disableFormInputs;
    }
}

- (void)formControlsDidChange
{
    [self.dataSource removeAllObjects];
    
    if ( [[self formControls] count] > 0 ) {
        [self.dataSource addObjectsFromArray:[self formControls]];
    }
    
    if ( [self supportsTextArea] ) {
        [self.dataSource addObject:@{
                                     @"data_type": @"10",
                                     @"datatype_c": @"多行文本",
                                     @"describe": @"签字意见",
                                     @"field_name": @"opinion",
                                     @"item_name": @"",
                                     @"item_value": @"",
                                     }];
    }
    
    [self.tableView reloadData];
}

- (void)loadCustomOpinions
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"常用意见查询APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  if ( [result[@"rowcount"] integerValue] > 0 ) {
                      NSMutableArray *temp = [NSMutableArray array];
                      for (id dict in result[@"data"]) {
                          if ( dict[@"opinion"] ) {
                              [temp addObject:[dict[@"opinion"] description]];
                          }
                          
                      }
                      
                      weakSelf.opinions = [temp copy];
//                      weakSelf.opinionView.opinions = temp;
//                      [weakSelf.opinionView reloadData];
                  }
              }];
}

- (BOOL)supportsTextArea
{
    return YES;
}

- (void)resetForm
{
    self.formObjects = [NSMutableDictionary dictionary];
    
    [self.tableView reloadData];
}

- (void)hideKeyboard
{
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationOptions = [noti.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.keyboardFrame = keyboardFrame;
    
//    [self updateSearchBoxPosition];
    
    self.tableView.contentInset          =
    self.tableView.scrollIndicatorInsets =
    UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0);
    /*
    CGFloat dty = CGRectGetMaxY(activeFieldFrame) - CGRectGetMinY(keyboardFrame);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
//         if ( self.activeField == self.lastField ) {
//             CGFloat delta = dty > 0 ? dty : 0;
//             self.autoScrollUITextFieldsContainer.contentOffset = CGPointMake(0, self.extraOffset + delta);
//         } else {
             CGFloat offsetY = dty > 0 ? dty : 0;
             self.tableView.contentOffset = CGPointMake(0, offsetY);
//         }
     } completion:nil];*/
    
    UITableViewCell *cell = (UITableViewCell *)[[self.firstResponder superview] superview];
    
    //    [self.tableView scrollRectToVisible:r animated:YES];
    
    if ( _empSearchView && _empSearchView.hidden == NO ) {
        cell = (UITableViewCell *)[[[self.firstResponder superview] superview] superview];
    }
    
    CGRect r = CGRectMake(self.firstResponder.frame.origin.x,
                          cell.frame.origin.y + self.firstResponder.frame.origin.y + 10 + 40,
                          self.firstResponder.frame.size.width,
                          self.firstResponder.frame.size.height);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
         [self.tableView scrollRectToVisible:r animated:NO];
     } completion:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSLog(@"%@", self.firstResponder);
    
//    self.tableView.contentInset = UIEdgeInsetsZero;
//    [self.tableView setContentOffset:self.offset animated:YES];
    
    
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationOptions = [noti.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
         self.tableView.contentInset          =
         self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
//         self.tableView.contentOffset = CGPointZero;
     } completion:nil];
}

- (void)doSend
{
    if ( ![self apiParams] || [[self apiParams] count] == 0 ) {
        NSLog(@"没有设置提交参数");
        return;
    }
    
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
    
    // 如果是表单提交，需要判断流程表单是否有必填字段未输入
    if ( [self.params[@"action"][@"action"] isEqualToString:@"submit"] ) {
        BOOL required = [self.params[@"required"] boolValue];
        if ( required ) {
            [self.contentView showHUDWithText:@"流程表单有必填字段，请到PC端进行设置!"
                                       offset:CGPointMake(0,20)];
            return;
        }
    }
    
    if ( [self apiParams][@"agree"] && [[self apiParams][@"agree"] length] == 0 ) {
        [self.contentView showHUDWithText:@"请选择是否同意"
                                   offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *opinion = self.formObjects[@"opinion"] ?: @"";
    
    // 流程退回处理
    if ([[self apiParams][@"type"] isEqualToString:@"back"]) {
        // 退回必须选择节点
        if (!([[self apiParams][@"backdid"] integerValue] > 0)) {
            // 有效的节点id是一个大于0的整数
            [self.contentView showHUDWithText:@"必须选择一个退回节点"
                                       offset:CGPointMake(0,20)];
            return;
        }
        
        // 必须输入意见
        if (opinion.length == 0) {
            [self.contentView showHUDWithText:@"意见不能为空"
                                       offset:CGPointMake(0,20)];
            return;
        }
    }
    
    if ( opinion.length == 0 ) {
        // 处理意见是否必填的提示
        NSDictionary *apiParam = [self apiParams];
        
        // 如果不同意，那么必须输入意见
        if ( [apiParam[@"agree"] length] > 0 && [apiParam[@"agree"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"意见不能为空"
                                       offset:CGPointMake(0,20)];
            return;
        }
        
        // 如果有这个字段那就做一个意见不能为空的判断
        if ( apiParam[@"opinion_allow_null"] ) {
            BOOL flag = [apiParam[@"opinion_allow_null"] boolValue];
            if ( !flag ) {
                [self.contentView showHUDWithText:@"意见不能为空"
                                           offset:CGPointMake(0,20)];
                
                return;
            }
        }
    }
    
    if ([self.params[@"action"][@"action"] isEqualToString:@"submit"]) {
        __weak typeof(self) weakSelf = self;
        
        id user = [[UserService sharedInstance] currentUser];
        NSString *manID = [user[@"man_id"] description];
        manID = manID ?: @"0";
        
        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
        
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"GetData",
                  @"funname": @"流程处理前验证APP",
                  @"param1": self.params[@"mid"] ?: @"0",
                  @"param2": manID,
                  @"param3": @"提交",
                  @"param4": @"1", // iOS
                  } completion:^(id result, NSError *error) {
//                      NSLog(@"auth result: %@", result);
                      [weakSelf handleAuthResult:result error: error];
                  }];
        
        return;
    } else {
        [self sendReq];
    }
}

- (void)handleAuthResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 1 ) {
            id item = [result[@"data"] firstObject];
            if ( [[item[@"ret"] description] length] == 0 ) {
                // 弹出确认提示框
                FlowSubmitAlert *alert = [[FlowSubmitAlert alloc] init];
                alert.receipts = self.params[@"getmannames"];
                
                if ( [self.params[@"ccmannames"] length] > 0 ) {
                    alert.ccNames = self.params[@"ccmannames"];
                }
                
                __weak typeof(self) weakSelf = self;
                [alert showInView:self.navigationController.view
                     doneCallback:^(FlowSubmitAlert *sender) {
                         [weakSelf sendReq];
                     }];
            } else {
                [self.contentView showHUDWithText:[item[@"ret"] description]
                                           offset:CGPointMake(0, 20)];
            }
        } else {
            [self.contentView showHUDWithText:@"流程业务验证失败" succeed:NO];
        }
    }
}

- (void)sendReq
{
    NSMutableDictionary *params = [[self apiParams] mutableCopy];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    params[@"manid"] = manID;
    params[@"did"] = [self.params[@"did"] description];
    params[@"mid"] = self.params[@"mid"] ?: @"";
    params[@"opinion"] = self.formObjects[@"opinion"] ?: @"";
    params[@"platformtype"] = @"1";
    
    params[@"platformtypec"] = AWDevicePlatformString() ?: @"unknown iPhone";
    
    params[@"annexids"] = [self.attachmentIDs componentsJoinedByString:@","];
    
    NSLog(@"API Params:\n%@", params);
    
    __weak typeof(self) me = self;
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:params completion:^(id result, NSError *error) {
         [me handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        [self.contentView makeToast:error.domain];
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        [self.navigationController.view showHUDWithText:@"处理成功" succeed:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowHandleSuccessNotification" object:nil];
        
        if ( [[self.params[@"action"][@"action"] description] isEqualToString:@"transmit"] ) {
            // 回到表单详情页面
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        UIViewController *vc = [[self.navigationController viewControllers] firstObject];
        if ( [NSStringFromClass([vc class]) isEqualToString:@"LoginVC"] ) {
            [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (NSArray *)formControls
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
    }
    
    [self addControlAtIndexPath:indexPath forCell:cell];
    
    cell.userInteractionEnabled = !self.disableFormInputs;
    
    return cell;
}

- (void)addControlAtIndexPath:(NSIndexPath *)indexPath forCell:(UITableViewCell *)cell
{
    id item = self.dataSource[indexPath.section];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    if ( !label ) {
        label = AWCreateLabel(CGRectMake(15, 8, 100, 34),
                              nil,
                              NSTextAlignmentLeft,
                              nil,
                              [UIColor blackColor]);
        [cell.contentView addSubview:label];
        label.tag = 1001;
        label.adjustsFontSizeToFitWidth = YES;
    }
    label.text = item[@"describe"];
    label.width = 100;
    label.numberOfLines = 1;
    
    [[cell.contentView viewWithTag:1002] removeFromSuperview];
    [[cell.contentView viewWithTag:1003] removeFromSuperview];
    [[cell.contentView viewWithTag:1004] removeFromSuperview];
    
    cell.accessoryView = nil;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger controlType = [item[@"data_type"] integerValue];
    switch (controlType) {
        case FormControlTypeInput:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            CGRect frame = CGRectMake(label.right, label.top,
                                      self.contentView.width - 15 - label.right, label.height);
            
            UITextField *textField = [[UITextField alloc] initWithFrame:frame];
            textField.placeholder = [NSString stringWithFormat:@"请输入%@", item[@"describe"]];
            [cell.contentView addSubview:textField];
            textField.tag = 1002;
            textField.returnKeyType = UIReturnKeyDone;
            textField.tintColor = MAIN_THEME_COLOR;
            
            NSString *key = [item[@"field_name"] description];
            textField.text = [self.formObjects[key] description];
            
            textField.data = item[@"field_name"];
            
            if ([[item[@"item_value"] description] length] > 0 && [item[@"item_value"] integerValue] == 0) {
                textField.enabled = NO;
                textField.textColor = AWColorFromRGB(168, 168, 168);
            } else {
                textField.enabled = YES;
                textField.textColor = [UIColor blackColor];
            }
            
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [textField addTarget:self action:@selector(textFieldBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
            [textField addTarget:self action:@selector(textFieldEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        }
            break;
        case FormControlTypeRadioButton:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSString *key = [item[@"field_name"] description];
            
            RadioButtonGroup *group = [[RadioButtonGroup alloc] init];
            [cell.contentView addSubview:group];
            group.tag = 1002;
            group.frame = CGRectMake(0, 0,
                                     self.contentView.width - 15 - label.right, 40);
            group.position = CGPointMake(label.right + 10, 5);
            
            NSArray *names = [item[@"item_name"] componentsSeparatedByString:@","];
            NSArray *values = [item[@"item_value"] componentsSeparatedByString:@","];
            NSMutableArray *temp = [NSMutableArray array];
            for (int i=0; i<names.count; i++) {
                id name = names[i];
                id val  = values[i];
                
                RadioButton *rb = [[RadioButton alloc] initWithIcon:
                                   [UIImage imageNamed:@"icon_checkbox.png"]
                                    selectedIcon:[UIImage imageNamed:@"icon_checkbox_click.png"] label:name
                                        value:val];
                [temp addObject:rb];
                
                rb.didSelectBlock = ^(RadioButton *sender) {
                    self.formObjects[key] = [(sender.value ?: @"") description];
                    NSString *opinion = self.formObjects[@"opinion"] ?: @"";
                    if ( [sender.value integerValue] != 0 ) {
                        self.formObjects[@"opinion"] = [NSString stringWithFormat:@"%@%@",
                                                        @"同意。", opinion];
                    }
                    
                };
            }
            
            group.radioButtons = temp;
            
            if ( !self.formObjects[key] ) {
                self.formObjects[key] = @"";
            } else {
                group.value = self.formObjects[key];
            }
            
        }
            break;
        case FormControlTypeDate:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            UILabel *detailLabel = AWCreateLabel(CGRectMake(label.right,
                                                            label.top,
                                                            self.contentView.width - 20 - 10 - label.right,
                                                            label.height),
                                                 nil,
                                                 NSTextAlignmentRight,
                                                 nil,
                                                 IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR);
            [cell.contentView addSubview:detailLabel];
            detailLabel.tag = 1002;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                NSDate *date = self.formObjects[key];
                
                static NSDateFormatter *df = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    df = [[NSDateFormatter alloc] init];
                    df.dateFormat = @"yyyy-MM-dd";
                });
                
                detailLabel.text = [df stringFromDate:date];
            } else {
                detailLabel.text = [NSString stringWithFormat:@"设置%@", item[@"describe"]];
            }
        }
            break;
        case FormControlTypeRadio:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            UILabel *detailLabel = AWCreateLabel(CGRectMake(label.right,
                                                            label.top,
                                                            self.contentView.width - 20 - 10 - label.right,
                                                            label.height),
                                                 nil,
                                                 NSTextAlignmentRight,
                                                 nil,
                                                 IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR);
            [cell.contentView addSubview:detailLabel];
            detailLabel.tag = 1002;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                id currentItem = self.formObjects[key];
                detailLabel.text = currentItem[@"name"];
            } else {
                detailLabel.text = [NSString stringWithFormat:@"选择%@", item[@"describe"]];
            }
        }
            break;
        case FormControlTypeSwitch:
        case FormControlTypeSwitch2:
        {
            //            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UISwitch *onOff = [[UISwitch alloc] init];
            cell.accessoryView = onOff;
//            onOff.on = YES;
            onOff.onTintColor = MAIN_THEME_COLOR;
            
            label.width = self.contentView.width - 60;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                onOff.on = [self.formObjects[key] boolValue];
            } else {
                if (controlType == FormControlTypeSwitch) {
                    // 审批要素，默认为NO
                    self.formObjects[key] = @"0";
                    
                    onOff.on = NO;
                } else {
                    self.formObjects[key] = @"0";
                    
                    onOff.on = NO;
                }
                
            }
            
            if ( controlType == FormControlTypeSwitch2 ) {
                NSString *prefix = @"";
                if ( !onOff.on ) {
                    prefix = @"不";
                }
                label.text = [NSString stringWithFormat:@"%@%@", prefix, item[@"describe"]];
            } else {
                label.text = [item[@"describe"] description];
            }
            
            onOff.userData = item;
            
//            onOff.tag = 10000 + indexPath.section;
            
            [onOff addTarget:self action:@selector(onOffChange:) forControlEvents:UIControlEventValueChanged];
            
        }
            break;
        case FormControlTypeSelect:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            UILabel *detailLabel = AWCreateLabel(CGRectMake(label.right,
                                                            label.top,
                                                            self.contentView.width - 20 - 10 - label.right,
                                                            label.height),
                                                 nil,
                                                 NSTextAlignmentRight,
                                                 nil,
                                                 IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR);
            [cell.contentView addSubview:detailLabel];
            detailLabel.tag = 1002;
            detailLabel.numberOfLines = 0;
            
            detailLabel.adjustsFontSizeToFitWidth = YES;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                id currentItem = self.formObjects[key];
                detailLabel.text = currentItem[@"name"];
            } else {
                detailLabel.text = [NSString stringWithFormat:@"选择%@", item[@"describe"]];
                
                // 特殊处理
                if ( [key isEqualToString:@"backdid"] ) {
                    detailLabel.text = @"选择节点";
                }
            }
            
//            detailLabel.text = [NSString stringWithFormat:@"选择%@", item[@"describe"]];
        }
            break;
        case FormControlTypeAddContact:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            CGRect frame = CGRectMake(label.right,
                                      label.top,
                                      self.contentView.width - label.right,
                                      label.height);
            UIView *inputContainer = [[UIView alloc] initWithFrame:frame];
            inputContainer.tag = 1003;
            [cell.contentView addSubview:inputContainer];
            
            // 添加按钮
            UIButton *btn = AWCreateImageButton(@"contact_icon_add.png", self, @selector(addContacts:));
            [inputContainer addSubview:btn];
            
            btn.userData = @{ @"type": @"1", @"field_name": item[@"field_name"] ?: @"" };
            btn.center = CGPointMake(inputContainer.width - 5 - btn.width / 2, inputContainer.height / 2);
            
            CGRect btnFrame = CGRectMake(0, 0, btn.left - 5, inputContainer.height);
            UIButton *btn2 = AWCreateTextButton(btnFrame,
                                                @"输入姓名搜索",
                                                AWColorFromRGB(168, 168, 168),
                                                self,
                                                @selector(inputToSearch:));
            [inputContainer addSubview:btn2];
//            btn2.titleLabel.font = AWSystemFontWithSize(15, NO);
            btn2.titleLabel.font = AWSystemFontWithSize(16, NO);
            btn2.titleEdgeInsets = UIEdgeInsetsMake(0, -58, 0, 0);
            btn2.userData = btn.userData;
            
            NSString *key = item[@"field_name"];
            if ( self.formObjects[key] && [self.formObjects[key] count] > 0 ) {
                
                btn2.hidden = YES;
                
                Employ *emp = [self.formObjects[key] firstObject];
                
                UIButton *nameBtn =
                AWCreateTextButton(CGRectZero,
                                   [NSString stringWithFormat:@"%@ ×", emp.name],
                                   IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
                                   self, @selector(removeContact:));
                [cell.contentView addSubview:nameBtn];
                nameBtn.tag = 1002;
                [nameBtn titleLabel].font = AWSystemFontWithSize(15, NO);
                
                nameBtn.userData = @{ @"field_name": key ?: @"", @"employ": emp };
                
                [nameBtn sizeToFit];
                
                nameBtn.cornerRadius = nameBtn.height / 2;
                nameBtn.layer.borderColor = [IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR CGColor];
                nameBtn.layer.borderWidth = 0.5;
                
                nameBtn.width += 20;
                
                nameBtn.center = CGPointMake(label.right + nameBtn.width / 2,
                                                        label.midY);
            } else {
                btn2.hidden = NO;
            }
        }
            break;
        case FormControlTypeAddContacts:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            CGRect frame = CGRectMake(label.right,
                                      label.top,
                                      self.contentView.width - label.right,
                                      label.height);
            UIView *inputContainer = [[UIView alloc] initWithFrame:frame];
            inputContainer.tag = 1003;
            [cell.contentView addSubview:inputContainer];
            
            // 添加按钮
            UIButton *btn = AWCreateImageButton(@"contact_icon_add.png", self, @selector(addContacts:));
            [inputContainer addSubview:btn];
            
            btn.userData = @{ @"type": @"2", @"field_name": item[@"field_name"] ?: @"" };;
            btn.center = CGPointMake(inputContainer.width - 5 - btn.width / 2, inputContainer.height / 2);
            
            // 文本输入框
            CGRect btnFrame = CGRectMake(0, 0, btn.left - 5, inputContainer.height);
            UIButton *btn2 = AWCreateTextButton(btnFrame,
                                                @"输入姓名搜索",
                                                AWColorFromRGB(168, 168, 168),
                                                self,
                                                @selector(inputToSearch:));
            [inputContainer addSubview:btn2];
            btn2.titleLabel.font = AWSystemFontWithSize(16, NO);
            btn2.titleEdgeInsets = UIEdgeInsetsMake(0, -58, 0, 0);
            btn2.userData = btn.userData;
            
            CGFloat startY = inputContainer.bottom;
            NSString *key = item[@"field_name"];
            
            if ( self.formObjects[key] && [self.formObjects[key] count] > 0 ) {
                CGFloat height = [self calcuHeightForContacts:self.formObjects[key]];
                
                UIView *btnContainer = [[UIView alloc] initWithFrame:
                                        CGRectMake(0, startY + 10, self.contentView.width, height)];
                [cell.contentView addSubview:btnContainer];
                btnContainer.tag = 1002;
//                btnContainer.backgroundColor = [UIColor redColor];
                
                NSArray *contacts = self.formObjects[key];
                
                UIButton *lastBtn = nil;
                [self.contactsButtons removeAllObjects];
                
                for (id emp in contacts) {
                    
                    UIButton *nameBtn =
                    AWCreateTextButton(CGRectZero,
                                       [NSString stringWithFormat:@"%@ ×", [emp name]],
                                       IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
                                       self, @selector(removeContact:));
                    [btnContainer addSubview:nameBtn];
                    nameBtn.userData = @{ @"field_name": key ?: @"", @"employ": emp };
                    [self.contactsButtons addObject:nameBtn];
                    
                    [nameBtn titleLabel].font = AWSystemFontWithSize(15, NO);
                    
                    [nameBtn sizeToFit];
                    
                    nameBtn.cornerRadius = nameBtn.height / 2;
                    nameBtn.layer.borderColor = [IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR CGColor];
                    nameBtn.layer.borderWidth = 0.5;
                    
                    nameBtn.width += 20;
                    
                    NSLog(@"btn width: %f", nameBtn.width);
                    
                    if ( !lastBtn ) {
                        nameBtn.center = CGPointMake(15 + nameBtn.width / 2,
                                                     10 + nameBtn.height / 2);
                    } else {
                        CGFloat dtx = lastBtn.right + 5;
                        CGFloat dty = lastBtn.top;
                        
                        if ( dtx + nameBtn.width > self.contentView.width - 15 ) {
                            dtx = 15;
                            dty = lastBtn.bottom + 10;
                        }
                        
                        nameBtn.position = CGPointMake(dtx, dty);
                    }
                    
                    lastBtn = nameBtn;
                }
            }
        }
            break;
        case FormControlTypeDateRange:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            CGRect frame = CGRectMake(0, 0,
                                      self.contentView.width - label.right - 15, label.height);
            UIView *controlContainer = [[UIView alloc] initWithFrame:frame];
            [cell.contentView addSubview:controlContainer];
            controlContainer.tag = 1002;
            controlContainer.center =
                CGPointMake(label.right + controlContainer.width / 2,
                            label.midY);
            
            NSString *splitDesc = [item[@"split_desc"] description];
            
            UILabel *splitDescLabel = AWCreateLabel(
                    CGRectMake(0, 0, 30, controlContainer.height),
                                                    splitDesc,
                                                    NSTextAlignmentCenter,
                                                    AWSystemFontWithSize(14, NO),
                                                    [UIColor blackColor]);
            [controlContainer addSubview:splitDescLabel];
            splitDescLabel.center = CGPointMake(controlContainer.width / 2,
                                                controlContainer.height / 2);
            
            NSArray *subDesc       = [item[@"sub_describe"] componentsSeparatedByString:@","];
            
            if ( subDesc.count != 2 ) {
                return;
            }
            
            CGFloat width = (controlContainer.width - splitDescLabel.width) / subDesc.count;
            
            // 创建按钮
            for (int i=0; i<subDesc.count; i++) {
                CGRect btnFrame = CGRectMake(0, 0, width, controlContainer.height);
                UIButton *btn = AWCreateTextButton(btnFrame,
                                                   subDesc[i],
                                                   IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
                                                   self,
                                                   @selector(openDateControl:));
                [controlContainer addSubview:btn];
                
                btn.tag = i + 1;
                btn.userData = item;
                
                NSString *key = [NSString stringWithFormat:@"%@.%d",
                                 item[@"field_name"], btn.tag];
                
                if ( self.formObjects[key] ) {
                    NSDate *date = self.formObjects[key];
                    static NSDateFormatter *df = nil;
                    static dispatch_once_t onceToken;
                    
                    dispatch_once(&onceToken, ^{
                        df = [[NSDateFormatter alloc] init];
                    });
                    
                    if ( [item[@"picker_mode"] integerValue] == 1 ) {
                        df.dateFormat = @"HH:mm";
                    } else {
                        df.dateFormat = @"yyyy-MM-dd";
                    }
                    
                    [btn setTitle:[df stringFromDate:date] forState:UIControlStateNormal];
                } else {
                    [btn setTitle:subDesc[i] forState:UIControlStateNormal];
                }
                
                btn.titleLabel.font = AWSystemFontWithSize(15, NO);
                
                btn.titleLabel.adjustsFontSizeToFitWidth = YES;
                
                btn.left = ( btn.width + splitDescLabel.width ) * i;
            }
        }
            break;
        case FormControlTypeUpload:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case FormControlTypeOpenFlow:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case FormControlTypeAttendanceException:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            label.text = nil;
            
            NSString *fieldName = item[@"field_name"];
            
//            NSDictionary *values = self.formObjects[fieldName] ?: @{};
            NSString *timeKey = [NSString stringWithFormat:@"%@.time", fieldName];
            NSString *typeKey = [NSString stringWithFormat:@"%@.type", fieldName];
            NSString *descKey = [NSString stringWithFormat:@"%@.desc", fieldName];
            
            CGRect frame = CGRectMake(15, label.top,
                                      self.contentView.width - 30,
                                      102);
            
            UIView *container = [[UIView alloc] initWithFrame:frame];
            container.tag = 1002;
            [cell.contentView addSubview:container];
            
            // 添加异常时间显示
            UILabel *timeLabel = AWCreateLabel(label.frame,
                                               @"异常时间",
                                               NSTextAlignmentLeft,
                                               label.font,
                                               label.textColor);
            [container addSubview:timeLabel];
            
            timeLabel.position = CGPointMake(0, 0);
            
            UILabel *timeValue = AWCreateLabel(label.frame,
                                              nil,
                                              NSTextAlignmentRight,
                                              label.font,
                                              label.textColor);
            [container addSubview:timeValue];
            
            timeValue.position = CGPointMake(timeLabel.right, 0);
            timeValue.width    = container.width - timeLabel.width;
            
            if ( self.formObjects[timeKey] ) {
                NSDate *date = self.formObjects[timeKey];
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                timeValue.text = [NSString stringWithFormat:@"%@",
                                  [df stringFromDate:date]];
            } else {
                timeValue.text = @"选择异常时间";
            }
            
            UIButton *btn = AWCreateImageButton(nil, self, @selector(attendBtnClick:));
            [container addSubview:btn];
            btn.frame = CGRectMake(0, timeValue.top,
                                   container.width, timeValue.height);
            
            btn.userData = @{ @"item": item, @"key": timeKey };
            
            // 选择异常类型
            UILabel *typeLabel = AWCreateLabel(label.frame,
                                               @"异常类型",
                                               NSTextAlignmentLeft,
                                               label.font,
                                               label.textColor);
            [container addSubview:typeLabel];
            
            typeLabel.position = CGPointMake(0, timeLabel.bottom);
            
            UILabel *typeValue = AWCreateLabel(label.frame,
                                               nil,
                                               NSTextAlignmentRight,
                                               label.font,
                                               label.textColor);
            [container addSubview:typeValue];
            
            typeValue.position = CGPointMake(timeLabel.right, timeLabel.bottom);
            typeValue.width    = container.width - timeLabel.width;
            
            if (self.formObjects[typeKey]) {
                typeValue.text = self.formObjects[typeKey][@"name"];
            } else {
                typeValue.text = @"选择异常类型";
            }
            
            btn = AWCreateImageButton(nil, self, @selector(attendBtnClick:));
            [container addSubview:btn];
            btn.frame = CGRectMake(0, typeValue.top,
                                   container.width, typeValue.height);
            
            btn.userData = @{ @"item": item, @"key": typeKey };
            
//            btn.backgroundColor = [UIColor redColor];
            
            typeValue.textColor = timeValue.textColor = AWColorFromRGB(201, 201, 201);
            
            // 添加意见输入框
            UILabel *label2 = AWCreateLabel(
                                            CGRectMake(0, typeValue.bottom + 3,
                                                       label.width, 34),
                                            @"异常说明",
                                            NSTextAlignmentLeft,
                                            label.font,
                                            label.textColor);
            [container addSubview:label2];
            
            // 意见输入框
            UITextField *textField = [[UITextField alloc] initWithFrame:label2.frame];
            textField.placeholder = @"输入异常说明";
            [container addSubview:textField];
            
            textField.width = container.width - label2.right;
            textField.left  = label2.right;
            
            textField.returnKeyType = UIReturnKeyDone;
            textField.tintColor = MAIN_THEME_COLOR;
            
//            NSString *key = [item[@"field_name"] description];
            textField.text = self.formObjects[descKey];
            
            textField.data = descKey;
            
//            if ([[item[@"item_value"] description] length] > 0 && [item[@"item_value"] integerValue] == 0) {
//                textField.enabled = NO;
//                textField.textColor = AWColorFromRGB(168, 168, 168);
//            } else {
//                textField.enabled = YES;
//                textField.textColor = [UIColor blackColor];
//            }
            
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [textField addTarget:self action:@selector(textFieldBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
            [textField addTarget:self action:@selector(textFieldEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
        }
            break;
        case FormControlTypeRelatedAnnex:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            // 相关附件
            UILabel *detailLabel = AWCreateLabel(CGRectMake(label.right,
                                                            label.top,
                                                            self.contentView.width - 20 - 10 - label.right,
                                                            label.height),
                                                 nil,
                                                 NSTextAlignmentLeft,
                                                 nil,
                            AWColorFromRGB(168, 168, 168));
            [cell.contentView addSubview:detailLabel];
            detailLabel.tag = 1002;
            
            detailLabel.adjustsFontSizeToFitWidth = YES;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                NSArray *values = self.formObjects[key];
                detailLabel.text = [NSString stringWithFormat:@"%d个附件", values.count];
            } else {
                detailLabel.text = @"上传附件";
            }
        }
            break;
        case FormControlTypeRelatedFlow:
        {
            // 相关流程
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UILabel *detailLabel = AWCreateLabel(CGRectMake(label.right,
                                                            label.top,
                                                            self.contentView.width - 20 - 10 - label.right,
                                                            label.height),
                                                 nil,
                                                 NSTextAlignmentLeft,
                                                 nil,
                                                 AWColorFromRGB(168, 168, 168));
            [cell.contentView addSubview:detailLabel];
            detailLabel.tag = 1002;
            
//            detailLabel.adjustsFontSizeToFitWidth = YES;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                NSArray *values = self.formObjects[key];
                // { title: '关于XXXXXXX的流程', mid: 123456 }
//                NSMutableArray *temp = [NSMutableArray array];
//                for (id val in values) {
//                    if ([val isKindOfClass:[NSDictionary class]] &&
//                        val[@"title"] ) {
//                        [temp addObject:val[@"title"]];
//                    }
//                }
//                detailLabel.text = [temp componentsJoinedByString:@","];
                detailLabel.text = [NSString stringWithFormat:@"%d个流程", values.count];
            } else {
                detailLabel.text = @"设置相关流程";
            }
        }
            break;
        case FormControlTypeRequestReply:
        {
            // 请示批复
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            // 意见操作
            CGRect frame = CGRectMake(15, label.bottom,
                                      self.contentView.width - 30,
                                      68);
            
            UIView *container = [[UIView alloc] initWithFrame:frame];
            [cell.contentView addSubview:container];
            container.tag = 1002;
            
            NSString *agreeKey = [NSString stringWithFormat:@"%@.agree",
                                  item[@"field_name"]];
            // 是否同意
            UILabel *agreeLabel = AWCreateLabel(CGRectMake(0, 0, label.width, 34),
                                                @"是否同意",
                                                NSTextAlignmentLeft,
                                                label.font,
                                                label.textColor);
            [container addSubview:agreeLabel];
            
            // 单选按钮
            RadioButtonGroup *group = [[RadioButtonGroup alloc] init];
            [container addSubview:group];
            group.frame = CGRectMake(agreeLabel.right, 0,
                                     container.width - 15 - agreeLabel.right, 34);
            NSArray *options = @[@{
                                     @"name": @"同意",
                                     @"value": @"1",
                                     },
                                 @{
                                     @"name": @"不同意",
                                     @"value": @"0",
                                     },
                                 ];
            NSMutableArray *temp = [NSMutableArray array];
            for (int i=0; i<options.count; i++) {
                id name = options[i][@"name"];
                id val  = options[i][@"value"];
                
                RadioButton *rb = [[RadioButton alloc] initWithIcon:
                                   [UIImage imageNamed:@"icon_checkbox.png"]
                                                       selectedIcon:[UIImage imageNamed:@"icon_checkbox_click.png"] label:name
                                                              value:val];
                [temp addObject:rb];
                
                rb.didSelectBlock = ^(RadioButton *sender) {
                    self.formObjects[agreeKey] = [(sender.value ?: @"") description];
                    
                };
            }
            
            group.radioButtons = temp;
            
            if ( !self.formObjects[agreeKey] ) {
                self.formObjects[agreeKey] = @"";
            } else {
                group.value = self.formObjects[agreeKey];
            }
            
            // 添加意见输入框
            UILabel *label2 = AWCreateLabel(
                                            CGRectMake(0, agreeLabel.bottom + 3,
                                                       label.width, 34),
                                            @"批复意见",
                                            NSTextAlignmentLeft,
                                            label.font,
                                            label.textColor);
            [container addSubview:label2];
            
            // 意见输入框
            UITextField *textField = [[UITextField alloc] initWithFrame:label2.frame];
            textField.placeholder = @"输入意见";
            [container addSubview:textField];
            
            textField.width = container.width - label2.right;
            textField.left  = label2.right;
            
            textField.returnKeyType = UIReturnKeyDone;
            textField.tintColor = MAIN_THEME_COLOR;
            
            NSString *key = [item[@"field_name"] description];
            textField.text = self.formObjects[key];
            
            textField.data = item[@"field_name"];
            
            if ([[item[@"item_value"] description] length] > 0 && [item[@"item_value"] integerValue] == 0) {
                textField.enabled = NO;
                textField.textColor = AWColorFromRGB(168, 168, 168);
            } else {
                textField.enabled = YES;
                textField.textColor = [UIColor blackColor];
            }
            
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [textField addTarget:self action:@selector(textFieldBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
            [textField addTarget:self action:@selector(textFieldEndEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            // 更新label的宽度
            label.width = self.contentView.width - 20;
            label.numberOfLines = 2;
            
        }
            break;
        case FormControlTypeTextArea:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            CGRect frame = CGRectMake(label.right,
                                      label.top,
                                      self.contentView.width - 15 - label.right,
                                      120);
            
            UITextView *textView = [[UITextView alloc] initWithFrame:frame];
            textView.tag = 1002;
            [cell.contentView addSubview:textView];
//            textView.backgroundColor = [UIColor redColor];
            textView.font = [UIFont systemFontOfSize:16];
            self.textView = textView;
            
            textView.tintColor = MAIN_THEME_COLOR;
            
            textView.delegate = self;
            
            NSString *key = [item[@"field_name"] description];
            if ( self.formObjects[key] ) {
                textView.placeholder = nil;
                textView.text = self.formObjects[key];
            } else {
                textView.text = nil;
                textView.placeholder = [NSString stringWithFormat:@"输入%@", item[@"describe"]];//@"输入签字意见";
            }
            
            textView.placeholderAttributes = @{ NSFontAttributeName: textView.font ?: [UIFont systemFontOfSize:16] };
            
            // 常用意见
            UIButton *opinionBtn = nil;
            if ( [self supportsCustomOpinion] ) {
                opinionBtn = AWCreateTextButton(
                                                          CGRectMake(self.contentView.width - 15 - 60,
                                                                     textView.bottom + 5,
                                                                     60,
                                                                     30),
                                                          @"常用意见",
                                                          IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
                                                          self, @selector(showOpinion:));
                opinionBtn.tag = 1003;
                [cell.contentView addSubview:opinionBtn];
                opinionBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
            }
            
            // 上传附件
            if ( [self supportsAttachment] ) {
                FAKIonIcons *attachIcon = [FAKIonIcons androidAttachIconWithSize:20];
                [attachIcon addAttributes:@{ NSForegroundColorAttributeName: IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR }];
                UIButton *attachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [cell.contentView addSubview:attachBtn];
                [attachBtn setImage:[attachIcon imageWithSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
                attachBtn.frame = CGRectMake(self.contentView.width - 40, textView.bottom,
                                             35, 35);
                [attachBtn addTarget:self
                              action:@selector(uploadAttachment:) forControlEvents:UIControlEventTouchUpInside];
//                attachBtn.userData = @"opinion.";
                attachBtn.backgroundColor = [UIColor clearColor];
                attachBtn.tag = 1004;
                
                opinionBtn.left = attachBtn.left - 5 - opinionBtn.width;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)attendBtnClick:(UIButton *)sender
{
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
    
    NSString *key = sender.userData[@"key"];
    id item = sender.userData[@"item"];
    
    if ( [key hasSuffix:@"type"] ) {
        // 异常类型
        SelectPicker *picker = [[SelectPicker alloc] init];
        picker.frame = self.contentView.bounds;
        //            picker.backgroundColor = [UIColor redColor];
        
        NSArray *names = [item[@"item_name"] componentsSeparatedByString:@","];
        NSArray *values = [item[@"item_value"] componentsSeparatedByString:@","];
        NSUInteger count = MIN(names.count, values.count);
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i=0; i<count; i++) {
            if ([names[i] length] > 0) {
                id pair = @{ @"name": names[i],
                             @"value": values[i]
                             };
                [temp addObject:pair];
            }
        }
        
        picker.options = [temp copy];
        picker.currentSelectedOption = self.formObjects[key];
        [picker showPickerInView:self.contentView];
        
        __weak typeof(self) me = self;
        picker.didSelectOptionBlock = ^(SelectPicker *sender, id selectedOption, NSInteger index) {
            me.formObjects[key] = selectedOption;
            [me.tableView reloadData];
            
//            NSString *sel = item[@"change_action"];
//            if ( [self respondsToSelector:NSSelectorFromString(sel)] ) {
//                [self performSelector:NSSelectorFromString(sel)
//                           withObject:selectedOption
//                           afterDelay:.1];
//            }
        };
        
    } else if ( [key hasSuffix:@"time"] ) {
        // 异常时间
        DatePicker *picker = [[DatePicker alloc] init];
        picker.frame = self.contentView.bounds;
        [picker showPickerInView:self.contentView];
        picker.currentSelectedDate = self.formObjects[key] ?: [NSDate date];
        
        picker.pickerMode = DatePickerModeDateTime;
        
        __weak typeof(self) me = self;
        picker.didSelectDateBlock = ^(DatePicker *picker, NSDate *selectedDate) {
            me.formObjects[key] = selectedDate;
            [me.tableView reloadData];
        };
    }
}

- (void)inputToSearch:(UIButton *)sender
{
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
    
    id userData = sender.userData;
    
    AddContactsModel *model = [self contactModelForFieldName:userData[@"field_name"]];
    [EmploySearchVC showInPage:self params:@{ @"oper_type": @([userData[@"type"] integerValue]),
                                              @"contacts.model": model,
                                              @"title": @"输入姓名搜索",
                                              @"is_just_remove": @"1",
                                              }];
    
}

- (void)openDateControl:(UIButton *)sender
{
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
    
    NSString *key = [NSString stringWithFormat:@"%@.%d",
                     [sender userData][@"field_name"], sender.tag];
    
    DatePicker *picker = [[DatePicker alloc] init];
    picker.frame = self.contentView.bounds;
    [picker showPickerInView:self.contentView];
    picker.currentSelectedDate = self.formObjects[key] ?: [NSDate date];
    
    if ( [sender userData][@"picker_mode"] ) {
        picker.pickerMode = [[sender userData][@"picker_mode"] integerValue];
    }
    
    if ( [sender userData][@"minute_interval"] ) {
        picker.minuteInterval = [[sender userData][@"minute_interval"] integerValue];
    }
    
    __weak typeof(self) me = self;
    picker.didSelectDateBlock = ^(DatePicker *picker, NSDate *selectedDate) {
        
        BOOL canSetDate = YES;
        
        NSDate *lastDate;
        NSDate *firstDate;
        if ( sender.tag == 1 ) {
            // 设置开始日期
            NSString *lastDateKey  =
            [NSString stringWithFormat:@"%@.2",(sender.userData)[@"field_name"]];
            lastDate  = me.formObjects[lastDateKey];
            if ( lastDate && [lastDate compare:selectedDate] == NSOrderedAscending ) {
                canSetDate = NO;
            }
        } else if ( sender.tag == 2 ) {
            // 设置截止日期
            NSString *firstDateKey =
            [NSString stringWithFormat:@"%@.1",(sender.userData)[@"field_name"]];
            firstDate = self.formObjects[firstDateKey];
            
            if ( firstDate && [selectedDate compare:firstDate] == NSOrderedAscending ) {
                canSetDate = NO;
            }
        } else {
            canSetDate = NO;
        }
        
        if ( canSetDate == NO ) {
            NSArray *desc = [[sender userData][@"sub_describe"] componentsSeparatedByString:@","];
            NSString *msg = [NSString stringWithFormat:@"%@不能小于%@",
                             [desc lastObject],
                             [desc firstObject]];
            [self.contentView showHUDWithText:msg offset:CGPointMake(0, 20)];
        } else {
            me.formObjects[key] = selectedDate;
            [me.tableView reloadData];
        }
    };
}

- (void)cancelUpload
{
    [self.uploadOperation cancel];
    self.uploadOperation = nil;
}

- (void)uploadAttachment:(UIButton *)sender
{
    self.currentAttachmentFormControl = nil;
    [self uploadAttachmentForFieldName:nil];
}

- (void)uploadAttachmentForFieldName:(NSString *)fieldName
{
    self.currentAttachmentFieldName = fieldName;
    
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"从相册选择"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self selectMedia];
                                                         }];
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:@"拍照"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self takePhoto];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    UIAlertController *actionCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionCtrl addAction:takeAction];
    [actionCtrl addAction:selectAction];
    [actionCtrl addAction:cancelAction];
    
    [self presentViewController:actionCtrl animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"info: %@", info);

    NSData   *fileData = nil;
    NSString *fileName = nil;
    NSString *mimeName = nil;

    NSString *mediaType = [info[UIImagePickerControllerMediaType] description];
    if ( [mediaType isEqualToString:@"public.movie"] ) {
        fileData = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];
        fileName = @"file.mov";
        mimeName = @"video/mp4";
        
        if ( fileData ) {
            [self uploadData:fileData fileName:fileName mimeType:mimeName];
        }
        
    } else if ( [mediaType isEqualToString:@"public.image"] ) {
        fileData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 1.0);//UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]);
        fileName = @"image.png";
        mimeName = @"image/png";
        
        if ( fileData ) {
            id image = @{
                         @"imageData": fileData,
                         @"imageName": @"IMG_0001.PNG"
                         };
            [self uploadImages:@[image] mimeType:mimeName];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadData:(NSData *)fileData
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
{
    [self uploadFile:@{}
       formDataBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           [formData appendPartWithFileData:fileData
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:mimeType];
       }];
}

- (void)handleAnnexUploadSuccess:(id)responseObject
{
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
    [self.contentView showHUDWithText:@"附件上传成功" succeed:YES];
    
    NSArray *IDs = [responseObject[@"IDS"] componentsSeparatedByString:@","];
    
    if ( IDs ) {
        [self.attachmentIDs addObjectsFromArray:IDs];
    }
    
    if ( self.currentAttachmentFieldName && IDs ) {
        NSArray *ids = self.formObjects[self.currentAttachmentFieldName] ?: @[];
        NSMutableArray *temp = [ids mutableCopy];
        [temp addObjectsFromArray:IDs];
        
        self.formObjects[self.currentAttachmentFieldName] = temp;
        
        [self.tableView reloadData];
    }
    
    NSLog(@"response: %@", responseObject);
}

- (void)selectMedia
{
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        [self authAndOpenPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        [self showAlertWithTitle:@"当前设备不支持拍照"];
    }
}

+ (void)getVideoFromPHAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSString *filename))result
{
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        if ( assetRes.type == PHAssetResourceTypePairedVideo ||
             assetRes.type == PHAssetResourceTypeVideo ) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    if (asset.mediaType == PHAssetMediaTypeVideo ||
        asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive ) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:
         [NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:
         ^(NSError * _Nullable error)
        {
            if (error) {                                                                  result(nil, nil);
            } else {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:PATH_MOVIE_FILE]];                                                                  result(data, fileName);
            }
            [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE
                                                       error:nil];                                                          }];
    } else {
        result(nil, nil);
    }
}

+ (void)getImageFromPHAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSString *filename) ) result {
    __block NSData *data;
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             data = [NSData dataWithData:imageData];
         }];
    }
    
    if (result) {
        if (data.length <= 0) {
            result(nil, nil);
        } else {
            result(data, resource.originalFilename);
        }
    }
}

- (void)uploadFile:(NSDictionary *)params
     formDataBlock:( void (^)(id<AFMultipartFormData>  _Nonnull formData) )formDataBlock
{
    [self cancelUpload];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [[MBProgressHUD appearance] setContentColor:MAIN_THEME_COLOR];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.progress = 0.0f;
    hud.label.text = @"上传中...";
    
    NSString *tableName = @"H_WF_Inst_Opinion";
    NSString *fieldname = @"Audit_Annex";
    NSString *mid = self.params[@"mid"] ?: @"0";
    if (self.currentAttachmentFormControl) {
//        id val = self.formObjects[self.currentAttachmentFieldName];
        NSArray *temp = [self.currentAttachmentFormControl[@"item_value"] componentsSeparatedByString:@","];
        if ( [temp firstObject] ) {
            tableName = [temp firstObject];
        }
        
        if ([temp lastObject]) {
            fieldname = [temp lastObject];
        }
        
        mid = @"";
    }
    
    __weak typeof(self) weakSelf = self;
    NSString *uploadUrl = UPLOAD_URL;//[NSString stringWithFormat:@"%@/upload", API_HOST];
    self.uploadOperation =
    [[AFHTTPRequestOperationManager manager] POST:uploadUrl
                                       parameters:@{
                                                    @"mid": mid,
                                                    @"domanid": manID,
                                                    @"tablename": tableName,
                                                    @"fieldname": fieldname,
                                                    }
                        constructingBodyWithBlock:formDataBlock
                                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
     {
         [weakSelf handleAnnexUploadSuccess:responseObject];
     }
     
                                          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
     {
         //
         NSLog(@"error: %@",error);
         [MBProgressHUD hideHUDForView:self.contentView animated:YES];
         [self.contentView showHUDWithText:@"附件上传失败" succeed:NO];
     }];
    [self.uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"%f", totalBytesWritten / (float)totalBytesExpectedToWrite);
        hud.progress = totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];

}

- (void)uploadImages:(NSArray *)images mimeType:(NSString *)mimeType
{
    [self uploadFile:@{}
       formDataBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           for (id image in images) {
               [formData appendPartWithFileData:image[@"imageData"]
                                           name:@"file"
                                       fileName:image[@"imageName"]
                                       mimeType:mimeType];
               
           }
       }];
}

- (void)takePhoto
{
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [self authAndOpenPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self showAlertWithTitle:@"当前设备不支持拍照"];
    }
}

- (void)authAndOpenPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( granted ) {
                            [self openPickerWithSourceType:sourceType];
                        } else {
                            [self showAlertForSourceType:sourceType];
                        }
                    });
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied:
            {
                [self showAlertForSourceType:sourceType];
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                [self openPickerWithSourceType:sourceType];
            }
                break;
                
            default:
                break;
        }
        
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
            {
                // 请求授权
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( status == PHAuthorizationStatusAuthorized ) {
                            [self openPickerWithSourceType:sourceType];
                        } else {
                            [self showAlertForSourceType:sourceType];
                        }
                    });
                }];
            }
                break;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
            {
                [self showAlertForSourceType:sourceType];
            }
                break;
            case PHAuthorizationStatusAuthorized:
            {
                [self openPickerWithSourceType:sourceType];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)showAlertForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    NSString *message = nil;
    NSString *url     = nil;
    
    if ( sourceType == UIImagePickerControllerSourceTypeCamera ) {
        message = @"“合能地产”需要获得访问相机的权限";
        url = @"App-Prefs:root=Privacy&path=CAMERA";
    } else {
        message = @"“合能地产”需要获得访问照片的权限";
        url = @"App-Prefs:root=Privacy&path=PHOTOS";
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    UIAlertAction *okAction   = [UIAlertAction actionWithTitle:@"设置"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                                       }];
    UIAlertController *alertCtrl =
    [UIAlertController alertControllerWithTitle:@"需要权限"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:cancelAction];
    [alertCtrl addAction:okAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)openPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if ( sourceType == UIImagePickerControllerSourceTypeCamera ) {
        self.imagePicker.sourceType = sourceType;
        
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
        
        self.imagePicker.videoMaximumDuration = 30;
        self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    } else {
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
        
        imagePickerVC.allowTakePicture  = NO;
        imagePickerVC.allowPickingVideo = YES;
        imagePickerVC.allowPickingImage = YES;
        imagePickerVC.allowPickingOriginalPhoto = YES;
        
        imagePickerVC.didFinishPickingPhotosHandle = ^( NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto ) {
            NSLog(@"photos: %@, assets: %@, origin: %d", photos, assets, isSelectOriginalPhoto);
            //        [self uploadImages:photos mimeType:@"image/png"];
            NSMutableArray *tempArray = [NSMutableArray array];
            for (id asset in assets) {
                if ( [asset isKindOfClass:[PHAsset class]] ) {
                    [[self class] getImageFromPHAsset:asset completion:^(NSData *data, NSString *filename) {
                        if ( data && filename ) {
                            [tempArray addObject:@{ @"imageData": data,
                                                    @"imageName": filename
                                                    }];
                        }
                    }];
                }
            }
            
            [self uploadImages:tempArray mimeType:@"image/png"];
        };
        
        imagePickerVC.didFinishPickingVideoHandle = ^(UIImage *coverImage,id asset) {
            NSLog(@"coverImage: %@, asset: %@", coverImage, asset);
            if ( [asset isKindOfClass:[PHAsset class]] ) {
                PHAsset *movAsset = (PHAsset *)asset;
                [[self class] getVideoFromPHAsset:movAsset completion:^(NSData *data, NSString *filename) {
                    [self uploadData:data fileName:filename mimeType:@"video/mp4"];
                }];
            }
            //        [self uploadData: fileName:@"file.mov" mimeType:@"video/mp4"];
        };
        
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

- (void)showAlertWithTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
}

- (void)showOpinion:(UIButton *)sender
{
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
    
    if ( self.opinions.count == 0 ) {
        [self.contentView showHUDWithText:@"没有常用意见" offset:CGPointMake(0, 20)];
        return;
    }
    
    self.opinionView.superview.hidden = NO;
    
    self.opinionView.opinions = self.opinions;
    [self.opinionView reloadData];
    
    CGRect frame = [self.tableView convertRect:sender.superview.superview.frame toView:self.contentView];
    self.opinionView.position =
        CGPointMake(self.contentView.width - 35 - self.opinionView.width,
                    CGRectGetMaxY(frame) - 35 - self.opinionView.height);
}

- (void)onOffChange:(UISwitch *)onOff
{
    id item = onOff.userData;
    
    NSString *key = item[@"field_name"];
    
    NSInteger controlType = [item[@"data_type"] integerValue];
    if ( controlType == FormControlTypeRequestReply ) {
        key = [NSString stringWithFormat:@"%@.agree", key];
    }
    
    self.formObjects[key] = onOff.isOn ? @"1" : @"0";
    
    [self.tableView reloadData];
    
//    self.formObjects[item[@"field_name"]]
//    NSInteger index = onOff.tag - 10000;
//    if ( index < [self.dataSource count] ) {
//        id item = self.dataSource[index];
//        
//        self.formObjects[item[@"field_name"]] = onOff.isOn ? @"1" : @"0";
//        
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//        
//        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
//        
//        NSInteger controlType = [item[@"data_type"] integerValue];
//        if ( controlType == FormControlTypeSwitch2 ) {
//            NSString *prefix = @"";
//            if ( !onOff.isOn ) {
//                prefix = @"不";
//            }
//            label.text = [NSString stringWithFormat:@"%@%@", prefix, item[@"describe"]];
//        } else {
//            label.text = [item[@"describe"] description];
//        }
//    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    self.formObjects[[textField.data description]] = textField.text;
    
//    self.firstResponder = textField;
}

- (void)textFieldBeginEdit:(UITextField *)textField
{
    self.firstResponder = textField;
}

- (void)textFieldEndEdit:(UITextField *)textField
{
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.firstResponder = textView;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.formObjects[@"opinion"] = textView.text;
}

- (void)removeSingleContact:(UIButton *)sender
{
    [sender removeFromSuperview];
    
    [self.formObjects removeObjectForKey:@"contact"];
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource[indexPath.section];
    NSLog(@"section: %d, %@", indexPath.section, item);
    int controlType = [item[@"data_type"] integerValue] - 1;
    CGFloat height = ControlHeights[controlType];
    if ( height == 0 ) {
        // 动态计算
        if ([item[@"data_type"] integerValue] == FormControlTypeAddContacts) {
            NSString *key = item[@"field_name"];
            NSArray *contacts = self.formObjects[key];
            if ( [contacts count] == 0 ) {
                return 50;
            }
            return 50 + [self calcuHeightForContacts:contacts] + 20;
        } else {
            return 50;
        }
    } else {
        return height;
    }
}

- (CGFloat)calcuHeightForContacts:(NSArray *)contacts
{
    CGFloat totalWidth = 0;
    int n = 1;
    for (id item in contacts) {
        CGSize size = [[NSString stringWithFormat:@"%@ ×",[item name]] sizeWithAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }];
        
        NSLog(@"size.width: %f", ceil(size.width) + 20);
        totalWidth += (ceil(size.width) + 20 + 5);
        NSLog(@"total.width: %f", totalWidth);
        
//        if ( totalWidth > (self.contentView.width - 25) * n ) {
//            n++;
//        }
        
        if ( totalWidth > self.contentView.width - 30 + 5 ) { // 左右间距为15，每一行宽度累加，多加了间距5，所以要去掉
            n++;
            totalWidth = (ceil(size.width) + 20 + 5);
        }
        
    }
    
    if ( contacts.count == 0 ) {
        n = 0;
    }
    
    return n * 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
    
    id item = self.dataSource[indexPath.section];
    NSInteger controlType = [item[@"data_type"] integerValue];
    switch (controlType) {
        case FormControlTypeDate:
        {
            DatePicker *picker = [[DatePicker alloc] init];
            picker.frame = self.contentView.bounds;
            [picker showPickerInView:self.contentView];
            picker.currentSelectedDate = self.formObjects[item[@"field_name"]] ?: [NSDate date];
            
            NSString *values = [item[@"item_value"] description];
            if ( values.length > 0 ) {
                NSArray *distValues = [values componentsSeparatedByString:@","];
                if ( distValues.count == 2 ) {
                    NSInteger firstVal = [[distValues firstObject] integerValue];
                    NSInteger lastVal  = [[distValues lastObject] integerValue];
                    
                    NSDate *now = [NSDate date];
                    NSDate *minDate = [now dateByAddingTimeInterval:firstVal * 24 * 3600];
                    NSDate *maxDate = [now dateByAddingTimeInterval:lastVal * 24 * 3600];
                    
                    picker.minimumDate = minDate;
                    picker.maximumDate = maxDate;
                } else {
                    //
                    NSInteger firstVal = [[distValues firstObject] integerValue];
                    
                    NSDate *now = [NSDate date];
                    NSDate *minDate = [now dateByAddingTimeInterval:firstVal * 24 * 3600];
                    picker.minimumDate = minDate;
                }
            }
            
            __weak typeof(self) me = self;
            picker.didSelectDateBlock = ^(DatePicker *sender, NSDate *selectedDate) {
                me.formObjects[item[@"field_name"]] = selectedDate;
                [me.tableView reloadData];
            };
        }
            break;
        case FormControlTypeRadio:
        case FormControlTypeSelect:
        {
            SelectPicker *picker = [[SelectPicker alloc] init];
            picker.frame = self.contentView.bounds;
            //            picker.backgroundColor = [UIColor redColor];
            
            NSArray *names = [item[@"item_name"] componentsSeparatedByString:@","];
            NSArray *values = [item[@"item_value"] componentsSeparatedByString:@","];
            NSUInteger count = MIN(names.count, values.count);
            NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:count];
            for (int i=0; i<count; i++) {
                if ([names[i] length] > 0) {
                    id pair = @{ @"name": names[i],
                                 @"value": values[i]
                                 };
                    [temp addObject:pair];
                }
            }
            
//            [temp insertObject:@{ @"name": @"请选择",
//                                  @"value": @"-1"
//                                  } atIndex:0];
            picker.options = [temp copy];
            picker.currentSelectedOption = self.formObjects[item[@"field_name"]];
            [picker showPickerInView:self.contentView];
            
            __weak typeof(self) me = self;
            picker.didSelectOptionBlock = ^(SelectPicker *sender, id selectedOption, NSInteger index) {
                me.formObjects[item[@"field_name"]] = selectedOption;
                [me.tableView reloadData];
                
                NSString *sel = item[@"change_action"];
                if ( [self respondsToSelector:NSSelectorFromString(sel)] ) {
                    [self performSelector:NSSelectorFromString(sel)
                               withObject:selectedOption
                               afterDelay:.1];
                }
            };
        }
            break;
        
        case FormControlTypeRelatedAnnex:
        {
            self.currentAttachmentFormControl = item;
            [self uploadAttachmentForFieldName:item[@"field_name"]];
        }
            break;
            
        case FormControlTypeRelatedFlow:
        {
            NSArray *flows = self.formObjects[item[@"field_name"]];
            if ([flows count] > 0) {
                // 直接打开选择的相关流程列表
                [self openSelectedRelatedFlows:item[@"field_name"]];
            } else {
//                [self searchFlow:item[@"field_name"]];
                [self openOAVCWithFieldName:item[@"field_name"]];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)openSelectedRelatedFlows:(NSString *)fieldName
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"RelatedFlowListVC" params:@{ @"field_name": fieldName ?: @"related_flow", @"flows": self.formObjects[fieldName] ?: @[] }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openOAVCWithFieldName:(NSString *)fieldName
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OAListVC" params:@{ @"from": fieldName ?: @"related_flow" }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)searchFlow:(NSString *)fieldName
{
//    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"FlowSearchVC" params:@{ @"field_name": fieldName ?: @"related_flow" }];
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"FlowSearchVC" params:@{ @"field_name": fieldName ?: @"related_flow", @"flows": self.formObjects[fieldName] ?: @[] }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateFlows:(NSNotification *)sender
{
    id data = sender.object;
    
//    NSArray *flows = self.formObjects[data[@"field_name"]] ?: @[];
//    NSMutableArray *temp = [flows mutableCopy];
//    
//    [temp addObject:@{ @"title": data[@"data"][@"flow_desc"] ?: @"",
//                       @"mid": data[@"data"][@"mid"] ?: @"0" }];
    
    self.formObjects[data[@"field_name"]] = data[@"flows"] ?: @[];
    
    [self.tableView reloadData];
}

- (void)addFlow:(NSNotification *)sender
{
    id data = sender.object;
    
    NSString *key = [data[@"field_name"] description];
    
    NSMutableArray *temp = [self.formObjects[key] ?: @[] mutableCopy];
    
    id item = @{ @"title": data[@"flow"][@"flow_desc"] ?: @"", @"mid": data[@"flow"][@"mid"] ?: @"" };
    if ( [temp containsObject:item] ) {
        
        [AWAppWindow() showHUDWithText:@"您已经选择了此流程，不能重复选择"
                                offset:CGPointMake(0, 20)];
        
        return;
    }
    
    [temp addObject:item];
    
    self.formObjects[key] = temp;
    
    [self.tableView reloadData];
    
    [self.navigationController popToViewController:self animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    self.contentInsets = UIEdgeInsetsZero;
    [self.firstResponder resignFirstResponder];
    self.firstResponder = nil;
}

- (NSDictionary *)apiParams
{
    //    mid(流程ID值), manid(操作人员ID), audit(审批要素)
//    return @{
//             @"dotype": @"flow",
//             @"type": @"submit",
//             @"manid": self.manId,
//             @"mid": self.params[@"mid"],
//             @"audit": @{},
//             };
    return nil;
}

- (void)removeContact:(UIButton *)sender
{
    id userData = sender.userData;
    if ( [userData isKindOfClass:[NSDictionary class]] ) {
        NSString *fieldName = userData[@"field_name"];
        id emp = userData[@"employ"];
        
        // 移除表单数据
        id object = self.formObjects[fieldName];
        if ( [object isKindOfClass:[NSArray class]] ) {
            
            // 移除表字段数据
            NSMutableArray *tempContacts = [self.formObjects[fieldName] mutableCopy];
            [tempContacts removeObject:emp];
            
            self.formObjects[fieldName] = [tempContacts copy];
            
            // 移除按钮
            [sender removeFromSuperview];
            
            // 更新选中的模型数据
            AddContactsModel *model = [self contactModelForFieldName:fieldName];
            model.selectedPeople = self.formObjects[fieldName] ?: @[];
            
            // 刷新表视图
            [self.tableView reloadData];
        }
        
    }
}

- (void)addContacts:(UIButton *)sender
{
    [self hideKeyboard];
    
    NSDictionary *userData = sender.userData;
    
    NSString *fieldName = [userData[@"field_name"] description];
    AddContactsModel *model = [self contactModelForFieldName:fieldName];
    
    UIViewController *vc =
    [[AWMediator sharedInstance] openNavVCWithName:@"SelectContactVC"
                                            params:@{ @"oper_type": @([userData[@"type"] integerValue]),
                                                      @"contacts.model": model,
                                                      @"title": @"选择联系人",
                                                      }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)contactsDidAdd:(NSNotification *)noti
{
    id userData = noti.object;
    if ( [userData isKindOfClass:[AddContactsModel class]] ) {
        AddContactsModel *model = (AddContactsModel *)userData;
        
        self.formObjects[model.fieldName] = model.selectedPeople ?: @[];
        
        [self.tableView reloadData];
    }
}

- (CustomOpinionView *)opinionView
{
    if ( !_opinionView ) {
        _opinionView = [[CustomOpinionView alloc] init];
//        _opinionView.opinions = @[@"同意", @"已阅"];
//        [_opinionView reloadData];
        
        __weak typeof(self) weakSelf = self;
        _opinionView.didSelectOpinionBlock = ^(CustomOpinionView *sender, NSString *opinion) {
            weakSelf.textView.placeholder = @"";
            weakSelf.textView.text = opinion;
            
            weakSelf.formObjects[@"opinion"] = opinion;
            
            [sender.superview removeFromSuperview];
            
            _opinionView = nil;
        };
        
        HNTouchView *view = [[HNTouchView alloc] initWithFrame:self.contentView.bounds];
        
        __weak HNTouchView *weakView = view;
        [self.contentView addSubview:view];
        view.didTouchBlock = ^{
            [weakView removeFromSuperview];
            _opinionView = nil;
        };
        
        [view addSubview:_opinionView];
        
        view.hidden = YES;
    }
    
    return _opinionView;
}

- (NSMutableDictionary *)contactModels
{
    if ( !_contactModels ) {
        _contactModels = [[NSMutableDictionary alloc] init];
    }
    return _contactModels;
}

- (AddContactsModel *)contactModelForFieldName:(NSString *)fieldName
{
    if ( !fieldName ) return [AddContactsModel new];
    
    AddContactsModel *model = self.contactModels[fieldName];
    if ( !model ) {
        model = [[AddContactsModel alloc] initWithFieldName:fieldName selectedPeople:self.formObjects[fieldName] ?: @[]];
        self.contactModels[fieldName] = model;
    }
    
    return model;
}

- (UIImagePickerController *)imagePicker
{
    if ( !_imagePicker ) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
//        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

- (NSMutableArray *)attachmentIDs
{
    if ( !_attachmentIDs ) {
        _attachmentIDs = [[NSMutableArray alloc] init];
    }
    return _attachmentIDs;
}

- (BOOL)supportsAttachment
{
    return YES;
}

- (BOOL)supportsCustomOpinion
{
    return YES;
}

- (void)dealloc
{
    [self cancelUpload];
}

@end

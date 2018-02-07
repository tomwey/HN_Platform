//
//  FormVC.h
//  HN_ERP
//
//  Created by tomwey on 1/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BaseNavBarVC.h"

typedef NS_ENUM(NSInteger, FormControlType) {
    FormControlTypeInput        = 1,
    FormControlTypeDate         = 2,
    FormControlTypeRadio        = 3,
    FormControlTypeSwitch       = 4,
    FormControlTypeAddContact   = 5,  // 添加单个人
    FormControlTypeAddContacts  = 6,  // 添加多个人
    FormControlTypeUpload       = 7,  // 上传附件，未实现
    FormControlTypeOpenFlow     = 8,  // 打开一个流程，并选中一个流程
    FormControlTypeSelect       = 9,
    FormControlTypeTextArea     = 10,
    FormControlTypeCheckbox     = 11,
    FormControlTypeSwitch2      = 12, // 支持在描述前面加否定限定的表述
    FormControlTypeDateRange    = 13, // 日期区间组件，用于开始日期至结束日期
    FormControlTypeRadioButton  = 14,
    FormControlTypeRelatedAnnex = 15, // 相关附件
    FormControlTypeRelatedFlow  = 16, // 相关流程
    FormControlTypeRequestReply = 17, // 请示批复
    FormControlTypeAttendanceException = 18, // 考勤异常
};

static CGFloat ControlHeights[] = {
    50,50,50,50,50,0,50,50,50,170,0,50,50,50,50,50,121,118,
};

@interface FormVC : BaseNavBarVC

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableDictionary *formObjects;

// 设置是否禁用Form输入，默认是NO
@property (nonatomic, assign) BOOL disableFormInputs;

- (NSArray *)formControls;
- (BOOL)supportsTextArea;

- (BOOL)supportsAttachment;
- (BOOL)supportsCustomOpinion;

- (void)resetForm;

- (void)hideKeyboard;

- (NSDictionary *)apiParams;

- (void)formControlsDidChange;

- (void)keyboardWillShow:(NSNotification *)noti;
- (void)keyboardWillHide:(NSNotification *)noti;

@end

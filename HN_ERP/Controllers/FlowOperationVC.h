//
//  FlowOperationVC.h
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BaseNavBarVC.h"

typedef NS_ENUM(NSInteger, FormControlType) {
    FormControlTypeInput       = 1,
    FormControlTypeDate        = 2,
    FormControlTypeRadio       = 3,
    FormControlTypeSwitch      = 4,
    FormControlTypeAddContact  = 5,  // 添加单个人
    FormControlTypeAddContacts = 6,  // 添加多个人
    FormControlTypeUpload      = 7,  // 上传附件，未实现
    FormControlTypeOpenFlow    = 8,  // 打开一个流程，并选中一个流程
    FormControlTypeSelect      = 9,
    FormControlTypeTextArea    = 10,
    FormControlTypeCheckbox    = 11,
};

@interface FlowOperationVC : BaseNavBarVC

@property (nonatomic, copy, readonly) NSString *manId;
@property (nonatomic, strong) id currentNode;

- (NSDictionary *)apiParams;

- (UITextView *)addFeedbackTextViewForFrame:(CGRect)frame inView:(UIView *)superView;

@end

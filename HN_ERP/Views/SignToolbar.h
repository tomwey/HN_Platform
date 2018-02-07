//
//  SignToolbar.h
//  HN_ERP
//
//  Created by tomwey on 3/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonType) {
    ButtonTypeDelete = 100,
    ButtonTypeAdd    = 101,
};

@interface SignToolbar : UIView

@property (nonatomic, assign) BOOL enableDeleteButton;

@property (nonatomic, assign) BOOL selectedCheckAll;

@property (nonatomic, copy) void (^didCheckAllBlock)(SignToolbar *sender, BOOL checked);

@property (nonatomic, copy) void (^didClickBlock)(SignToolbar *sender, ButtonType buttonType);

@end

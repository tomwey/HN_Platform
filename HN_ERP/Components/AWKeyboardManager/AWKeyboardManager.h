//
//  KeyboardManager.h
//  deyi
//
//  Created by tomwey on 9/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWKeyboardManager : NSObject

+ (AWKeyboardManager *)sharedInstance;

/**
 * 注册键盘通知
 *
 * 在viewWillAppear方法中调用
 */
- (void)registerKeyboardNotification;

/**
 * 移除键盘通知
 *
 * 在viewWillDisappear方法中调用
 */
- (void)unregisterKeyboardNotification;

/**
 * 设置自动滚动的输入框容器
 */
@property (nonatomic, weak) UIScrollView *autoScrollUITextFieldsContainer;

/**
 * 添加需要自动滚动的输入框
 *
 */
- (void)addAutoScrollUITextFields:(NSArray *)textFields;
- (void)removeAutoScrollUITextFields:(NSArray *)textFields;

/**
 * 此方法适用于最后一个输入框下面还有需要响应的控件的时候，
 * 需要添加额外的偏移来显示这个输入框下面的空间
 */
- (void)addLastAutoScrollUITextField:(UITextField *)lastField
                         extraOffset:(CGFloat)offset;
- (void)removeLastAutoScrollUITextField:(UITextField *)lastField;

@end

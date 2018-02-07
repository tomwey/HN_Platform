//
//  LoadEmptyOrErrorHandle.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

/*************************************************
 UITableView中数据加载失败或者数据为空的处理类
 *************************************************/

@protocol ReloadDelegate;
@interface UITableView (LoadEmptyOrErrorHandle)

/** 设置点击屏幕的回调delegate */
@property (nonatomic, assign) id <ReloadDelegate> reloadDelegate;

/** 设置错误提示文本的文本属性 */
@property (nonatomic, strong) NSDictionary<NSString *, id> *messageTextAttributes UI_APPEARANCE_SELECTOR;

/** 移除数据加载失败或者数据为空的提示 */
- (void)removeErrorOrEmptyTips;

/** 显示吐司提示，支持多行显示 */
- (void)showErrorOrEmptyToast:(NSString *)message;

/**
 * 显示纯文本提示，支持点击屏幕会响应ReloadDataProtocol接口方法
 * @param message 提示文字
 * @param delegate 点击屏幕任意位置reload数据
 */
- (void)showErrorOrEmptyMessage:(NSString *)message reloadDelegate:(id <ReloadDelegate>)delegate;

/**
 * 显示图片提示，支持点击屏幕会响应ReloadDataProtocol接口方法
 * @param image 提示图片
 * @param delegate 点击屏幕任意位置reload数据
 */
- (void)showErrorOrEmptyImage:(UIImage *)image reloadDelegate:(id <ReloadDelegate>)delegate;

- (void)showCustomView:(UIView *)aView;
- (void)removeCustomView;

@end

@protocol ReloadDelegate <NSObject>

@optional
/** 点击屏幕任意地方，重新加载数据 */
- (void)reloadDataForErrorOrEmpty;

@end

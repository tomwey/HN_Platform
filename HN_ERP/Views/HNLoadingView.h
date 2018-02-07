//
//  HNLoadingView.h
//  HN_ERP
//
//  Created by tomwey on 2/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HNLoadingState) {
    HNLoadingStateDefault,
    HNLoadingStateLoading,
    HNLoadingStateSuccessResult,
    HNLoadingStateFail,
    HNLoadingStateEmptyResult,
};

typedef NS_ENUM(NSInteger, HNLoadingIndicatorPosition) {
    HNLoadingIndicatorPositionTop,
    HNLoadingIndicatorPositionMiddle,
    HNLoadingIndicatorPositionBottom,
};

@class HNErrorOrEmptyView;

@interface HNLoadingView : UIView

@property (nonatomic, strong, readonly) HNErrorOrEmptyView *resultView;

@property (nonatomic, assign) HNLoadingIndicatorPosition indicatorPosition;

/*!
 * 开始加载，并显示加载的状态
 */
- (void)startLoading;

/** !
 * 结束加载
 * @param state 结束加载时的状态
 * @param reloadCallback 如果状态为失败或者结果集为空时，可以指定一个重新加载的回调
 * @return
 */
- (void)stopLoading:(HNLoadingState)state
     reloadCallback:(void (^)(void))reloadCallback;

//+ (instancetype)showLoadingToView:(UIView *)view animated:(BOOL)animated;
//
//+ (void)hideLoadingForView:(UIView *)view animated:(BOOL)animated;

@end

@interface HNErrorOrEmptyView : UIView

@property (nonatomic, copy) NSString  *text;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSDictionary *textAttributes;

@end

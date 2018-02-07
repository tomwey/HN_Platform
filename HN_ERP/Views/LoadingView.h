//
//  LoadingView.h
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoadingState) {
    LoadingStateDefault,
    LoadingStateLoading,
    LoadingStateSuccessResult,
    LoadingStateFail,
    LoadingStateEmptyResult,
};

@interface LoadingView : UIView

- (void)startLoading:(void (^)(void))reloadCallback;

- (void)finishLoading:(LoadingState)state;

@end

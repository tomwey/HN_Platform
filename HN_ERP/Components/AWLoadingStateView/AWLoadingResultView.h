//
//  AWLoadingResultView.h
//  BSA
//
//  Created by tangwei1 on 16/11/9.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWLoadingStateBaseView.h"

@interface AWLoadingResultView : UIView <AWLoadingResultViewProtocol>

@property (nonatomic, strong) UIImage *errorImage;
@property (nonatomic, strong) UIImage *emptyImage;

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *emptyMessage;

/// key的值为NSFontAttributeName或者NSForegroundColorAttributeName
/// 分别设置文字的字体以及颜色
@property (nonatomic, strong) NSDictionary<NSString *, id> *errorMessageAttributes;
@property (nonatomic, strong) NSDictionary<NSString *, id> *emptyMessageAttributes;

@end

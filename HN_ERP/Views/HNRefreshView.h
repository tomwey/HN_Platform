//
//  HNRefreshView.h
//  HN_ERP
//
//  Created by tomwey on 2/22/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNRefreshView : UIView

@property (nonatomic, copy) NSString *text;
// 默认是NO
@property (nonatomic, assign) BOOL animated;

@end

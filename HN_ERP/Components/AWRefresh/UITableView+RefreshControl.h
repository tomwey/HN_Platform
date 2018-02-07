//
//  UITableView+RefreshControl.h
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (AddRefreshControl)

- (UIRefreshControl *)addRefreshControlWithReloadCallback:(void (^)(UIRefreshControl*))callback;

- (void)finishLoading;

@end

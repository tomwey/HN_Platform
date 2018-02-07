//
//  UITableView+RefreshControl.m
//  zgnx
//
//  Created by tomwey on 5/29/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import "UITableView+RefreshControl.h"
#import <objc/runtime.h>

@implementation UITableView (AddRefreshControl)

typedef void (^ReloadCallback)(UIRefreshControl*);

static char kTableViewCallbackKey;

- (UIRefreshControl *)addRefreshControlWithReloadCallback:(void (^)(UIRefreshControl* control))callback
{
    objc_setAssociatedObject(self, &kTableViewCallbackKey, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ( callback ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil);
        });
    }
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startLoad:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 11361;
    [self addSubview:refreshControl];
    
    return refreshControl;
}

- (void)startLoad:(UIRefreshControl *)sender
{
    ReloadCallback callback = objc_getAssociatedObject(self, &kTableViewCallbackKey);
    if ( callback ) {
        callback(sender);
    }
}

- (void)finishLoading
{
    UIRefreshControl* refreshControl = (UIRefreshControl *)[self viewWithTag:11361];
    [refreshControl endRefreshing];
}

@end

//
//  UIApplication+Close.m
//  HN_ERP
//
//  Created by tomwey on 3/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "UIApplication+Close.h"
@interface UIApplication (existing)
- (void)suspend;
- (void)terminateWithSuccess;
@end

@implementation UIApplication (Close)

- (void)close
{
    if ( [self respondsToSelector:@selector(suspend)] ) {
        [self beginBackgroundTaskWithExpirationHandler:^{}];
        [self performSelector:@selector(exit) withObject:nil afterDelay:0.4];
        [self performSelector:@selector(suspend) withObject:nil];
    } else {
        [self exit];
    }
}

- (void)exit
{
    if ( [self respondsToSelector:@selector(terminateWithSuccess)] ) {
        [self performSelector:@selector(terminateWithSuccess) withObject:nil];
    } else {
        exit(EXIT_SUCCESS);
    }
}

@end

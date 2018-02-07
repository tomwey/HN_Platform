//
//  Trace&PlanListView.h
//  HN_ERP
//
//  Created by tomwey on 7/28/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracePlanListView : UIView

@property (nonatomic, copy) NSString *id_;
- (void)startLoading:(void (^)(void))completionBlock;

@end

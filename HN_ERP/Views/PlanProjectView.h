//
//  PlanProjectView.h
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanProjectView : UIView

@property (nonatomic, copy) void (^didSelectItem)(PlanProjectView *sender, id item);

- (void)startLoading;

@end

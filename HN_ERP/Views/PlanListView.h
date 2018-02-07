//
//  PlanListView.h
//  HN_ERP
//
//  Created by tomwey on 3/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanListView : UIView

@property (nonatomic, copy) void (^didSelectBlock)(PlanListView *sender, id selectedItem);

@property (nonatomic, assign) NSInteger dataType;

- (void)startLoading;

@end

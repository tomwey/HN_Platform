//
//  BIChartView.h
//  HN_ERP
//
//  Created by tomwey on 4/27/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIChartView : UIView

@property (nonatomic, strong) id chartData;

@property (nonatomic, copy) void (^didClickChartBlock)(BIChartView *sender);

@end

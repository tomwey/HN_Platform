//
//  PriceTrendView.h
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIVIewProtocol.h"

@interface PriceTrendView : UIView <BIViewProtocol>

@property (nonatomic, strong) id userDefaultArea;
@property (nonatomic, strong) NSArray *areaData;
@property (nonatomic, weak) UINavigationController *navController;

@property (nonatomic, copy) NSString *areaID;
@property (nonatomic, copy) NSString *areaName;

@property (nonatomic, copy) NSString *industryID;
@property (nonatomic, copy) NSString *industryName;

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion;

@end

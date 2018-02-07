//
//  ConFeeView.h
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIVIewProtocol.h"

@interface ConFeeView : UIView <BIViewProtocol>

@property (nonatomic, strong) id userDefaultArea;
@property (nonatomic, strong) NSArray *areaData;
@property (nonatomic, weak) UINavigationController *navController;

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion;

@end

//
//  SupplySellView.h
//  HN_ERP
//
//  Created by tomwey on 21/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIVIewProtocol.h"

@interface SupplySellView : UIView <BIViewProtocol>

@property (nonatomic, strong) id userDefaultArea;
@property (nonatomic, strong) NSArray *areaData;

@property (nonatomic, weak) UINavigationController *navController;

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion;

@end

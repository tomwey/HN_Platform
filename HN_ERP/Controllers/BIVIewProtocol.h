//
//  BIVIewProtocol.h
//  HN_ERP
//
//  Created by tomwey on 9/11/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#ifndef BIVIewProtocol_h
#define BIVIewProtocol_h

@protocol BIViewProtocol <NSObject>

@property (nonatomic, strong) id userDefaultArea;
@property (nonatomic, strong) NSArray *areaData;

@property (nonatomic, weak) UINavigationController *navController;

- (void)startLoadingData:(void (^)(BOOL succeed, NSError *error))completion;

@end

#endif /* BIVIewProtocol_h */

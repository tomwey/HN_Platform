//
//  CatalogContentView.h
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogContentView : UIView

@property (nonatomic, strong) NSArray *catalogData;

@property (nonatomic, copy) void (^didSelectBlock)(id data);

//- (void)reloadData;

@end

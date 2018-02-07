//
//  CatalogLeftMenuView.h
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OutputCatalog;
@interface CatalogLeftMenuView : UIView

@property (nonatomic, strong) NSArray *catalogData;

@property (nonatomic, copy) void (^didSelectCatalog)(OutputCatalog *catalog);

@end

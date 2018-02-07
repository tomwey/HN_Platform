//
//  UIViewController+NetworkService.h
//  RTA
//
//  Created by tomwey on 10/24/16.
//  Copyright © 2016 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreService.h"

@interface NSObject (StoreService)

@property (nonatomic, strong, readonly) StoreService *storeService;

@end

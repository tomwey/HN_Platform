//
//  Breadcrumb.h
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Breadcrumb : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *deptID;
@property (nonatomic, weak) UIViewController *page;

- (instancetype)initWithName:(NSString *)name page: (UIViewController *)page;

@end

//
//  EmployeeListVC.h
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BaseNavBarVC.h"

typedef NS_ENUM(NSInteger, EmployeeOperType) {
    EmployeeOperTypeView = 0,
    EmployeeOperTypeRadio,
    EmployeeOperTypeCheckbox,
};

@interface EmployeeListVC : BaseNavBarVC

@end

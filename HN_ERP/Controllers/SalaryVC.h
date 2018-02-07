//
//  SalaryVC.h
//  HN_ERP
//
//  Created by tomwey on 4/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BaseNavBarVC.h"

@interface SalaryVC : BaseNavBarVC

@end

@interface SalaryLoader : NSObject

+ (instancetype)sharedInstance;

- (void)startLoadingWithPassword:(NSString *)pwd
                            date:(NSDate *)date
                      completion:(void (^)(NSString *yearMonthStr, id salaryData, NSError *error, NSArray *yearMonths))completion;

@end

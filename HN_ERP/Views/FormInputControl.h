//
//  FormInputControl.h
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FormControl.h"

@interface FormInputControl : FormControl

- (instancetype)initWithLabel:(NSString *)label
                         name:(NSString *)name
                  placeholder:(NSString *)placeholder
                        value:(NSString *)value;

@end

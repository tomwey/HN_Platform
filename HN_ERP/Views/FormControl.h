//
//  FormControl.h
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FormControlProtocol <NSObject>

- (instancetype)initWithLabel:(NSString *)label
                         name:(NSString *)name
                  placeholder:(NSString *)placeholder;

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *value;

@end

@interface FormControl : UIView <FormControlProtocol>

@end

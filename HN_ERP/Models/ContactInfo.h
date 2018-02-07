//
//  ContactInfo.h
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactInfo : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *contacts;

- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title;

@end

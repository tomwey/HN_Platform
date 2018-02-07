//
//  NSObject+APIService.h
//  HN_ERP
//
//  Created by tomwey on 1/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIService.h"

@interface NSObject (APIService)

- (id <APIServiceProtocol>)apiServiceWithName:(NSString *)apiServiceName;

@end

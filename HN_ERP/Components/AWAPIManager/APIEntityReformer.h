//
//  APIEntityReformer.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIReformer.h"

@class APIManager;
@interface APIEntityReformer : NSObject <APIReformer>

- (id)reformDataWithManager:(APIManager *)manager;

@end

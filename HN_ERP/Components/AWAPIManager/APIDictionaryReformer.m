//
//  APIDictionaryReformer.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "APIDictionaryReformer.h"
#import "APIManager.h"

@implementation APIDictionaryReformer

- (id)reformDataWithManager:(APIManager *)manager
{
    id result = manager.rawData;
    if ( [result isKindOfClass:[NSArray class]] ) {
        return manager.rawData;
    } else if ( [result isKindOfClass:[NSDictionary class]] ) {
        NSArray* keys = [result allKeys];
        if ( [keys containsObject:@"data"] ) {
            return [result objectForKey:@"data"];
        }
        return manager.rawData;
    }
    
    return nil;
}

@end

//
//  OutputArea.m
//  HN_ERP
//
//  Created by tomwey on 23/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputArea.h"

@implementation OutputArea

- (instancetype)initWithDictionary:(id)dict
{
    if ( self = [super init] ) {
        self.areaId = [dict[@"area_id"] description];
        self.areaName = [dict[@"area_name"] description];
        self.areaOrder = [dict[@"area_order"] description];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
//    if (!object || self != object ) {
//        return false;
//    }
    
    if ( ![object isKindOfClass:[OutputArea class]] ) {
        return false;
    }
    
    OutputArea *area = (OutputArea *)object;
    return [area.areaId isEqualToString:self.areaId];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@", self.areaId, self.areaName];
}

- (id)shortItem
{
    return @{ @"name": self.areaName ?: @"", @"value": self.areaId ?: @"" };
}

@end

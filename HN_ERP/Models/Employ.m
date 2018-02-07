//
//  Employ.m
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "Employ.h"

@implementation Employ

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult
{
    if ( self = [super init] ) {
        self.checked = @([jsonResult[@"checked"] boolValue]);
        self.avatar  = jsonResult[@"icon"];
        self._id     = @([jsonResult[@"id"] integerValue]);
        self.itype   = @([jsonResult[@"itype"] integerValue]);
        self.job     = jsonResult[@"job"];
        self.level   = @([jsonResult[@"level"] integerValue]);
        self.name    = jsonResult[@"name"];
        self.pid     = @([jsonResult[@"pid"] integerValue]);
        self.supportsSelecting = @([jsonResult[@"supports_selecting"] boolValue]);
    }
    return self;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ( ![object isKindOfClass:[Employ class]] ) {
        return NO;
    }
    
    if ( object == self ) {
        return YES;
    }
    
    Employ *other = (Employ *)object;
    return [other._id integerValue] == [self._id integerValue];
}

@end

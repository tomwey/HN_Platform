//
//  Breadcrumb.m
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "Breadcrumb.h"

@implementation Breadcrumb

- (instancetype)initWithName:(NSString *)name page:(UIViewController *)page
{
    if ( self = [super init] ) {
        self.name = name;
        self.page = page;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, id: %@", self.name, self.deptID];
}

@end

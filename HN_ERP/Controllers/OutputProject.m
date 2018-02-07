//
//  OutputProject.m
//  HN_ERP
//
//  Created by tomwey on 23/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputProject.h"

@implementation OutputProject

- (instancetype)initWithDictionary:(id)dict
{
    if ( self = [super init] ) {
        self.projectId = [dict[@"project_id"] description];
        self.projectName = [dict[@"project_name"] description];
        self.projectOrder = [dict[@"project_order"] description];
        self.projectType = [dict[@"projecttype"] description];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
//    if (!object || self != object ) {
//        return false;
//    }
    
    if ( ![object isKindOfClass:[OutputProject class]] ) {
        return false;
    }
    
    OutputProject *project = (OutputProject *)object;
    return [project.projectId isEqualToString:self.projectId];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@", self.projectId, self.projectName];
}

- (id)shortItem
{
    return @{ @"name": self.projectName ?: @"", @"value": self.projectId ?: @"" };
}

@end

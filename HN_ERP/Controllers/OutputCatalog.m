//
//  OutputCatalog.m
//  HN_ERP
//
//  Created by tomwey on 23/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputCatalog.h"

@implementation OutputCatalog

- (instancetype)initWithDictionary:(id)result
{
    if ( self = [super init] ) {
        
//                    connum = 16;
//                    ilevel = 1;
//                    mid = "Type1_30";
//                    parid = 0;
//        
//                    typeid = 30;
//                    typename = "\U54a8\U8be2\U7c7b";
//                    typeno = "";
//                    typeorder = 30;
        
        self.total = result[@"connum"];
        self.level = result[@"ilevel"];
        self.mid   = result[@"mid"];
        self.parentId = result[@"parid"];
        self.typeId = result[@"typeid"];
        self.name = result[@"typename"];
        self.typeNo = result[@"typeno"];
        self.typeOrder = result[@"typeorder"];
        
        self.children = [@[] mutableCopy];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@", self.level, self.name, self.total, self.children];
}

//- (BOOL)isEqual:(id)object
//{
//    
//}

@end

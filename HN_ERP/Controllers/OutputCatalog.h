//
//  OutputCatalog.h
//  HN_ERP
//
//  Created by tomwey on 23/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputCatalog : NSObject

@property (nonatomic, copy) NSNumber *total;
@property (nonatomic, copy) NSNumber *level;
@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSNumber *parentId;

@property (nonatomic, copy) NSNumber *typeId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *typeNo;

@property (nonatomic, copy) NSNumber *typeOrder;

@property (nonatomic, strong) NSMutableArray *children;

- (instancetype)initWithDictionary:(id)result;

@end

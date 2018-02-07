//
//  Employ.h
//  HN_ERP
//
//  Created by tomwey on 2/16/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employ : NSObject <NSMutableCopying, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *job;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSNumber *checked;
@property (nonatomic, copy) NSNumber *_id;
@property (nonatomic, copy) NSNumber *level;
@property (nonatomic, copy) NSNumber *pid;
@property (nonatomic, copy) NSNumber *itype;
@property (nonatomic, copy) NSNumber *supportsSelecting;

- (instancetype)initWithDictionary:(NSDictionary *)jsonResult;

@end

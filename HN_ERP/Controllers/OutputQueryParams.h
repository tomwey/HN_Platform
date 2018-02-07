//
//  OutputQueryParams.h
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputQueryParams : NSObject

@property (nonatomic, copy) NSString *queryType;
@property (nonatomic, copy) NSString *projID;
@property (nonatomic, copy) NSString *manID;
@property (nonatomic, copy) NSString *catalogID;
@property (nonatomic, copy) NSString *where;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, copy) NSString *isFeeType;

@end

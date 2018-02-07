//
//  OutputArea.h
//  HN_ERP
//
//  Created by tomwey on 23/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputArea : NSObject

//"area_id" = 1679354;
//"area_name" = "\U6df1\U5733";
//"area_order" = 6;

@property (nonatomic, copy) NSString *areaId;
@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, copy) NSString *areaOrder;

- (instancetype)initWithDictionary:(id)dict;

- (id)shortItem;

@end

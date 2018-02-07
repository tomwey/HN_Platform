//
//  OutputProject.h
//  HN_ERP
//
//  Created by tomwey on 23/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutputArea.h"

@interface OutputProject : NSObject

//            "parent_project_id" = 102;
//            "parent_project_name" = "\U4e2d\U592e\U82b1\U56ed";
//            "parent_project_order" = 12300;
//            "project_id" = 10066;
//            "project_name" = "\U4e2d\U592e\U82b1\U56ed\U4e00\U671f";
//            "project_order" = 12500;

@property (nonatomic, strong) OutputArea *area;

@property (nonatomic, strong) OutputProject *parent;

@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *projectOrder;
@property (nonatomic, copy) NSString *projectType;

- (instancetype)initWithDictionary:(id)dict;

- (id)shortItem;

@end

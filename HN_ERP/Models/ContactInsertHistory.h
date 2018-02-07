//
//  ContactInsertHistory.h
//  HN_ERP
//
//  Created by tomwey on 2/15/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CTPersistanceRecord.h"

@interface ContactInsertHistory : CTPersistanceRecord

@property (nonatomic, strong) NSNumber *_id;
@property (nonatomic, copy)   NSString *mobile;
@property (nonatomic, strong) NSNumber *personID;

@end

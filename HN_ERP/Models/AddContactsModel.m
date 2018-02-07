//
//  AddContactsModel.m
//  HN_ERP
//
//  Created by tomwey on 2/27/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AddContactsModel.h"

@implementation AddContactsModel

- (instancetype)initWithFieldName:(NSString *)fieldName
                   selectedPeople:(NSArray *)selectedPeople
{
    if ( self = [super init] ) {
        self.fieldName = fieldName;
        self.selectedPeople = selectedPeople;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ => %@", self.fieldName, self.selectedPeople];
}

@end

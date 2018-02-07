//
//  AddContactsModel.h
//  HN_ERP
//
//  Created by tomwey on 2/27/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddContactsModel : NSObject

@property (nonatomic, copy) NSString *fieldName;
@property (nonatomic, strong) NSArray *selectedPeople;

- (instancetype)initWithFieldName:(NSString *)fieldName
                   selectedPeople:(NSArray *)selectedPeople;

@end

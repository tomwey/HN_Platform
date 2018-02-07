//
//  FormControl.m
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FormControl.h"

@implementation FormControl

@synthesize label,name,placeholder,value;

- (instancetype)initWithLabel:(NSString *)sLabel name:(NSString *)sName placeholder:(NSString *)sPlaceholder
{
    if ( self = [super init] ) {
        self.label = sLabel;
        self.name  = sName;
        self.placeholder = sPlaceholder;
        self.value = nil;
    }
    
    return self;
}

@end

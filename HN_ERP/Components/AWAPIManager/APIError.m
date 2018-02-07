//
//  APIError.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "APIError.h"

@implementation APIError

- (instancetype)initWithCode:(NSInteger)code message:(NSString *)message
{
    if ( self = [super init] ) {
        self.code = code;
        self.message = message;
    }
    return self;
}

+ (instancetype)apiErrorWithCode:(NSInteger)code message:(NSString *)message;
{
    return [[APIError alloc] initWithCode:code message:message];
}

- (void)dealloc
{
    self.message = nil;
//    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"APIError(code=%ld, message=%@)", (long)self.code, self.message];
}

@end

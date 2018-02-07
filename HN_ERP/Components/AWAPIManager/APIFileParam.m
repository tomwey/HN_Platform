//
//  APIFileParam.m
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "APIFileParam.h"

@implementation APIFileParam

- (instancetype)initWithFileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    if ( self = [super init] ) {
        self.fileData = fileData;
        self.name = name;
        self.fileName = fileName;
        self.mimeType = mimeType;
    }
    return self;
}

+ (instancetype)paramWithFileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    return [[APIFileParam alloc] initWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
}

- (void)dealloc
{
    self.fileData = nil;
    self.name = nil;
    self.fileName = nil;
    self.mimeType = nil;
    
//    [super dealloc];
}

@end

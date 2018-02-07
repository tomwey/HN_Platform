//
//  NSDataAdditions.h
//  Cute&Funny
//
//  Created by tangwei1 on 15-4-17.
//  Copyright (c) 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AWCategory)

/**
 * 用CC_MD5计算二进制数据的md5
 */
@property (nonatomic, readonly) NSString* md5Hash;

- (NSData *)aes256_encrypt:(NSString *)key;
- (NSData *)aes256_decrypt:(NSString *)key;

@end

@interface NSData (Compression)

// decompress
- (NSData *)zlibInflate;

- (NSData *)zlibDeflate;

@end

@interface NSString (MD5)

/**
 * 计算字符串的md5
 */
@property (nonatomic, readonly) NSString* md5Hash;

- (NSString *)aes256_encrypt:(NSString *)key;
- (NSString *)aes256_decrypt:(NSString *)key;

@end

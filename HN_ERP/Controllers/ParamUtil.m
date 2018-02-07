//
//  ParamUtil.m
//  RTA
//
//  Created by tomwey on 10/24/16.
//  Copyright © 2016 tomwey. All rights reserved.
//

#import "ParamUtil.h"
#import "Defines.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

static inline NSString *AESEncryptStringForString(NSString *string) {
    NSString *defaultKey = @"666AA4DF3533497D973D852004B975BC";
    size_t bytesEncrypted = 0;
    //#define BUFFSIZE 8192
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    char* buffer = malloc(bufferSize);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(defaultKey.UTF8String, (CC_LONG)strlen(defaultKey.UTF8String), digest);
    
    CCCryptorStatus ret = CCCrypt(kCCEncrypt,
                                  kCCAlgorithmAES128,
                                  kCCOptionPKCS7Padding | kCCOptionECBMode,
                                  digest,
                                  kCCKeySizeAES128,
                                  NULL,
                                  data.bytes,
                                  data.length,
                                  buffer, bufferSize,
                                  &bytesEncrypted);
    if (ret != kCCSuccess) {
        free(buffer);
        return nil;
    }
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:bytesEncrypted];
    for(int i=0;i<bytesEncrypted;i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%02x",buffer[i]&0xff];///16进制数
        [result appendString:newHexStr];
    }
    
    free(buffer); buffer = NULL;
//    NSLog(@"REsult : [%@]", result);
    return result;
};

NSString *stringByParams(NSDictionary *params)
{
    if (!params) {
        return nil;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    for (id key in params) {
        [temp addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    return [temp componentsJoinedByString:@"&"];
}

NSString *AESEncryptStringFromParams(NSDictionary *params)
{
    NSString *paramString = stringByParams(params);
    
    NSMutableString *string = [NSMutableString stringWithString:paramString];
    [string appendFormat:@"&app_key=%@", API_KEY];
    [string appendString:@"&"];
    [string appendFormat:@"app_secret=%@", API_SECRET];
    
    NSString *result = AESEncryptStringForString(string);
    
//    NSString *result = [string aes256_encrypt:[AES_KEY md5Hash]];
    
//    NSLog(@"aes: %@", result);
    
    return result;
    
//    return [[string dataUsingEncoding:NSUTF8StringEncoding] aes256_encrypt:AES_KEY];
}

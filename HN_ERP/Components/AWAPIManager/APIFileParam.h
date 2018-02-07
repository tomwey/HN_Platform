//
//  APIFileParam.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

/*****************************************************
 文件参数类：封装了文件参数相关的数据
 *****************************************************/
@interface APIFileParam : NSObject

/** 设置文件二进制数据，不能为nil */
@property (nonatomic, retain) NSData* fileData;

/** 设置服务器接收该文件数据的参数名，不能为nil, 并且是唯一的 */
@property (nonatomic, copy) NSString* name;

/** 设置文件数据对应的文件名称，不能为nil, 例如：image.png */
@property (nonatomic, copy) NSString* fileName;

/** 设置支持的文件上传类型，不能为nil，例如：JPEG图片格式的MIME type为：image/jpeg，
 正确的文件类型参见：http://www.iana.org/assignments/media-types/*/
@property (nonatomic, copy) NSString* mimeType;

- (instancetype)initWithFileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;
+ (instancetype)paramWithFileData:(NSData *)fileData name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end

/**
 * 快速创建一个自动释放的文件参数对象
 * 
 * @param fileData 文件数据
 * @param name 设置服务器接收该文件数据的参数名，不能为nil, 并且是唯一的
 * @param fileName 设置文件数据对应的文件名称，不能为nil, 例如：image.png
 * @param mimeType 设置支持的文件上传类型，不能为nil，例如：JPEG图片格式的MIME type为：image/jpeg，
                   正确的文件类型参见：http://www.iana.org/assignments/media-types/
 * @return 返回一个自动释放的文件参数对象
 */
static inline APIFileParam* APIFileParamCreate(NSData* fileData, NSString* name, NSString* fileName, NSString* mimeType)
{
    return [APIFileParam paramWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
};

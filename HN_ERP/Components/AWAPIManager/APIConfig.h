//
//  APIConfig.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APIConfig <NSObject>

/** 设置API生产服务器地址，
 *  格式为：域名加端口或者IP加端口，
 *  例如：http://120.0.0.1:8000或者http://www.apixxx.com
 */
@property (nonatomic, copy) NSString* productionServer;

/** 设置API开发服务器地址，
 *  格式为：域名加端口或者IP加端口，
 *  例如：http://120.0.0.1:8000或者http://www.apixxx.com
 */
@property (nonatomic, copy) NSString* stageServer;

/** 设置是否是开发模式 */
@property (nonatomic, assign) BOOL debugMode;

/** 根据app模式返回指定的服务器地址 */
@property (nonatomic, copy, readonly) NSString* currentServer;

@end

@interface APIConfig : NSObject <APIConfig>

+ (instancetype)sharedInstance;

/** 设置API生产服务器地址 */
@property (nonatomic, copy) NSString* productionServer;

/** 设置API开发服务器地址 */
@property (nonatomic, copy) NSString* stageServer;

/** 设置是否是开发模式 */
@property (nonatomic, assign) BOOL debugMode;

/** 根据app模式返回指定的服务器地址 */
@property (nonatomic, copy, readonly) NSString* currentServer;

@end

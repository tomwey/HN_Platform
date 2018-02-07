//
//  APIManager.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APIConfig.h"
#import "APIError.h"
#import "APIRequest.h"
#import "APIReformer.h"

@class APIManager;
//////////////////////////////////////////////////////////
#pragma mark 网络请求结果回调
//////////////////////////////////////////////////////////
@protocol APIManagerDelegate <NSObject>

@optional

/** 网络请求开始 */
- (void)apiManagerDidStart:(APIManager *)manager;

/** 网络请求完成 */
- (void)apiManagerDidFinish:(APIManager *)manager;

@required
/** 网络请求成功回调 */
- (void)apiManagerDidSuccess:(APIManager *)manager;

/** 网络请求失败回调 */
- (void)apiManagerDidFailure:(APIManager *)manager;

@end

@interface APIManager : NSObject

/** 初始化对象 */
- (instancetype)initWithDelegate:(id <APIManagerDelegate>)aDelegate;
+ (instancetype)apiManagerWithDelegate:(id <APIManagerDelegate>)aDelegate;

//////////////////////////////////////////////////////////
#pragma mark Setters and Getters
//////////////////////////////////////////////////////////

/** 设置请求回调方法 */
@property (nonatomic, assign) id <APIManagerDelegate> delegate;

/** 设置API配置，如果不设置该值，那么默认使用全局APIConfig */
@property (nonatomic, retain) id <APIConfig> apiConfig;

/** 返回网络响应原生数据 */
@property (nonatomic, retain, readonly) id rawData;

/** 返回网络错误 */
@property (nonatomic, retain, readonly) APIError* apiError;

/** 返回请求对象 */
@property (nonatomic, retain, readonly) APIRequest* apiRequest;

/** 是否正在请求 */
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;

///////////////////////////////////////////////////////////////////
#pragma mark Public Methods
///////////////////////////////////////////////////////////////////

/**
 * 开始请求，子类可以重写该方法，该方法会在请求开始之前调用
 * 注意：必须调用[super startRequest]
 */
- (void)startRequest;

/**
 * 完成请求，子类可以重写该方法，该方法会在请求结束之后调用
 * 注意：必须调用[super finishRequesting]
 */
- (void)finishRequesting;

/**
 * 发送请求
 * @param aRequest 请求对象
 * @return
 */
- (void)sendRequest:(APIRequest *)aRequest;
- (void)sendRequest:(APIRequest *)aRequest delegate:(id <APIManagerDelegate>)delegate;

/**
 * 取消请求
 */
- (void)cancelRequest;

/**
 * 返回指定转化格式的数据对象
 * @param reformer 数据转化对象
 * @return 返回正确格式的数据
 */
- (id)fetchDataWithReformer:(id <APIReformer>)reformer;

@end

/***********************************************************************
                    UITableView加载网络数据扩展
 ***********************************************************************/
@interface UITableView (LoadNetworkDataWithAPIManager)

/** 设置数据接口，例如：/v1/tags.json */
@property (nonatomic, copy) NSString* dataUri;

- (void)loadDataWithAPIManager:(APIManager *)manager;

- (void)loadNextPageData;

@end
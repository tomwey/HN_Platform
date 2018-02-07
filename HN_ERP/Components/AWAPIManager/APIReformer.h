//
//  APIReformer.h
//  BayLe
//
//  Created by tangwei1 on 15/11/24.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#ifndef APIReformer_h
#define APIReformer_h

/****************************************************
 网络结果数据转换协议
 ****************************************************/

@class APIManager;
@protocol APIReformer <NSObject>

- (id)reformDataWithManager:(APIManager *)manager;

@end

#endif /* APIReformer_h */

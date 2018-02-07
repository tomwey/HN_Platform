//
//  AWTableDataConfig.h
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#ifndef AWTableDataConfig_h
#define AWTableDataConfig_h

/** 配置表视图中每个cell或collectionCell的数据 */
@protocol AWTableDataConfig <NSObject>

/**
 * 配置每个cell或grid对象的数据，并绑定选中回调块
 *
 * @param data 要绑定的数据对象
 * @param selectBlock 选中每个cell或grid的回调块，当有需要处理选中消息时，需要回调该块来回传参数
 */
- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock;

@optional

+ (CGFloat)cellHeight;

@end

#endif /* AWTableDataConfig_h */




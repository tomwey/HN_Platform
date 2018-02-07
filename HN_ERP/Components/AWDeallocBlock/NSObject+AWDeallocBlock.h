//
//  NSObject+AWDeallocBlock.h
//  RTA
//
//  Created by tangwei1 on 16/11/7.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWDeallocBlock : NSObject

@property (nonatomic, copy) void (^deallocBlock)(void);

@end

@interface NSObject (AWDeallocBlock)

// 需要注意循环引用
- (void)addDeallocBlock:(void (^)(void))block;

@end

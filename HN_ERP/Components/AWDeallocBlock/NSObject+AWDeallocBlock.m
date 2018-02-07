//
//  NSObject+AWDeallocBlock.m
//  RTA
//
//  Created by tangwei1 on 16/11/7.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "NSObject+AWDeallocBlock.h"
#import <objc/runtime.h>

@implementation AWDeallocBlock

/*
 * 当引用对象释放时，我会自动被释放，进而dealloc得到调用
 * objc的runtime动态关联机制
 */
- (void)dealloc
{
    if ( self.deallocBlock ) {
        self.deallocBlock();
    }
}

@end

@implementation NSObject (AWDeallocBlock)

static char kAWDeallocBlockKey;

- (void)addDeallocBlock:(void (^)(void))block
{
    AWDeallocBlock *deallocBlock = (AWDeallocBlock *)objc_getAssociatedObject(self, &kAWDeallocBlockKey);
    if ( !deallocBlock ) {
        deallocBlock = [[AWDeallocBlock alloc] init];
        objc_setAssociatedObject(self, &kAWDeallocBlockKey, deallocBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        deallocBlock.deallocBlock = block;
    }
}

@end

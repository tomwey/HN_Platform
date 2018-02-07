//
//  AWMacros.h
//  BayLe
//
//  Created by tangwei1 on 15/11/19.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#ifndef AWMacros_h
#define AWMacros_h

// 自定义日志输出方法
#ifdef DEBUG

#define NSLog(s, ...) do { \
NSLog(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,[NSString stringWithFormat:(s), ##__VA_ARGS__]);\
} while(0)

#else

#define NSLog(s, ...) do {} while(0)

#endif

/////////////////////////////////////////////////////////////////////////////////////

// 单例实现
#define AW_SINGLETON_IMPL(__CLASS_NAME) \
\
+ (__CLASS_NAME*)sharedInstance \
{ \
static __CLASS_NAME* instance = nil;\
dispatch_once(&onceToken, ^{\
if ( !instance ) {\
    instance = [[__CLASS_NAME alloc] init];\
}\
});\
return instance; \
}

/////////////////////////////////////////////////////////////////////////////////////

// Time
#define AW_MINUTE    60
#define AW_HOUR      ( 60 * AW_MINUTE )
#define AW_DAY       ( 24 * AW_HOUR )
#define AW_5_DAYS    ( 5 * AW_DAY )
#define AW_WEEK      ( 7 * AW_DAY )
#define AW_MONTH     ( 30.5 * AW_DAY )
#define AW_YEAR      ( 365 * AW_DAY )

// Safe releases
//#define AW_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
//#define AW_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

// Release a CoreFoundation object safely
//#define AW_RELEASE_CF_SAFELY(__REF)  { if ( nil != (__REF) ) { CFRelease(__REF); __REF = nil; } }

#endif /* AWMacros_h */

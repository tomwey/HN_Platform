//
//  HNCacheHelper.h
//  HN_ERP
//
//  Created by tomwey on 06/02/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNCacheHelper : NSObject

+ (instancetype)sharedInstance;

-( float )readCacheSize;

- (void)clearFile;

@end

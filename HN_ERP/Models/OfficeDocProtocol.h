//
//  OfficeDocProtocol.h
//  HN_ERP
//
//  Created by tomwey on 4/1/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeDocProtocol : NSURLProtocol

@end

@interface NSURLProtocol (WebKitSupport)

+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;

@end

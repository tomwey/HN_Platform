//
//  AWMediator.h
//  deyi
//
//  Created by tomwey on 9/3/16.
//  Copyright © 2016 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWMediator : NSObject

+ (AWMediator *)sharedInstance;

- (UIViewController *)openVCWithName:(NSString *)vcClassName
                              params:(NSDictionary *)params;
- (UIViewController *)openVCWithClass:(Class)vcClass
                               params:(NSDictionary *)params;

- (UIViewController *)openNavVCWithName:(NSString *)vcClassName
                                 params:(NSDictionary *)params;

@end

@interface UIViewController (AWParamsCategory)

@property (nonatomic, strong, readonly) NSDictionary *params;

@end

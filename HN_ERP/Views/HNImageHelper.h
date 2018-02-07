//
//  HNImageHelper.h
//  HN_ERP
//
//  Created by tomwey on 2/21/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNImageHelper : UIView

+ (UIImage *)imageForName:(NSString *)name
                    manID:(NSInteger)manID
                     size:(CGSize)size;

+ (void)imageForName:(NSString *)name
               manID:(NSInteger)manID
                size:(CGSize)size
     completionBlock:(void (^)(UIImage *anImage, NSError *error))completionBlock;

@end

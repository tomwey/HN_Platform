//
//  UIImageView+CustomAvatar.h
//  HN_ERP
//
//  Created by tomwey on 06/02/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManInfo : NSObject

@property (nonatomic, assign) NSInteger manID;
@property (nonatomic, copy) NSString *manName;

@end

@interface UIImageView (CustomAvatar)

- (void)setImageWithManInfo:(ManInfo *)manInfo;

@end

ManInfo *HNManInfoCreate(NSInteger manID, NSString *manName);

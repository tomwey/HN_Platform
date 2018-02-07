//
//  Checkbox.h
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Checkbox : UIView

- (instancetype)initWithNormalImage:(UIImage *)normalImage
                      selectedImage:(UIImage *)selectedImage;

// 默认为nil
@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSDictionary *labelAttributes;

// 默认为NO
@property (nonatomic, assign) BOOL checked;

// 最大宽度，默认为180
@property (nonatomic, assign) CGFloat maximumWidth;

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, copy) void (^didChangeBlock)(Checkbox *sender);

@end

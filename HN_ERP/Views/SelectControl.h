//
//  SelectControl.h
//  HN_ERP
//
//  Created by tomwey on 1/24/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectControl;

@interface SelectControlGroup : NSObject

@property (nonatomic, assign) BOOL supportsMultipleSelect;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id value;

- (void)addControl:(SelectControl *)control;
- (void)removeControl:(SelectControl *)control;

- (void)removeAllControls;

@end

@interface SelectControl : UIView

- (instancetype)initWithNormalImage:(UIImage *)normalImage
                      selectedImage:(UIImage *)selectedImage
                               name:(NSString *)name
                              value:(NSString *)value;

@property (nonatomic, weak) SelectControlGroup *controlGroup;

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;

@property (nonatomic, assign) id delegate;

@property (nonatomic, assign, readonly) BOOL selected;

@end

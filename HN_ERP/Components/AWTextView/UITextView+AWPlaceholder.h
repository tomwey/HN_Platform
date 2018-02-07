//
//  UITextView+AWPlaceholder.h
//  RTA
//
//  Created by tangwei1 on 16/11/7.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (AWPlaceholder)

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSDictionary *placeholderAttributes;

@property (nonatomic, assign) CGPoint placeholderPosition;

@end

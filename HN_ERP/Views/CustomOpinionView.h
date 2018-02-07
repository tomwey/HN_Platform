//
//  CustomOpinionView.h
//  HN_ERP
//
//  Created by tomwey on 3/2/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomOpinionView : UIView

@property (nonatomic, strong) NSArray<NSString *> *opinions;

@property (nonatomic, copy) void (^didSelectOpinionBlock)(CustomOpinionView *sender, NSString *opinion);

- (void)showInView:(UIView *)view position:(CGPoint)position;
- (void)dismiss;

- (void)reloadData;

@end

@interface HNTouchView : UIView

@property (nonatomic, copy) void (^didTouchBlock)(void);

@end

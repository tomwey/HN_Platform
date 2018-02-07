//
//  MoneyView.h
//  HN_ERP
//
//  Created by tomwey on 19/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LayoutType) {
    LayoutTypeMoneyTop,
    LayoutTypeMoenyBottom,
};

@interface MoneyView : UIView

@property (nonatomic, assign) LayoutType layoutType;

@property (nonatomic, assign) NSTextAlignment alignment;

- (void)setMoney:(NSString *)money forLabel:(NSString *)label;

@end

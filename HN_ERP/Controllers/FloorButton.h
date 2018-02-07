//
//  Floor.h
//  HN_ERP
//
//  Created by tomwey on 25/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FloorConfirmType) {
    FloorConfirmTypeUnconfirmed,
    FloorConfirmTypeConfirmed,
    FloorConfirmTypeShouldConfirming,
};
@interface FloorButton : UIView

//@property (nonatomic, assign) BOOL confirmed;
//
//@property (nonatomic, assign) BOOL hasConfirmed;

@property (nonatomic, assign) FloorConfirmType confirmType;

@property (nonatomic, assign) NSInteger floor;

@property (nonatomic, assign) BOOL needPay;

@property (nonatomic, assign) BOOL confirmed;

@property (nonatomic, copy) void (^didSelectBlock)(FloorButton *sender);

@end

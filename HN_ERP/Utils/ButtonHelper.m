//
//  ButtonHelper.m
//  HN_ERP
//
//  Created by tomwey on 3/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ButtonHelper.h"

UIButton * HNBackButton(CGFloat btnSize, id target, SEL action)
{
    FAKIonIcons *backIcon = [FAKIonIcons iosArrowLeftIconWithSize:btnSize];
    [backIcon addAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
    UIImage  *backImage = [backIcon imageWithSize:CGSizeMake(40, 40)];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:backImage forState:UIControlStateNormal];
    [backBtn sizeToFit];
//    backBtn.backgroundColor = [UIColor yellowColor];
    
    [backBtn addTarget:target action:action
      forControlEvents:UIControlEventTouchUpInside];
    return backBtn;
}

UIButton * HNCloseButton(CGFloat btnSize, id target, SEL action)
{
    return HNCloseButton2(btnSize, target, action, [UIColor whiteColor]);
}

UIButton * HNCloseButton2(CGFloat btnSize, id target, SEL action, UIColor *btnColor)
{
    FAKIonIcons *closeIcon = [FAKIonIcons iosCloseEmptyIconWithSize:btnSize];
    [closeIcon addAttributes:@{ NSForegroundColorAttributeName: btnColor }];
    UIImage  *closeImage = [closeIcon imageWithSize:CGSizeMake(37, 37)];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    closeBtn.backgroundColor = [UIColor redColor];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    [closeBtn addTarget:target
                 action:action
       forControlEvents:UIControlEventTouchUpInside];
    return closeBtn;
}

UIButton * HNCloseButtonWithSize(CGFloat iconSize, CGSize btnSize, id target, SEL action)
{
    FAKIonIcons *closeIcon = [FAKIonIcons iosCloseEmptyIconWithSize:iconSize];
    [closeIcon addAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
    UIImage  *closeImage = [closeIcon imageWithSize:btnSize];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.backgroundColor = [UIColor redColor];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    [closeBtn addTarget:target
                 action:action
       forControlEvents:UIControlEventTouchUpInside];
    return closeBtn;
}

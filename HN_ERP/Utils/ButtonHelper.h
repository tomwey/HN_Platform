//
//  ButtonHelper.h
//  HN_ERP
//
//  Created by tomwey on 3/9/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontAwesomeKit.h"

UIButton * HNBackButton(CGFloat btnSize, id target, SEL action);

UIButton * HNCloseButton(CGFloat btnSize, id target, SEL action);
UIButton * HNCloseButton2(CGFloat btnSize, id target, SEL action, UIColor *btnColor);

UIButton * HNCloseButtonWithSize(CGFloat iconSize, CGSize btnSize, id target, SEL action);

//
//  FlowSubmitAlert.h
//  HN_ERP
//
//  Created by tomwey on 4/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlowSubmitAlert : UIView

@property (nonatomic, copy) NSString *receipts;
@property (nonatomic, copy) NSString *ccNames;

- (void)showInView:(UIView *)aView
      doneCallback:(void (^)(FlowSubmitAlert *sender))callback;

@end

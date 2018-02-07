//
//  MeetingOrderedView.h
//  HN_ERP
//
//  Created by tomwey on 5/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QueryParams;
@interface MeetingOrderedView : UIView

+ (void)showInView:(UIView *)superView
       queryParams:(QueryParams *)params
    selectCallback:(void (^)(id item))callback
     closeCallback:(void (^)(void))closeCallback;

+ (void)hideForView:(UIView *)superView animated:(BOOL)animated;

@end

@interface QueryParams : NSObject

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, copy) NSString *meetingRoomId;

@end

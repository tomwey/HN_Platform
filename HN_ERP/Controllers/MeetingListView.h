//
//  MeetingListView.h
//  HN_ERP
//
//  Created by tomwey on 5/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingListView : UIView

- (void)startLoadingWithParams:(NSDictionary *)params
                    completion:(void (^)(MeetingListView *sender))completion;

@property (nonatomic, copy) void (^didSelectMeetingItemBlock)(id item);

@end

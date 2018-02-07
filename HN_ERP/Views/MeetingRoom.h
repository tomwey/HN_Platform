//
//  MeetingRoom.h
//  HN_ERP
//
//  Created by tomwey on 4/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingRoom : UIView

@property (nonatomic, strong) id meetingData;

@property (nonatomic, copy) void (^openBlock)(MeetingRoom *sender);

@end

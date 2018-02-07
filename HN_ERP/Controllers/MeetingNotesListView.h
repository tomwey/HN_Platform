//
//  MeetingNotesListView.h
//  HN_ERP
//
//  Created by tomwey on 7/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingNotesListView : UIView

@property (nonatomic, copy) void (^itemDidSelectBlock)(MeetingNotesListView *sender, id selectedItem);

@end

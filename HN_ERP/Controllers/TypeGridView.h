//
//  TypeGridView.h
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeGridView : UIView

@property (nonatomic, strong) id item;
@property (nonatomic, copy) void (^tapCallback)(TypeGridView *sender);

@end

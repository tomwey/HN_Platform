//
//  EmploySearchView.h
//  HN_ERP
//
//  Created by tomwey on 3/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmploySearchView : UIView

@property (nonatomic, copy) void (^didSelectBlock)(EmploySearchView *view, id item);

//@property (nonatomic, copy) NSString *fieldName;

@property (nonatomic, assign, readonly) CGSize searchResultsBoxSize;

@property (nonatomic, assign) CGPoint searchResultsBoxPosition;

- (void)startSearching:(NSString *)keyword
            atPosition:(CGPoint)position
       completionBlock:(void (^)(void))completionBlock;

- (void)stopSearching;

@end

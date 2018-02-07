//
//  DocumentView.h
//  HN_ERP
//
//  Created by tomwey on 2/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentView : UIView

@property (nonatomic, weak) UIView *loadingContainer;

@property (nonatomic, strong) NSDictionary *searchCondition;
@property (nonatomic, copy)   NSString     *industryType;
@property (nonatomic, copy)   NSString     *readType;

@property (nonatomic, copy) void (^didSelectDocumentBlock)(DocumentView *sender, id item);

- (void)startLoadingForType:(NSString *)type;

- (void)forceRefreshForType:(NSString *)type;

@end

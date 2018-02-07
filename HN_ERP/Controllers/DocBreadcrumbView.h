//
//  DocBreadcrumbView.h
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocBreadcrumb;
@interface DocBreadcrumbView : UIView

@property (nonatomic, copy) NSArray *breadcrumbs;

@property (nonatomic, copy) void (^breadcrumbClickCallback)(DocBreadcrumbView *sender, DocBreadcrumb *data);

@end

@interface DocBreadcrumb : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) UIViewController *page;
@property (nonatomic, strong) id data;

- (instancetype)initWithName:(NSString *)name
                        data:(id)data
                        page:(UIViewController *)page;

@end

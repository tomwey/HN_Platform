//
//  AWFilterBaseView.h
//  HN_ERP
//
//  Created by tomwey on 28/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FilterItemType) {
    FilterItemTypeNormal = 1,
    FilterItemTypeCustomDateRange = 2,
};

@class AWFilterItem;
@interface AWFilterView : UIView

@property (nonatomic, strong) NSArray<AWFilterItem *> *filterItems;
@property (nonatomic, strong) NSArray<AWFilterItem *> *customFilterItems;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)showInView:(UIView *)superView
       selectBlock:(void (^)(AWFilterView *sender, AWFilterItem *selectedItem))selectBlock;

- (void)dismiss;

@end

////////////////////////////////////////////////////////////////////////
@interface AWFilterItem : NSObject

@property (nonatomic, assign) FilterItemType itemType;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) id value;

- (instancetype)initWithName:(NSString *)name value:(id)value type:(FilterItemType)type;

@end

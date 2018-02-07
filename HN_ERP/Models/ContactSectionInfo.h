//
//  ContactSectionInfo.h
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactInfo;
@class AWSectionHeaderView;

@interface ContactSectionInfo : NSObject

@property (nonatomic, getter=isOpen) BOOL open;

@property (nonatomic, strong) ContactInfo *contact;

@property (nonatomic, weak) AWSectionHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *rowHeights;

- (NSUInteger)countOfRowHeights;
- (id)objectInRowHeightsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject;
- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes;
- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray;

@end

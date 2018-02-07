//
//  ContactSectionInfo.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContactSectionInfo.h"
#import "ContactInfo.h"
#import "AWSectionHeaderView.h"

@implementation ContactSectionInfo

- (instancetype)init
{
    if ( self = [super init] ) {
        self.rowHeights = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)countOfRowHeights
{
    return [self.rowHeights count];
}

- (id)objectInRowHeightsAtIndex:(NSUInteger)idx
{
    return self.rowHeights[idx];
}

- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx {
    [self.rowHeights insertObject:anObject atIndex:idx];
}

- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes {
    [self.rowHeights insertObjects:rowHeightArray atIndexes:indexes];
}

- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx {
    [self.rowHeights removeObjectAtIndex:idx];
}

- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes {
    [self.rowHeights removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject {
    self.rowHeights[idx] = anObject;
}

- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray {
    [self.rowHeights replaceObjectsAtIndexes:indexes withObjects:rowHeightArray];
}

@end


//
//  ContactCell.m
//  HN_ERP
//
//  Created by tomwey on 1/19/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContactCell.h"

@interface ContactCell ()

@property (nonatomic, readwrite) BOOL opened;

@end

@implementation ContactCell

- (void)setOpened:(BOOL)opened animated:(BOOL)animated
{
    self.opened = opened;
    
    
}

@end

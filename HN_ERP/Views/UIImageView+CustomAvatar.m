//
//  UIImageView+CustomAvatar.m
//  HN_ERP
//
//  Created by tomwey on 06/02/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "UIImageView+CustomAvatar.h"
#import "Defines.h"
#import <objc/runtime.h>

#define COLORS_COUNT 10
static NSString * colors[COLORS_COUNT] = {
    @"96,70,184",
    @"135,64,167",
    @"200,66,140",
    @"75,53,40",
    @"145,114,94",
    @"33,47,63",
    @"108,121,122",
    @"37,161,77",
    @"223,53,47",
    @"44,63,109"
};

@implementation UIImageView (CustomAvatar)

- (void)setImageWithManInfo:(ManInfo *)manInfo
{
    NSInteger index = manInfo.manID % COLORS_COUNT;
    
    NSArray *colorPartials = [colors[index] componentsSeparatedByString:@","];
    self.backgroundColor = AWColorFromRGB([colorPartials[0] intValue],
                                                 [colorPartials[1] intValue],
                                                 [colorPartials[2] intValue]);
    
    self.cornerRadius = self.height / 2.0;
    self.clipsToBounds = YES;
    
    self.image = nil;
    
    UILabel *label = [self hn_customLabel];
    
    label.frame = self.bounds;
    
    NSString *name = [manInfo.manName description];
    
    if ( name.length >= 2 ) {
        label.text = [name substringFromIndex:name.length - 2];
    } else {
        label.text = name;
    }
}

- (UILabel *)hn_customLabel
{
    UILabel *label = objc_getAssociatedObject(self, @selector(hn_customLabel));
    if (!label) {
        label = AWCreateLabel(CGRectZero,
                              nil,
                              NSTextAlignmentCenter,
                              AWSystemFontWithSize(14, NO),
                              [UIColor whiteColor]);
        [self addSubview:label];
        
        objc_setAssociatedObject(self, @selector(hn_customLabel), label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return label;
}

@end

@implementation ManInfo


@end

ManInfo *HNManInfoCreate(NSInteger manID, NSString *manName)
{
    ManInfo *info = [[ManInfo alloc] init];
    info.manID = manID;
    info.manName = manName;
    return info;
}

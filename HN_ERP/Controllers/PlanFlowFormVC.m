//
//  PlanFlowFormVC.m
//  HN_ERP
//
//  Created by tomwey on 5/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PlanFlowFormVC.h"
#import "Defines.h"

@interface PlanFlowFormVC ()

@end

@implementation PlanFlowFormVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navBar.title = @"计划确认";
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))
                   leftMargin:2];
    
    __weak typeof(self) weakSelf = self;
    [self addRightItemWithTitle:@"发送"
                titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(60, 44)
                    rightMargin:3
                       callback:^{
                           [weakSelf send];
                       }];
    
//    [self prepareFormObjects];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)send
{
    NSLog(@"%@", self.formObjects);
}

- (void)prepareFormObjects
{
    self.formObjects[@"proj_name"] = self.params[@"itemname"] ?: @"";
    self.formObjects[@"plan_type"] = self.params[@"plantypename"] ?: @"";
    self.formObjects[@"plan_level"] = self.params[@"plangrade"] ?: @"";
    self.formObjects[@"dept"] = self.params[@"liabledeptname"] ?: @"";
    self.formObjects[@"man1"] = self.params[@"liablemanname"] ?: @"";
    self.formObjects[@"man"] = self.params[@"domanname"] ?: @"";
    self.formObjects[@"plan_time"] = HNDateFromObject(self.params[@"planoverdate"], @"T");
    //    self.formObjects[@"proj_name"] = self.params[@"itemname"] ?: @"";
    //    self.formObjects[@"proj_name"] = self.params[@"itemname"] ?: @"";
}

- (BOOL)supportsTextArea
{
    return NO;
}

- (BOOL)supportsCustomOpinion
{
    return NO;
}

- (BOOL)supportsAttachment
{
    return NO;
}

@end

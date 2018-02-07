//
//  CommentVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CommentVC.h"
#import "Defines.h"

@implementation CommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navBar.title = @"提交批注";
}

- (NSDictionary *)apiParams
{
    return @{
             @"dotype": @"flow",
             @"type": @"comment",
             @"opinion_allow_null": self.params[@"opinion_allow_null"],
             };
}

@end

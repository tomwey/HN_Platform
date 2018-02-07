//
//  RemainStockVC.m
//  HN_ERP
//
//  Created by tomwey on 9/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "RemainStockVC.h"
#import "Defines.h"
#import "RemainStockView.h"

@interface RemainStockVC ()

@property (nonatomic, strong) RemainStockView *remainStockView;

@end

@implementation RemainStockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"剩余货值";
    
    self.remainStockView = [[RemainStockView alloc] init];
    [self.contentView addSubview:self.remainStockView];
    self.remainStockView.frame = self.contentView.bounds;
    
    
    self.remainStockView.userDefaultArea = self.params[@"default_area"];
    self.remainStockView.areaData        = self.params[@"area_data"];
    self.remainStockView.navController   = self.params[@"navController"];
    self.remainStockView.areaID          = self.params[@"area_id"];
    self.remainStockView.areaName        = self.params[@"area_name"];
    
    self.remainStockView.industryID      = self.params[@"industry_id"];
    self.remainStockView.industryName    = self.params[@"industry_name"];
    
    [self.remainStockView startLoadingData:nil];
}

@end

//
//  PriceTrendVC.m
//  HN_ERP
//
//  Created by tomwey on 15/09/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PriceTrendVC.h"
#import "Defines.h"
#import "PriceTrendView.h"

@interface PriceTrendVC ()

@property (nonatomic, strong) PriceTrendView *trendView;

@end

@implementation PriceTrendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"价格趋势";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.trendView = [[PriceTrendView alloc] init];
    [self.contentView addSubview:self.trendView];
    self.trendView.frame = self.contentView.bounds;
    
    self.trendView.userDefaultArea = self.params[@"default_area"];
    self.trendView.areaData        = self.params[@"area_data"];
    self.trendView.navController   = self.params[@"navController"];
    self.trendView.areaID          = self.params[@"area_id"];
    self.trendView.areaName        = self.params[@"area_name"];
    
    self.trendView.industryID      = self.params[@"industry_id"];
    self.trendView.industryName    = self.params[@"industry_name"];
    
    [self.trendView startLoadingData:nil];
    
}


@end

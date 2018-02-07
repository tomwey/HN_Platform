//
//  HomeVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "HomeVC.h"
#import "Defines.h"

@interface HomeVC () //<UITableViewDelegate>


@end

@implementation HomeVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                        image:[UIImage imageNamed:@"icon_home.png"]
                                                selectedImage:[UIImage imageNamed:@"icon_home_selected.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *header = AWCreateImageView(nil);
    header.image = AWImageNoCached(@"home-header.png");
    header.frame = CGRectMake(0, 0, self.contentView.width,
                              self.contentView.width * header.image.size.height /
                              header.image.size.width);
    [self.contentView addSubview:header];
    
    NSArray *sections = @[@"btn_oa.png",@"btn_meeting.png",
                          @"btn_document",
                          @"btn_plan.png",@"btn_bi.png"];
    
    CGFloat dtw = self.contentView.width / 3.0;
    
    int i = 0;
    for (NSString *btnName in sections) {
        UIButton *btn = AWCreateImageButton(btnName, self, @selector(btnClicked:));
        [self.contentView addSubview:btn];
        
        int m = i % 3;
        int n = i / 3;
        
        CGFloat dtx = dtw / 2 + m * dtw;
        CGFloat dty = header.bottom + 40 + btn.height / 2 + n * (btn.height + 40);
        
        btn.center = CGPointMake(dtx, dty);
        btn.tag = 100 + i;
        
        i++;
    }
}

- (void)btnClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
            // oa
        }
            break;
        case 101:
        {
            // meeting
        }
            break;
        case 102:
        {
            // document
        }
            break;
        case 103:
        {
            // plan
        }
            break;
        case 104:
        {
            // bi
        }
            break;
        
            
        default:
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

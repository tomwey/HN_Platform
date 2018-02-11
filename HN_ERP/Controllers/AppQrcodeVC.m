//
//  AppQrcodeVC.m
//  HN_ERP
//
//  Created by tomwey on 6/29/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AppQrcodeVC.h"
#import "Defines.h"

@interface AppQrcodeVC ()

@end

@implementation AppQrcodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"扫码下载";
    
    UIImageView *imageView = AWCreateImageView(nil);
    [self.contentView addSubview:imageView];
    imageView.image = AWImageNoCached(@"hnapp-qrcode.jpg");
    imageView.frame = CGRectMake(0, 0, 150, 150);
    
    imageView.center = CGPointMake(self.contentView.width / 2,
                                   20 + imageView.height / 2);
    
    UILabel *tipLabel = AWCreateLabel(CGRectMake(0, imageView.bottom + 10,
                                                 self.contentView.width,
                                                 30),
                                      @"扫描二维码下载安装",
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(14, NO),
                                      AWColorFromRGB(58, 58, 58));
    [self.contentView addSubview:tipLabel];
}

@end

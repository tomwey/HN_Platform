//
//  GuideVC.m
//  HN_ERP
//
//  Created by tomwey on 9/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "GuideVC.h"
#import "Defines.h"

@interface GuideVC () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *pageScrollView;

@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UIButton *skipButton;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

#define kGuidsCount 3
#define kGuideSaveKey @"hasShowGuide.20170929.1"

@implementation GuideVC

+ (BOOL)canShowGuide
{
    BOOL shown = [[NSUserDefaults standardUserDefaults] boolForKey:kGuideSaveKey];
    return !shown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kGuideSaveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    
    self.view.backgroundColor = AWColorFromRGB(249, 249, 249);
    
//    self.pageScrollView.backgroundColor = MAIN_THEME_COLOR;
    
    self.pageScrollView.frame = self.view.bounds;
    
    self.pageControl.frame = CGRectMake(0, self.view.height - 20 - 5,
                                        self.view.width,
                                        20);
    
    self.pageControl.numberOfPages = kGuidsCount;
    self.pageControl.currentPage   = 0;
    
    self.pageControl.hidesForSinglePage = YES;
    
    for (int i=0; i<kGuidsCount; i++) {
        UIImageView *imageView = AWCreateImageView(nil);
        imageView.image = AWImageNoCached([NSString stringWithFormat:@"guide_%d.png", i+1]);
        [self.pageScrollView addSubview:imageView];
        imageView.frame = self.pageScrollView.frame;
        imageView.left = i * imageView.width;
        
        imageView.userInteractionEnabled = YES;
        
        if ( i == kGuidsCount - 1 ) {
            [imageView addSubview:self.goButton];

            self.goButton.position = CGPointMake(imageView.width - self.goButton.width - 12,
                                                 12);
        } else {
//            [imageView addSubview:self.skipButton];
            
            UIButton *skipButton = AWCreateTextButton(CGRectMake(0, 0, 50, 34),
                                             @"跳过",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(skip:));
            //        [self.view addSubview:_skipButton];
            [imageView addSubview:skipButton];
            
            skipButton.titleLabel.font = AWSystemFontWithSize(14, NO);
            
            skipButton.layer.borderColor = [UIColor whiteColor].CGColor;
            skipButton.layer.borderWidth = 1;
            
            skipButton.position = CGPointMake(imageView.width - skipButton.width - 12,
                                                 12);
        }
    }
    
    self.pageScrollView.contentSize = CGSizeMake(kGuidsCount * self.view.width, self.view.height);
}

- (void)go
{
    self.goButton.userInteractionEnabled = NO;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app showGuide:NO];
}

- (void)skip:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    
    [self go];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = self.pageScrollView.contentOffset.x / self.pageScrollView.width;
    self.pageControl.currentPage = page;
    
    NSLog(@"%f", self.pageScrollView.contentOffset.x);
    if ( self.pageScrollView.contentOffset.x > (self.view.width * ( kGuidsCount - 1 ) + 20 ) ) {
        [self go];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIScrollView *)pageScrollView
{
    if (!_pageScrollView) {
        _pageScrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_pageScrollView];
        _pageScrollView.showsVerticalScrollIndicator =
        _pageScrollView.showsHorizontalScrollIndicator = NO;
        
        _pageScrollView.pagingEnabled = YES;
        
        _pageScrollView.delegate = self;
    }
    
    return _pageScrollView;
}

- (UIPageControl *)pageControl
{
    if ( !_pageControl ) {
        _pageControl = [[UIPageControl alloc] init];
        [self.view addSubview:_pageControl];
    }
    return _pageControl;
}

- (UIButton *)goButton
{
    if ( !_goButton ) {
        _goButton = AWCreateTextButton(CGRectMake(0, 0, 96, 38),
                                       @"立即使用",
                                       [UIColor whiteColor],
                                       self,
                                       @selector(go));
//        [self.view addSubview:_goButton];
        
        _goButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
        _goButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _goButton.layer.borderWidth = 1;
        
        _goButton.layer.cornerRadius = _goButton.height / 2;
        _goButton.clipsToBounds = YES;
    }
    return _goButton;
}

//- (UIButton *)skipButton
//{
//    if ( !_skipButton ) {
//        _skipButton = AWCreateTextButton(CGRectMake(0, 0, 50, 34),
//                                         @"跳过",
//                                         [UIColor whiteColor],
//                                         self,
//                                         @selector(skip));
////        [self.view addSubview:_skipButton];
//        
//        _skipButton.titleLabel.font = AWSystemFontWithSize(14, NO);
//        
//        _skipButton.layer.borderColor = [UIColor whiteColor].CGColor;
//        _skipButton.layer.borderWidth = 1;
//    }
//    return _skipButton;
//}

@end

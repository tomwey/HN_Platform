//
//  DocBreadcrumbView.m
//  HN_ERP
//
//  Created by tomwey on 5/10/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DocBreadcrumbView.h"
#import "Defines.h"

@interface DocBreadcrumbView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *tempBreadcrumbs;
@property (nonatomic, strong) NSMutableArray *tempBreadcrumbs2;

@end

@implementation DocBreadcrumbView

- (void)setBreadcrumbs:(NSArray *)breadcrumbs
{
    _breadcrumbs = breadcrumbs;
    
    [self layoutBreadcrumbs];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
}

- (void)btnClicked:(UIButton *)sender
{
    DocBreadcrumb *b = sender.userData;
    if ( b == [self.breadcrumbs lastObject] ) {
        return;
    }
    
    if ( self.breadcrumbClickCallback ) {
        self.breadcrumbClickCallback(self, b);
    }
}

- (void)layoutBreadcrumbs
{
    self.height = 60;
    self.scrollView.height = 60;
    
    for (UIView *view in self.tempBreadcrumbs) {
        [view removeFromSuperview];
    }
    [self.tempBreadcrumbs removeAllObjects];
    
    for (UIView *view in self.tempBreadcrumbs2) {
        [view removeFromSuperview];
    }
    [self.tempBreadcrumbs2 removeAllObjects];
    
    CGFloat posX = 20;
    UIButton *lastBtn = nil;
    int i = 0;
    for (DocBreadcrumb *bc in self.breadcrumbs) {
        UIButton *btn = AWCreateTextButton(CGRectZero, bc.name,
                                           MAIN_THEME_COLOR,//AWColorFromRGB(133, 133, 133),
                                           self,
                                           @selector(btnClicked:));
        btn.userData = bc;
        [self.scrollView addSubview:btn];
        
        [btn sizeToFit];
        btn.height = 60;

        btn.position = CGPointMake(posX - 10,
                                   self.scrollView.height / 2 - btn.height / 2);
        
        posX = btn.right + 50;
        
        if ( i == self.breadcrumbs.count - 1 ) {
            lastBtn = btn;
            [btn setTitleColor:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR forState:UIControlStateNormal];
            btn.userInteractionEnabled = NO;
        } else {
            UIImageView *arrowView = AWCreateImageView(@"icon_arrow-right.png");
            [self.scrollView addSubview:arrowView];
            arrowView.center = CGPointMake(btn.right + 10 + arrowView.width / 2, btn.midY);
            [self.tempBreadcrumbs2 addObject:arrowView];
        }
        
        [self.tempBreadcrumbs addObject:btn];
        
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(posX, self.height);
    
    [self.scrollView scrollRectToVisible:[(UIView *)[self.tempBreadcrumbs lastObject] frame] animated:YES];
}

- (UIScrollView *)scrollView
{
    if ( !_scrollView ) {
        _scrollView = [[UIScrollView alloc] init];
        [self addSubview:_scrollView];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (NSMutableArray *)tempBreadcrumbs
{
    if ( !_tempBreadcrumbs ) {
        _tempBreadcrumbs = [[NSMutableArray alloc] init];
    }
    return _tempBreadcrumbs;
}

- (NSMutableArray *)tempBreadcrumbs2
{
    if ( !_tempBreadcrumbs2 ) {
        _tempBreadcrumbs2 = [[NSMutableArray alloc] init];
    }
    return _tempBreadcrumbs2;
}

@end

@implementation DocBreadcrumb

- (instancetype)initWithName:(NSString *)name
                        data:(id)data
                        page:(UIViewController *)page
{
    if ( self = [super init] ) {
        self.name = name;
        self.data = data;
        self.page = page;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return self;
}

@end

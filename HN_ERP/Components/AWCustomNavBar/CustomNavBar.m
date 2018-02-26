//
//  CustomNavBar.m
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "CustomNavBar.h"
#import <objc/runtime.h>

@interface CustomNavBar ()

@property (nonatomic, strong) UIImageView* backgroundView;

@property (nonatomic, strong) UIView* inLeftItem;
@property (nonatomic, strong) UIView* inRightItem;
@property (nonatomic, strong) UIView* inTitleView;
@property (nonatomic, strong) UILabel* inTitleLabel;

@property (nonatomic, strong) NSMutableArray* leftFluidItems;
@property (nonatomic, strong) NSMutableArray* rightFluidItems;

@end

@implementation CustomNavBar

static CGFloat const kLeftItemLeftOffset   = 15.0;
static CGFloat const kRightItemRightOffset = kLeftItemLeftOffset;
static CGFloat const kFluidItemSpacing     = 10.0;

@dynamic backgroundImage, leftItem, rightItem, title, titleView;

@synthesize leftMarginOfLeftItem   = _leftMarginOfLeftItem;
@synthesize rightMarginOfRightItem = _rightMarginOfRightItem;
@synthesize marginOfFluidItem      = _marginOfFluidItem;

#pragma mark -
#pragma mark Lifecycle methods
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 44 + /*[self statusBarHeight]*/ 20);
    
    if ( CGRectGetHeight([[UIScreen mainScreen] bounds]) == 812 ) {
        // iPhone X
        self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 44 + /*[self statusBarHeight]*/ 20 + 24);
    } else {
        
    }
    
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.frame = self.bounds;
    [self addSubview:self.backgroundView];
    self.backgroundView.userInteractionEnabled = YES;
    
    _leftMarginOfLeftItem   = kLeftItemLeftOffset;
    _rightMarginOfRightItem = kRightItemRightOffset;
    _marginOfFluidItem      = kFluidItemSpacing;
}

- (void)dealloc
{
    self.backgroundView = nil;
    _inLeftItem = nil;
    _inRightItem = nil;
    _inTitleView = nil;
    self.inTitleLabel = nil;
    
    self.leftFluidItems = nil;
    self.rightFluidItems = nil;
}

#pragma mark -
#pragma mark Layout method
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ( self.leftItem ) {
        self.inLeftItem.center = CGPointMake(self.leftMarginOfLeftItem + CGRectGetWidth(self.inLeftItem.bounds) / 2,
                                             22 + [self statusBarHeight]);
    }
    
    if ( self.rightItem ) {
        self.inRightItem.center = CGPointMake(CGRectGetWidth(self.bounds) - self.rightMarginOfRightItem - CGRectGetWidth(self.inRightItem.bounds) / 2,
                                              22 + [self statusBarHeight]);
    }
    
    [self layoutFluidItems];
}

#pragma mark - 
#pragma mark Public Methods
- (void)addFluidBarItem:(UIView *)item atPosition:(FluidBarItemPosition)position
{
    switch (position) {
        case FluidBarItemPositionTitleLeft:
        {
            if ( !self.leftFluidItems ) {
                self.leftFluidItems = [NSMutableArray array];
            }
            
            if ( ![self.leftFluidItems containsObject:item] ) {
                [self.leftFluidItems addObject:item];
                
                [self.backgroundView addSubview:item];
            }
        }
            break;
        case FluidBarItemPositionTitleRight:
        {
            if ( !self.rightFluidItems ) {
                self.rightFluidItems = [NSMutableArray array];
            }
            
            if ( ![self.rightFluidItems containsObject:item] ) {
                [self.rightFluidItems addObject:item];
                
                [self.backgroundView addSubview:item];
            }
        }
            break;
            
        default:
            break;
    }
    
    [self setNeedsLayout];
//    [self layoutFluidItems];
}

- (void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleAttributes
{
    _titleTextAttributes = titleAttributes;
    if ( self.inTitleLabel && [titleAttributes count] > 0 ) {
//        NSString* text = [NSString stringWithString:self.title];
//        self.inTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:titleAttributes];
//        self.inTitleLabel.text = nil;
//        text = nil;
        if ( titleAttributes[NSFontAttributeName] ) {
            self.inTitleLabel.font = titleAttributes[NSFontAttributeName];
        }
        
        if ( titleAttributes[NSForegroundColorAttributeName] ) {
           self.inTitleLabel.textColor = titleAttributes[NSForegroundColorAttributeName]; 
        }
        
    }
}

#pragma mark -
#pragma mark Override Setters and Getters
///---------------------------- 设置左导航条目 -----------------------------------
- (void)setLeftItem:(UIView *)leftItem
{
    if ( !leftItem ) {
        [self.inLeftItem removeFromSuperview];
        self.inLeftItem = nil;
    } else {
        if ( leftItem != self.inLeftItem ) {
            if ( self.inLeftItem.superview ) {
                [self.inLeftItem removeFromSuperview];
            }
            
            self.inLeftItem = leftItem;
            [self.backgroundView addSubview:self.inLeftItem];
        }
    }
    
//    [self layoutFluidItems];
    [self setNeedsLayout];
}

- (UIView *)leftItem { return self.inLeftItem; }

///---------------------------- 设置右导航条目 ------------------------------------
- (void)setRightItem:(UIView *)rightItem
{
    if ( !rightItem ) {
        [self.inRightItem removeFromSuperview];
    } else {
        if ( rightItem != self.inRightItem ) {
            if ( self.inRightItem.superview ) {
                [self.inRightItem removeFromSuperview];
            }
            
            self.inRightItem = rightItem;
            [self.backgroundView addSubview:self.inRightItem];
        }
    }
    
//    [self layoutFluidItems];
    [self setNeedsLayout];
}

- (UIView *)rightItem { return self.inRightItem; }

///---------------------------- 设置标题 ------------------------------------
- (void)setTitle:(NSString *)title
{
    if ( !title ) {
        [self.inTitleLabel removeFromSuperview];
        self.inTitleLabel = nil;
    } else {
        if ( !self.inTitleLabel ) {
            self.inTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                      CGRectGetWidth(self.bounds) * 0.618,
                                                                      44)];
            
            self.inTitleLabel.backgroundColor = [UIColor clearColor];
            self.inTitleLabel.numberOfLines   = 2;
            self.inTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.backgroundView addSubview:self.inTitleLabel];
            self.inTitleLabel.adjustsFontSizeToFitWidth = YES;
        }
        self.inTitleLabel.text = title;
        if ( self.titleTextAttributes ) {
            if ( self.titleTextAttributes[NSFontAttributeName] ) {
                self.inTitleLabel.font = self.titleTextAttributes[NSFontAttributeName];
            }
            
            if ( self.titleTextAttributes[NSForegroundColorAttributeName] ) {
                self.inTitleLabel.textColor = self.titleTextAttributes[NSForegroundColorAttributeName];
            }
        }
    }
}

- (NSString *)title { return self.inTitleLabel.text ?: self.inTitleLabel.attributedText.string; }

///---------------------------- 设置自定义标题视图 ------------------------------------
- (void)setTitleView:(UIView *)titleView
{
    if ( !titleView ) {
        [self.inTitleView removeFromSuperview];
        self.inTitleView = nil;
    } else {
        if ( self.inTitleView == titleView ) {
            return;
        }
        
        if ( self.inTitleView.superview ) {
            [self.inTitleView removeFromSuperview];
        }
        
        self.inTitleView = titleView;
        [self.backgroundView addSubview:self.inTitleView];
    }
}

- (UIView *)titleView { return self.inTitleView; }

///---------------------------- 设置背景图片和背景颜色 ------------------------------------
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundView.image = backgroundImage;
}

- (UIImage *)backgroundImage { return self.backgroundView.image; }

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundView.image = nil;
    self.backgroundView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor { return self.backgroundView.backgroundColor; }

- (void)setLeftMarginOfLeftItem:(CGFloat)leftMarginOfLeftItem
{
    if ( _leftMarginOfLeftItem != leftMarginOfLeftItem ) {
        _leftMarginOfLeftItem = leftMarginOfLeftItem;
        [self setNeedsLayout];
    }
}

- (void)setRightMarginOfRightItem:(CGFloat)rightMarginOfRightItem
{
    if ( _rightMarginOfRightItem != rightMarginOfRightItem ) {
        _rightMarginOfRightItem = rightMarginOfRightItem;
        [self setNeedsLayout];
    }
}

- (void)setMarginOfFluidItem:(CGFloat)marginOfFluidItem
{
    if ( _marginOfFluidItem != marginOfFluidItem ) {
        _marginOfFluidItem = marginOfFluidItem;
        [self setNeedsLayout];
    }
}

#pragma mark -
#pragma mark Private Methods
- (CGFloat)statusBarHeight
{
    return CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
}

- (void)layoutFluidItems
{
    // 布局左边的item
    CGFloat leftOffsetX;
    if ( !self.leftItem ) {
        leftOffsetX = self.leftMarginOfLeftItem;
    } else {
        leftOffsetX = CGRectGetMaxX(self.leftItem.frame) + self.marginOfFluidItem;
    }
    
    for (UIView *item in self.leftFluidItems) {
        item.center = CGPointMake(leftOffsetX + CGRectGetWidth(item.frame) / 2,
                                  22 + [self statusBarHeight]);
        leftOffsetX = CGRectGetMaxX(item.frame) + self.marginOfFluidItem;
    }
    
    // 布局右边的item
    CGFloat rightOffsetX;
    if ( !self.rightItem ) {
        rightOffsetX = CGRectGetWidth(self.bounds) - self.rightMarginOfRightItem;
    } else {
        rightOffsetX = CGRectGetMinX(self.rightItem.frame) - self.marginOfFluidItem;
    }
    
    NSUInteger count = self.rightFluidItems.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView* item = self.rightFluidItems[i];
        item.center = CGPointMake(rightOffsetX - CGRectGetWidth(item.frame) / 2,
                                  22 + [self statusBarHeight]);
        rightOffsetX = CGRectGetMinX(item.frame) - self.marginOfFluidItem;
    }
    
    // 布局标题
    CGFloat width = rightOffsetX - leftOffsetX - 20; // 左右间距各为10
    width = MIN(width, CGRectGetWidth(self.bounds) * 0.75);
    
    if ( self.inTitleLabel ) {
        self.inTitleLabel.frame  = CGRectMake(0, 0, width, 44);
        self.inTitleLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2,
                                               22 + [self statusBarHeight]);
    }
    
    // 布局标题视图
    if ( self.inTitleView ) {
        self.inTitleView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2,
                                              22 + [self statusBarHeight]);
    }
}

@end

@implementation UIViewController (CustomNavBar)

static CGFloat const kCustomNavBarTag = 1011013;
static CGFloat const kContentViewTag  = 1011014;

- (CustomNavBar *)navBar
{
    CustomNavBar* navBar = (CustomNavBar* )[self.view viewWithTag:kCustomNavBarTag];
    if ( !navBar ) {
        self.navigationController.navigationBarHidden = YES;
        
        navBar = [[CustomNavBar alloc] init];
        
        if (CGRectGetHeight([[UIScreen mainScreen] bounds]) == 812) {
            navBar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 88);
        } else {
            navBar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 64);
        }
        
        // 设置默认属性
        navBar.backgroundColor = [UIColor whiteColor];
        
//        navBar.layer.shadowColor = [[UIColor colorWithRed:180 / 255.0
//                                                    green:180 / 255.0
//                                                     blue:180 / 255.0
//                                                    alpha:1.0] CGColor];
//        navBar.layer.shadowOffset = CGSizeMake(0, 0.5);
//        navBar.layer.shadowOpacity = 0.6;
//        navBar.layer.shadowRadius = 0.5;
        
        navBar.tag = kCustomNavBarTag;
        
        [self.view addSubview:navBar];
        
        // 创建一个contentView
        CGFloat height = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(navBar.frame);
        
        if (CGRectGetHeight([[UIScreen mainScreen] bounds]) == 812) {
            height -= 34;
        }
        
        UIView* contentView = [[UIView alloc] initWithFrame:
                               CGRectMake(0,
                                          CGRectGetHeight(navBar.frame),
                                          CGRectGetWidth(self.view.bounds),
                                          height)];
        contentView.tag = kContentViewTag;
        [self.view addSubview:contentView];
        
        if ( self.tabBarController ) {
            CGRect frame = contentView.frame;
            frame.size.height -= 49;
            contentView.frame = frame;
        }
        
        [self.view sendSubviewToBack:contentView];
        
        [self.view bringSubviewToFront:navBar];
    }
    
    return navBar;
}

- (UIView *)contentView
{
    return [self.view viewWithTag:kContentViewTag] ?: self.view;
}

@end

/// 添加导航条item扩展
@implementation UIViewController (AddNavBarItems)

static inline UIButton *CreateImageButtonWithSize(NSString *imageName, CGSize size, id target, SEL action) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    
    button.exclusiveTouch = YES;
    
    CGFloat width = MAX(image.size.width, 40);
    CGFloat height = MAX(image.size.height, 40);
    
    height = MIN(height, 44);
    
    button.bounds = CGRectMake(0, 0, width, height);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
};

static inline UIButton *CreateTextButtonWithSize(NSString *title, CGSize size, id target, SEL action) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, 0, size.width, size.height);
    
    button.exclusiveTouch = YES;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
};

static char kAWLeftItemCallbackKey,kAWRightItemCallbackKey;

- (void)aw_leftItemClick_10110:(UIButton *)sender
{
    void (^clickCallback)(void) = objc_getAssociatedObject(self, &kAWLeftItemCallbackKey);
    if ( clickCallback ) {
        clickCallback();
    }
}

- (void)aw_rightItemClick_10110:(UIButton *)sender
{
    void (^clickCallback)(void) = objc_getAssociatedObject(self, &kAWRightItemCallbackKey);
    if ( clickCallback ) {
        clickCallback();
    }
}

/**
 * 添加导航条图片按钮，按钮的大小为图片的大小
 *
 * @param itemImage 按钮图片
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithImage:(NSString *)itemImage  callback:(void (^)(void))callback
{
    return [self addLeftItemWithImage:itemImage leftMargin:15 callback:callback];
}

- (UIView *)addRightItemWithImage:(NSString *)itemImage callback:(void (^)(void))callback
{
    return [self addRightItemWithImage:itemImage rightMargin:15 callback:callback];
}

/**
 * 添加导航条图片按钮，如果图片大小太小，则按钮的大小为指定的大小，否则为图片的大小
 *
 * @param itemImage 按钮图片
 * @param itemSize  按钮大小
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
//- (UIView *)addLeftItemWithImage:(NSString *)itemImage  size:(CGSize)itemSize callback:(void (^)(void))callback
//{
//    return [self addLeftItemWithImage:itemImage size:itemSize leftMargin:15 callback:callback];
//}
//
//- (UIView *)addRightItemWithImage:(NSString *)itemImage size:(CGSize)itemSize callback:(void (^)(void))callback
//{
//    return [self addRightItemWithImage:itemImage size:itemSize rightMargin:15 callback:callback];
//}

/**
 * 添加导航条图片按钮，如果图片大小太小，则按钮的大小为指定的大小，否则为图片的大小
 *
 * @param itemImage 按钮图片
 * @param itemSize  按钮大小
 * @param margin 按钮左间距
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithImage:(NSString *)itemImage
                            //size:(CGSize)itemSize
                      leftMargin:(CGFloat)margin
                        callback:(void (^)(void))callback
{
    objc_setAssociatedObject(self, &kAWLeftItemCallbackKey, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ( [itemImage length] == 0 ) {
        self.navBar.leftItem = nil;
        return nil;
    } else {
        UIButton *btn = CreateImageButtonWithSize(itemImage, CGSizeZero, self, @selector(aw_leftItemClick_10110:));
        self.navBar.leftItem = btn;
        self.navBar.leftMarginOfLeftItem = margin;
        return btn;
    }
}

- (UIView *)addRightItemWithImage:(NSString *)itemImage
                             //size:(CGSize)itemSize
                      rightMargin:(CGFloat)margin
                         callback:(void (^)(void))callback
{
    objc_setAssociatedObject(self, &kAWRightItemCallbackKey, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ( [itemImage length] == 0 ) {
        self.navBar.rightItem = nil;
        return nil;
    } else {
        UIButton *btn = CreateImageButtonWithSize(itemImage, CGSizeZero, self, @selector(aw_rightItemClick_10110:));
        self.navBar.rightItem = btn;
        self.navBar.rightMarginOfRightItem = margin;
        return btn;
    }
}

/**
 * 添加导航条文字按钮
 *
 * @param title 按钮标题
 * @param itemSize  按钮大小
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithTitle:(NSString *)title  size:(CGSize)itemSize callback:(void (^)(void))callback
{
    return [self addLeftItemWithTitle:title titleAttributes:nil size:itemSize leftMargin:10 callback:callback];
}

- (UIView *)addRightItemWithTitle:(NSString *)title size:(CGSize)itemSize callback:(void (^)(void))callback
{
    return [self addRightItemWithTitle:title titleAttributes:nil size:itemSize rightMargin:10 callback:callback];
}

/**
 * 添加导航条文字按钮
 *
 * @param title 按钮标题
 * @param itemSize  按钮大小
 * @param margin 按钮的左间距或右间距
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithTitle:(NSString *)title
                 titleAttributes:(NSDictionary <NSString *, id> *)attributes
                            size:(CGSize)itemSize
                      leftMargin:(CGFloat)margin
                        callback:(void (^)(void))callback
{
    objc_setAssociatedObject(self, &kAWLeftItemCallbackKey, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ( title.length == 0 || CGSizeEqualToSize(itemSize, CGSizeZero) ) {
        self.navBar.leftItem = nil;
        return nil;
    } else {
        UIButton *btn = CreateTextButtonWithSize(title, itemSize, self, @selector(aw_leftItemClick_10110:));
        
        if ( attributes[NSForegroundColorAttributeName] ) {
            [btn setTitleColor:attributes[NSForegroundColorAttributeName] forState:UIControlStateNormal];
        }
        
        if ( attributes[NSFontAttributeName] ) {
            btn.titleLabel.font = attributes[NSFontAttributeName];
        }
        
        self.navBar.leftItem = btn;
        self.navBar.leftMarginOfLeftItem = margin;
        return btn;
    }
}

- (UIView *)addRightItemWithTitle:(NSString *)title
                  titleAttributes:(NSDictionary <NSString *, id> *)attributes
                             size:(CGSize)itemSize
                      rightMargin:(CGFloat)margin
                         callback:(void (^)(void))callback
{
    objc_setAssociatedObject(self, &kAWRightItemCallbackKey, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ( title.length == 0 || CGSizeEqualToSize(itemSize, CGSizeZero) ) {
        self.navBar.rightItem = nil;
        return nil;
    } else {
        UIButton *btn = CreateTextButtonWithSize(title, itemSize, self, @selector(aw_rightItemClick_10110:));
        
        if ( attributes[NSForegroundColorAttributeName] ) {
            [btn setTitleColor:attributes[NSForegroundColorAttributeName] forState:UIControlStateNormal];
        }
        
        if ( attributes[NSFontAttributeName] ) {
            btn.titleLabel.font = attributes[NSFontAttributeName];
        }
        
        self.navBar.rightItem = btn;
        self.navBar.rightMarginOfRightItem = margin;
        return btn;
    }
}

/**
 * 添加导航条自定义视图
 *
 * @param aView 自定义视图
 * @return
 */
- (void)addLeftItemWithView:(UIView *)aView
{
    if ( aView == nil ) {
        self.navBar.leftItem = nil;
    } else {
        self.navBar.leftItem = aView;
    }
}

- (void)addRightItemWithView:(UIView *)aView
{
    if ( aView == nil ) {
        self.navBar.rightItem = nil;
    } else {
        self.navBar.rightItem = aView;
    }
}

- (void)addLeftItemWithView:(nullable UIView *)aView leftMargin:(CGFloat)margin
{
    if ( aView == nil ) {
        self.navBar.leftItem = nil;
    } else {
        self.navBar.leftItem = aView;
        self.navBar.leftMarginOfLeftItem = margin;
    }
}
- (void)addRightItemWithView:(nullable UIView *)aView rightMargin:(CGFloat)margin
{
    if ( aView == nil ) {
        self.navBar.rightItem = nil;
    } else {
        self.navBar.rightItem = aView;
        self.navBar.rightMarginOfRightItem = margin;
    }
}

@end

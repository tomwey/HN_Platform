//
//  CustomNavBar.h
//  zgnx
//
//  Created by tangwei1 on 16/5/24.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FluidBarItemPosition) {
    FluidBarItemPositionTitleLeft = 0, // 标题左边
    FluidBarItemPositionTitleRight = 1, // 标题右边
};

@interface CustomNavBar : UIView

@property (nonatomic, strong, nullable) UIImage* backgroundImage;

/**
 ! 设置左右固定位置的item
 */
@property (nonatomic, strong, nullable) UIView* leftItem;
@property (nonatomic, strong, nullable) UIView* rightItem;

/**
 ! 设置标题，最多可以显示两行
 */
@property (nonatomic, copy, nullable)   NSString* title;

/**
 ! 设置标题文字属性
 
 @see NSMutableAttributes.h
 */
@property (nonatomic, copy, nullable)   NSDictionary<NSString*, id>* titleTextAttributes;

/**
 ! 设置标题视图
 */
@property (nonatomic, strong, nullable) UIView*   titleView;

/*
 * 设置leftItem的靠左间距，默认为15
 */
@property (nonatomic, assign) CGFloat leftMarginOfLeftItem;

/**
 * 设置rightItem的靠右间距，默认为10
 */
@property (nonatomic, assign) CGFloat rightMarginOfRightItem;

/**
 * 设置非固定item的间距，默认为15
 */
@property (nonatomic, assign) CGFloat marginOfFluidItem;

/**
 ! 添加导航条非固定item
 
 如果导航条有固定的leftItem，那么被添加的靠左item会依次排在leftItem的右边，
 如果导航条没有固定的leftItem, 那么被添加的item会从leftItem的位置开始，依次添加。
 在导航条右边添加item同理。
 
 注意：如果在导航条左右都添加了太多的item，可能会导致item重叠，此处并没有做处理。
      建议不要放太多流式item
 */
- (void)addFluidBarItem:(UIView *)item atPosition:(FluidBarItemPosition)position;

@end

/// 未考虑屏幕方向
@interface UIViewController (CustomNavBar)

/**
 ! 返回一个该页面的导航条，并添加到页面顶部
 
 注意：请在已经有根视图self.view的前提下调用，否则可能会引起崩溃。
 另：如果调用此属性，请使用self.contentView存放所有该页面的子视图，不包括navBar以及navBar的子视图
 */
@property (nonatomic, strong, readonly) CustomNavBar* navBar;

/**
 ! 返回一个存放子视图的容器视图
 
 如果使用了CustomNavBar控件，那么会返回一个新的自定义的容器视图，
 并且容器视图的frame为：CGRectMake(0, navBar的高度, 全屏宽，全屏高 - navBar的高度)；
 否则返回默认的根视图self.view
 */
@property (nonatomic, strong, readonly) UIView* contentView;

@end

/// 给导航条添加item
@interface UIViewController (AddNavBarItems)

/**
 * 添加导航条图片按钮，按钮的大小为图片的大小
 *
 * @param itemImage 按钮图片
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithImage:(NSString *)itemImage  callback:(void (^)(void))callback;
- (UIView *)addRightItemWithImage:(NSString *)itemImage callback:(void (^)(void))callback;

/**
 * 添加导航条图片按钮，如果图片大小太小，则按钮的大小为指定的大小，否则为图片的大小
 *
 * @param itemImage 按钮图片
 * @param itemSize  按钮大小
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
//- (UIView *)addLeftItemWithImage:(NSString *)itemImage  size:(CGSize)itemSize callback:(void (^)(void))callback;
//- (UIView *)addRightItemWithImage:(NSString *)itemImage size:(CGSize)itemSize callback:(void (^)(void))callback;

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
                        callback:(void (^)(void))callback;

- (UIView *)addRightItemWithImage:(NSString *)itemImage
                             //size:(CGSize)itemSize
                      rightMargin:(CGFloat)margin
                         callback:(void (^)(void))callback;

/**
 * 添加导航条文字按钮
 *
 * @param title 按钮标题
 * @param itemSize  按钮大小
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithTitle:(NSString *)title  size:(CGSize)itemSize callback:(void (^)(void))callback;
- (UIView *)addRightItemWithTitle:(NSString *)title size:(CGSize)itemSize callback:(void (^)(void))callback;

/**
 * 添加导航条文字按钮
 *
 * @param title 按钮标题
 * @param attributes 按钮标题字体属性
 * @param itemSize  按钮大小
 * @param margin 按钮的左间距或右间距
 * @param callback  按钮点击回调，注意：callback可能会导致循环引用，使用是请先处理
 * @return 返回该按钮
 */
- (UIView *)addLeftItemWithTitle:(NSString *)title
                 titleAttributes:(nullable NSDictionary <NSString *, id> *)attributes
                            size:(CGSize)itemSize
                      leftMargin:(CGFloat)margin
                        callback:(void (^)(void))callback;

- (UIView *)addRightItemWithTitle:(NSString *)title
                  titleAttributes:(nullable NSDictionary <NSString *, id> *)attributes
                             size:(CGSize)itemSize
                      rightMargin:(CGFloat)margin
                         callback:(void (^)(void))callback;

/**
 * 添加导航条自定义视图
 *
 * @param aView 自定义视图
 * @return
 */
- (void)addLeftItemWithView:(nullable UIView *)aView;
- (void)addRightItemWithView:(nullable UIView *)aView;

- (void)addLeftItemWithView:(nullable UIView *)aView leftMargin:(CGFloat)margin;
- (void)addRightItemWithView:(nullable UIView *)aView rightMargin:(CGFloat)margin;

@end

NS_ASSUME_NONNULL_END

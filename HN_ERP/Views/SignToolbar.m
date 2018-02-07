//
//  SignToolbar.m
//  HN_ERP
//
//  Created by tomwey on 3/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SignToolbar.h"
#import "Defines.h"

@interface SignToolbar ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign, readwrite) BOOL checked;

@property (nonatomic, weak) UIButton *delBtn;

@property (nonatomic, weak) UIImageView *checkIcon;

@end

@implementation SignToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, AWFullScreenWidth(), 50);
    
    self.checked = NO;
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.backgroundView];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    
    // 水平线
    AWHairlineView *horizontalLine =
        [AWHairlineView horizontalLineWithWidth:self.width
                                          color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                         inView:self];
    horizontalLine.position = CGPointMake(0, 0);
    
    // 添加新增按钮
    UIButton *addBtn =
        AWCreateTextButton(CGRectMake(0, 0, 102, self.height),
                           @"添加操作人",
                           [UIColor whiteColor], self, @selector(btnClicked:));
    [self addSubview:addBtn];
    addBtn.left = self.width - addBtn.width;
    addBtn.backgroundColor = MAIN_THEME_COLOR;
    
    addBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
    
    addBtn.tag = ButtonTypeAdd;
    
    // 添加删除按钮
    UIButton *delBtn =
    AWCreateTextButton(CGRectMake(0, 0, 80, self.height),
                       @"删除",
                       [UIColor whiteColor], self, @selector(btnClicked:));
    [self addSubview:delBtn];
    delBtn.left = addBtn.left - delBtn.width;
//    delBtn.backgroundColor = AWColorFromRGB(249, 157, 33);
    delBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
    delBtn.userInteractionEnabled = NO;
    delBtn.backgroundColor = AWColorFromRGB(201, 201, 201);
    delBtn.tag = ButtonTypeDelete;
    
    self.delBtn = delBtn;
    
    // 添加全选
    UIButton *allCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:allCheck];
    allCheck.frame = CGRectMake(0, 0, 102, self.height);
//    allCheck.backgroundColor = [UIColor redColor];
    [allCheck addTarget:self
                 action:@selector(checkAll:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *checkIcon = AWCreateImageView(@"icon_checkbox.png");
    [allCheck addSubview:checkIcon];
//    checkIcon.frame = CGRectMake(0, 0, 20, 20);
    checkIcon.position = CGPointMake(15, allCheck.height / 2 - checkIcon.height / 2);
    
    self.checkIcon = checkIcon;
    
    CGRect frame = CGRectMake(checkIcon.right + 8, 0, allCheck.width - checkIcon.right - 10, allCheck.height);
                    
    UILabel *allLabel = AWCreateLabel(frame, @"全选",
                                      NSTextAlignmentLeft,
                                      AWSystemFontWithSize(15, NO),
                                      AWColorFromRGB(115, 123, 135));
    [allCheck addSubview:allLabel];
}

- (void)setEnableDeleteButton:(BOOL)enableDeleteButton
{
    _enableDeleteButton = enableDeleteButton;
    
    self.delBtn.userInteractionEnabled = enableDeleteButton;
    
    if ( enableDeleteButton ) {
        self.delBtn.backgroundColor = AWColorFromRGB(232, 160, 42);//AWColorFromHex(@"#EE4949");//AWColorFromRGB(249, 157, 33);
    } else {
        self.delBtn.backgroundColor = AWColorFromRGB(201, 201, 201);
    }
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    
    if ( checked ) {
        self.checkIcon.image = [UIImage imageNamed:@"icon_checkbox_click.png"];
    } else {
        self.checkIcon.image = [UIImage imageNamed:@"icon_checkbox.png"];
    }
}

- (void)setSelectedCheckAll:(BOOL)selectedCheckAll
{
    self.checked = selectedCheckAll;
}

- (void)checkAll:(UIButton *)sender
{
    self.checked = !self.checked;
    
    self.enableDeleteButton = self.checked;
    
    if ( self.didCheckAllBlock ) {
        self.didCheckAllBlock(self, self.checked);
    }
}

- (void)btnClicked:(UIButton *)sender
{
    if ( self.didClickBlock ) {
        self.didClickBlock(self, sender.tag);
    }
}

@end

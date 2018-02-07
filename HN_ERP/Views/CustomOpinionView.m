//
//  CustomOpinionView.m
//  HN_ERP
//
//  Created by tomwey on 3/2/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CustomOpinionView.h"
#import "Defines.h"

#define kCornerRadius 10
#define kCaretOffset  20
#define kCaretHeight  15

#define kBubbleBGColor AWColorFromRGBA(255, 255, 255, 0.7)

@interface CustomOpinionView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end
@implementation CustomOpinionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = CGRectMake(0, 0, 160, 120);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect currentFrame = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat strokeWidth = 1.0;
    
    CGFloat borderRadius = 10;
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR.CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw and fill the bubble
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, strokeWidth + 0.5f, currentFrame.size.height / 2.0);
    CGContextAddArcToPoint(context, strokeWidth + 0.5f, strokeWidth + 0.5f,
                           currentFrame.size.width / 2.0, strokeWidth + 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, strokeWidth + 0.5f,
                           currentFrame.size.width - strokeWidth - 0.5f,currentFrame.size.height / 2.0, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - 10 - strokeWidth - 0.5f,
                           currentFrame.size.width / 2.0,currentFrame.size.height - 10 - strokeWidth - 0.5f, borderRadius - strokeWidth);
    
    CGContextAddLineToPoint(context, currentFrame.size.width - borderRadius - 10 - strokeWidth - 0.5f,
                            currentFrame.size.height - 10 - strokeWidth - 0.5f);
    CGContextAddLineToPoint(context, currentFrame.size.width - borderRadius - 20 - strokeWidth - 0.5f,
                            currentFrame.size.height - strokeWidth - 0.5f);
    CGContextAddLineToPoint(context, currentFrame.size.width - borderRadius - 30 - strokeWidth - 0.5f,
                            currentFrame.size.height - 10 - strokeWidth - 0.5f);
    
    CGContextAddArcToPoint(context, strokeWidth + 0.5f, currentFrame.size.height - 10 - strokeWidth - 0.5f,
                           strokeWidth + 0.5f, currentFrame.size.height / 2.0 , borderRadius - strokeWidth);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)showInView:(UIView *)view position:(CGPoint)position
{
    
}

- (void)dismiss
{
    
}

- (void)reloadData
{
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(0, kCornerRadius,
                                      self.width,
                                      self.height - kCaretHeight - 2 * kCornerRadius);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.opinions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
    }
    
    cell.textLabel.text = self.opinions[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectOpinionBlock ) {
        self.didSelectOpinionBlock(self, self.opinions[indexPath.row]);
        self.didSelectOpinionBlock = nil;
        
        [self removeFromSuperview];
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        [_tableView removeBlankCells];
        
        _tableView.backgroundColor = [UIColor clearColor];
        
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
//        _tableView.separatorColor = kBubbleBGColor;
    }
    return _tableView;
}

@end

@implementation HNTouchView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ( self.didTouchBlock ) {
        self.didTouchBlock();
        self.didTouchBlock = nil;
    }
}

@end

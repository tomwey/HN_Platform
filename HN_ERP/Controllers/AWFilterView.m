//
//  AWFilterBaseView.m
//  HN_ERP
//
//  Created by tomwey on 28/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "AWFilterView.h"
#import "Defines.h"

@interface AWFilterView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void (^selectBlock)(AWFilterView *sender, AWFilterItem *selectedItem);

@property (nonatomic, strong) NSDateFormatter *dateFormater;

@end

#define kTableMaxHeight 44 * 5

@implementation AWFilterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        _selectedIndex = 0;
        
        self.dateFormater = [[NSDateFormatter alloc] init];
        self.dateFormater.dateFormat = @"yyyy-MM-dd";
    }
    return self;
}

- (void)setFilterItems:(NSArray<AWFilterItem *> *)filterItems
{
    _filterItems = filterItems;
    
    [self.tableView removeBlankCells];
}

- (void)setCustomFilterItems:(NSArray<AWFilterItem *> *)customFilterItems
{
    _customFilterItems = customFilterItems;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth(),
                                                            [self customFilterItemsHeight])];
    
    for (AWFilterItem *item in customFilterItems) {
        if ( item.itemType == FilterItemTypeCustomDateRange ) {
            UILabel *label = AWCreateLabel(CGRectMake(15, 0, 56, 44),
                                           @"自定义",
                                           NSTextAlignmentLeft,
                                           AWSystemFontWithSize(14, NO),
                                           AWColorFromRGB(153, 153, 153));
            [view addSubview:label];
            
            NSString *startText = @"开始日期";
            NSString *endText   = @"结束日期";
            
            if ( item.userData ) {
                if (item.userData[@"startDate"]) {
                    startText = item.userData[@"startDate"];
                }
                
                if (item.userData[@"endDate"]) {
                    endText = item.userData[@"endDate"];
                }
            }
            
            UILabel *start = AWCreateLabel(CGRectZero,
                                           startText,
                                           NSTextAlignmentCenter,
                                           AWSystemFontWithSize(14, NO),
                                           label.textColor);
            
            [view addSubview:start];
            
            start.adjustsFontSizeToFitWidth = YES;
            
            start.userInteractionEnabled = YES;
            
            [start addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(openDatePicker:)]];
            start.tag = 100;
            
            start.userData = item;
            
            AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:8
                                                                     color:label.textColor
                                                                    inView:view];
            
            UILabel *end = AWCreateLabel(CGRectZero,
                                           endText,
                                           NSTextAlignmentCenter,
                                           AWSystemFontWithSize(14, NO),
                                           label.textColor);
            
            [view addSubview:end];
            
            end.adjustsFontSizeToFitWidth = YES;
            
            end.userInteractionEnabled = YES;
            
            [end addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(openDatePicker:)]];
            end.tag = 101;
            
            end.userData = item;
            
            UIButton *okBtn = AWCreateTextButton(CGRectMake(view.width - 50 - 15, 5, 50, 34),
                                                 @"确定",
                                                 MAIN_THEME_COLOR,
                                                 self,
                                                 @selector(ok:));
            [view addSubview:okBtn];
            
            okBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
            
            okBtn.layer.borderWidth = 0.6;
            okBtn.layer.borderColor = MAIN_THEME_COLOR.CGColor;
            
            okBtn.userData = item;
            
            CGFloat width = (okBtn.left - label.right - 18 - 10) / 2.0;
            start.frame = CGRectMake(label.right,
                                     5,
                                     width, 34);
            
            line.center = CGPointMake(start.right + 5 + 5, label.midY);
            
            end.frame = CGRectMake(line.right + 5, 5, width, 34);
     
            start.layer.borderColor = AWColorFromRGB(153, 153, 153).CGColor;
            start.layer.borderWidth = 0.6;
            
            end.layer.borderColor = AWColorFromRGB(153, 153, 153).CGColor;
            end.layer.borderWidth = 0.6;
        }
    }
    
    self.tableView.tableFooterView = view;
}

- (void)ok:(UIButton *)sender
{
    self.selectedIndex = -1;
    if ( self.selectBlock ) {
        self.selectBlock(self, sender.userData);
    }
    
    [self dismiss];
}

- (void)openDatePicker:(UIGestureRecognizer *)sender
{
    UILabel *label = (UILabel *)sender.view;
    
    DatePicker *picker = [[DatePicker alloc] init];
    picker.frame = self.superview.bounds;
    [picker showPickerInView:self.superview];
    
    AWFilterItem *item = label.userData;
    
    NSDate *date = [NSDate date];
    if (item.userData) {
        if ( label.tag == 100 ) {
            NSDate *startDate = [self.dateFormater dateFromString:item.userData[@"startDate"]];
            if ( startDate ) {
                date = startDate;
            }
            
            UILabel *endLabel = (UILabel *)[self.tableView.tableFooterView viewWithTag:101];
            picker.minimumDate = nil;
            
            NSDate *date = [self.dateFormater dateFromString:endLabel.text];
            if ( date ) {
                picker.maximumDate = date;
            }
            
        } else if (label.tag == 101) {
            NSDate *startDate = [self.dateFormater dateFromString:item.userData[@"endDate"]];
            if ( startDate ) {
                date = startDate;
            }
            
            UILabel *startLabel = (UILabel *)[self.tableView.tableFooterView viewWithTag:100];
            picker.maximumDate = nil;
            
            NSDate *date = [self.dateFormater dateFromString:startLabel.text];
            if ( date ) {
                picker.minimumDate = date;
            }
        }
    }
    
    picker.currentSelectedDate = date;
    
    __weak typeof(self) me = self;
    picker.didSelectDateBlock = ^(DatePicker *picker, NSDate *selectedDate) {
        
        NSMutableDictionary *dict = [item.userData ?: @{} mutableCopy];
        if ( label.tag == 100 ) {
            // 设置开始日期
            [dict setObject:[self.dateFormater stringFromDate:selectedDate] forKey:@"startDate"];
        } else if ( label.tag == 101 ) {
            // 设置截止日期
            [dict setObject:[self.dateFormater stringFromDate:selectedDate] forKey:@"endDate"];
        }
        
        label.text = [me.dateFormater stringFromDate:selectedDate];
        item.userData = [dict copy];
    };
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0
                                                    blue:153/255.0
                                                   alpha:1.0];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    cell.textLabel.textColor = [UIColor colorWithRed:231/255.0 green:90/255.0
                                                blue:22/255.0
                                               alpha:1.0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds),
                                      [self filterItemsHeight] +
                                      [self customFilterItemsHeight]
                                      );
}

- (CGFloat)filterItemsHeight
{
    return MIN(self.filterItems.count * self.tableView.rowHeight, kTableMaxHeight);
}

- (CGFloat)customFilterItemsHeight
{
    return self.customFilterItems.count * 44;
}

- (void)showInView:(UIView *)superView
       selectBlock:(void (^)(AWFilterView *sender, AWFilterItem *selectedItem))selectBlock
{
    self.selectBlock = selectBlock;
    
    if ( !self.superview ) {
        [superView addSubview:self];
    }
    
    [superView bringSubviewToFront:self];
    
    self.maskView.alpha = 0.0;
    
    CGFloat height = [self filterItemsHeight];
    
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
    
//    [UIView animateWithDuration:.3
//                     animations:^{
                         self.maskView.alpha = 0.6;
                         self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame),
                                                           height + [self customFilterItemsHeight]);
//                     } completion:^(BOOL finished) {
//                         
//                     }];
    
        [self.tableView reloadData];
    
    self.tableView.scrollEnabled = self.filterItems.count > 5;
}

- (void)dismiss
{
//    [UIView animateWithDuration:.3
//                     animations:^{
//                         self.maskView.alpha = 0.0;
//                         self.tableView.alpha = 0.0;
////                         self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
//                     } completion:^(BOOL finished) {
//                         [self removeFromSuperview];
//                     }];
    
    [self removeFromSuperview];
}

- (void)dealloc
{
    NSLog(@"filterview dealloc");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filterItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
        cell.tintColor = [UIColor colorWithRed:231/255.0 green:90/255.0
                                          blue:22/255.0
                                         alpha:1.0];
    }
    
    AWFilterItem *item = self.filterItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    cell.textLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0
                                                blue:153/255.0
                                               alpha:1.0];
    
    if ( self.selectedIndex == indexPath.row ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        cell.textLabel.textColor = [UIColor colorWithRed:231/255.0 green:90/255.0
                                                    blue:22/255.0
                                                   alpha:1.0];
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndex = indexPath.row;
    
    if ( self.selectBlock ) {
        self.selectBlock(self, self.filterItems[indexPath.row]);
    }
    
//    [self resetCustomValue];
    
    [self dismiss];
}

//- (void)resetCustomValue
//{
//    for (AWFilterItem *item in self.customFilterItems) {
//        item.userData = nil;
//    }
//    
//    [self setCustomFilterItems:self.customFilterItems];
//}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.6;
        
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(dismiss)]];
    }
    return _maskView;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)
                                                  style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.rowHeight = 44;
        
//        _tableView.tableFooterView = [[UIView alloc] init];
        
//        _tableView.scrollEnabled = NO;
    }
    
    [self bringSubviewToFront:_tableView];
    
    return _tableView;
}

@end

@implementation AWFilterItem

- (instancetype)initWithName:(NSString *)name value:(id)value type:(FilterItemType)type
{
    if ( self = [super init] ) {
        self.name = name;
        self.value = value;
        self.itemType = type;
    }
    return self;
}

@end


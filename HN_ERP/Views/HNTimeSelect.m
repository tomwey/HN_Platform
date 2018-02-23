//
//  HNTimeSelect.m
//  HN_ERP
//
//  Created by tomwey on 9/6/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNTimeSelect.h"
#import "SelectButton.h"
#import "Defines.h"

@interface HNTimeSelect ()

@property (nonatomic, strong) DMButton *quarterButton;
@property (nonatomic, strong) DMButton *monthButton;
@property (nonatomic, strong) DMButton *weekButton;

@property (nonatomic, strong) NSArray *yearData;

@property (nonatomic, strong) NSMutableArray *quarterData;
@property (nonatomic, strong) NSMutableArray *monthData;
@property (nonatomic, strong) NSMutableArray *weekData;

@end

@implementation HNTimeSelect

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        
        self.quarterData = [@[] mutableCopy];
        self.monthData = [@[] mutableCopy];
        self.weekData  = [@[] mutableCopy];
        
        _quarter     = -1;
        _month       = -1;
        _weekOfMonth = -1;
        
        self.yearData  = @[@{
                              @"id": @"0",
                              @"name": @"全部",
                              @"months": @[],
                              },
                          @{
                              @"id": @"1",
                              @"name": @"1季度",
                              @"months": @[@(1),@(2),@(3)],
                              },
                          @{
                              @"id": @"2",
                              @"name": @"2季度",
                              @"months": @[@(4),@(5),@(6)],
                              },
                          @{
                              @"id": @"3",
                              @"name": @"3季度",
                              @"months": @[@(7),@(8),@(9)],
                              },
                          @{
                              @"id": @"4",
                              @"name": @"4季度",
                              @"months": @[@(10),@(11),@(12)],
                              },
                          ];

//        [self initData];
    }
    
    return self;
}

- (void)prepareInitData
{
    [self initData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = 0;
    CGFloat width   = (self.width) / 3.0;
    
    self.quarterButton.frame =
    self.monthButton.frame   =
    self.weekButton.frame    =
    CGRectMake(0, 0, width, self.height);
    
    self.quarterButton.position = CGPointMake(0, 0);
    self.monthButton.position   = CGPointMake(self.quarterButton.right + padding,
                                              0);
    self.weekButton.position    = CGPointMake(self.monthButton.right + padding, 0);
}

- (void)initData
{
    NSDate *date = [NSDate date];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [currentCalendar components:
                            NSCalendarUnitYear |
                            NSCalendarUnitQuarter |
                            NSCalendarUnitMonth |
                            NSCalendarUnitWeekOfMonth
                                              fromDate:date];
    
    [self prepareQuarterData:dc.month];
    
    self.year = dc.year;
    
    if (self.needUpdateWeekOfMonth)
        self.month = dc.month;
}

- (void)setQuarter:(NSInteger)quarter
{
    if ( _quarter != quarter ) {
        _quarter = quarter;
        
        self.month = 0;
        
        if (quarter == 0) {
            self.quarterButton.title = @"全部";
        } else {
            self.quarterButton.title = [NSString stringWithFormat:@"%d季度", quarter];
        }
        
        self.quarterButton.userData = @{ @"name": self.quarterButton.title,
                                         @"value": [@(quarter) description]
                                       };
        
        // 准备月数据
        [self prepareMonthData];
    }
}

- (void)setMonth:(NSInteger)month
{
    if ( _month != month ) {
        _month = month;
        self.weekOfMonth = 0;
        if (month == 0) {
            self.monthButton.title = @"全部";
        } else {
            self.monthButton.title = [NSString stringWithFormat:@"%d月", month];
        }
        
        self.monthButton.userData = @{ @"name": self.monthButton.title,
                                       @"value": [@(month) description]
                                       };
        // 准备周数据
        [self loadWeekData];
    }
}

- (void)setWeekOfMonth:(NSInteger)weekOfMonth
{
    if ( _weekOfMonth != weekOfMonth ) {
        _weekOfMonth = weekOfMonth;
        
        if (weekOfMonth == 0) {
            self.weekButton.title = @"全部";
        } else {
            self.weekButton.title = [NSString stringWithFormat:@"第%d周", weekOfMonth];
        }
        
        self.weekButton.userData = [self currentWeekData];
    }
}

- (id)currentWeekData
{
    for (id obj in self.weekData) {
        if ( [obj[@"id"] integerValue] == self.weekOfMonth ) {
            return @{ @"name": obj[@"name"],
                      @"value": [@(self.weekOfMonth) description]};
        }
    }
    return nil;
}

- (void)didUpdateTimeSelect
{
    if ( self.timeSelectDidChange ) {
        self.timeSelectDidChange(self);
    }
}

- (id)currentQuarterDataForMonth:(NSInteger)month
{
    for (id obj in self.yearData) {
        NSArray *months = obj[@"months"];
        if ( [months containsObject:@(month)] ) {
            return obj;
        }
    }
    return nil;
}

- (void)prepareQuarterData:(NSInteger)month
{
    // 准备季度数据
    
    id currentQuarter = [self currentQuarterDataForMonth:month];
    
    [self.quarterData removeAllObjects];
    
    for (int i=0;i<[currentQuarter[@"id"] integerValue]+1; i++) {
        [self.quarterData addObject:self.yearData[i]];
    }
    
    self.quarter = [currentQuarter[@"id"] integerValue];
}

- (void)prepareMonthData
{
    // 准备月数据
    [self.monthData removeAllObjects];
    
    [self.monthData addObject:@{ @"id": @"0",
                                 @"name": @"全部"}];
    
    id quarterData = [self currentQuarterData];
    
    NSArray *months = quarterData[@"months"];
    
    for (id o in months) {
        [self.monthData addObject:@{
                                    @"id": [o description],
                                    @"name": [NSString stringWithFormat:@"%@月", o]
                                    }];
    }
}

- (id)currentQuarterData
{
    for (id obj in self.quarterData) {
        if ( [obj[@"id"] integerValue] == self.quarter ) {
            return obj;
        }
    }
    
    return nil;
}

- (void)loadWeekData
{
    [self.weekData removeAllObjects];
    [self.weekData addObject:@{
                               @"id": @"0",
                               @"name": @"全部"
                               }];
    
    if (self.year == 0 || self.month == 0) return;
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"BI签约回款月份周数据查询APP",
              @"param1": [@(self.year) description],
              @"param2": [@(self.month) description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    if ( error ) {
        
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            NSArray *data = result[@"data"];
            for (int i=1; i<data.count; i++) {
                id obj = data[i];
                NSString *bDate = obj[@"begindate"];
                NSString *eDate = obj[@"enddate"];
                
                if ( bDate.length > 5 ) {
                    bDate = [bDate substringFromIndex:5];
                    bDate = [bDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
                }
                
                if ( eDate.length > 5 ) {
                    eDate = [eDate substringFromIndex:5];
                    eDate = [eDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
                }
                
                [self.weekData addObject:@{
                                           @"id": obj[@"week"],
                                           @"name": [NSString stringWithFormat:@"第%@周(%@-%@)",
                                                     obj[@"week"], bDate, eDate],
                                           @"bDate": obj[@"begindate"] ?: @"",
                                           @"eDate": obj[@"enddate"] ?: @"",
                                           }];
            }
            
        }
    }
    
    if (self.needUpdateWeekOfMonth) {
        self.weekOfMonth = [self weekOfMonthForNow];
    }
    
    self.weekButton.userData = [self currentWeekData];
}

- (NSInteger)weekOfMonthForNow
{
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateStr = [df stringFromDate:date];
    
    for (int i=1; i<self.weekData.count; i++) {
        id obj = self.weekData[i];
        if ( [obj[@"bDate"] compare:dateStr options:NSNumericSearch] == NSOrderedSame ||
            [obj[@"eDate"] compare:dateStr options:NSNumericSearch] == NSOrderedSame) {
            return [obj[@"id"] integerValue];
        } else if ( [obj[@"bDate"] compare:dateStr options:NSNumericSearch] == NSOrderedAscending &&
            [obj[@"eDate"] compare:dateStr options:NSNumericSearch] == NSOrderedDescending) {
            return [obj[@"id"] integerValue];
        }
    }
    
    return 0;
}

- (void)openPickerForData:(NSArray *)data forButton:(DMButton *)sender
{
    UIView *superView = self.containerView ?: self.superview;
    
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = superView.bounds;
    
    id currentOption = sender.userData;
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        NSString *name = dict[@"name"];
        id value = dict[@"id"];
        id pair = @{ @"name": name,
                     @"value": [value description]
                     };
        [temp addObject:pair];
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:superView];
    
    //    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *inSender, id selectedOption, NSInteger index) {
        
        if ( sender == self.quarterButton ) {
            NSInteger quarter = [selectedOption[@"value"] integerValue];
            if ( self.quarter != quarter ) {
                self.quarter = quarter;
                
                [self didUpdateTimeSelect];
            }
            
        } else if ( sender == self.monthButton ) {
            NSInteger month = [selectedOption[@"value"] integerValue];
            if ( self.month != month ) {
                self.month = month;
                
                [self didUpdateTimeSelect];
            }
        } else if ( sender == self.weekButton ) {
            NSInteger weekOfMonth = [selectedOption[@"value"] integerValue];
            if ( self.weekOfMonth != weekOfMonth ) {
                self.weekOfMonth = weekOfMonth;
                
                [self didUpdateTimeSelect];
            }
        }
        
        sender.userData = selectedOption;
        
    };
}

- (DMButton *)quarterButton
{
    if ( !_quarterButton ) {
        _quarterButton = [[DMButton alloc] init];
        [self addSubview:_quarterButton];
        
        __weak typeof(self) me = self;
//        _quarterButton.clickBlock = ^(SelectButton *sender) {
//            [me openPickerForData:me.quarterData forButton:sender];
//        };
        _quarterButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.quarterData forButton:sender];
        };
    }
    return _quarterButton;
}

- (DMButton *)monthButton
{
    if ( !_monthButton ) {
        _monthButton = [[DMButton alloc] init];
        [self addSubview:_monthButton];
        
        __weak typeof(self) me = self;
        _monthButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.monthData forButton:sender];
        };
//        _monthButton.clickBlock = ^(SelectButton *sender) {
//            [me openPickerForData:me.monthData forButton:sender];
//        };
    }
    return _monthButton;
}

- (DMButton *)weekButton
{
    if ( !_weekButton ) {
        _weekButton = [[DMButton alloc] init];
        [self addSubview:_weekButton];
        
        __weak typeof(self) me = self;
        _weekButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.weekData forButton:sender];
        };
//        _weekButton.clickBlock = ^(SelectButton *sender) {
//            [me openPickerForData:me.weekData forButton:sender];
//        };
    }
    return _weekButton;
}

@end

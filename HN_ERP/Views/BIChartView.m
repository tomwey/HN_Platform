//
//  BIChartView.m
//  HN_ERP
//
//  Created by tomwey on 4/27/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "BIChartView.h"
#import "PNChart.h"
#import "Defines.h"

@interface BIChartView ()

@property (nonatomic, strong) PNPieChart *chartView;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *realLabel;

@property (nonatomic, strong) UILabel *centerLabel;

@end

@implementation BIChartView

- (void)setChartData:(id)chartData
{
    if ( _chartData == chartData ) return;
    
    _chartData = chartData;
    
    CGFloat plan = [chartData[@"plan"] floatValue];
    CGFloat real = [chartData[@"real"] floatValue];
    
    CGFloat rate;
    if ( plan == 0 ) {
        rate = 0;
    } else {
        rate = real / plan;
    }
    
    if ( rate < 0 ) {
        rate = 0;
    } else if ( rate > 1.0 ) {
        rate = 1.0;
    }
    
    int value;
    UIColor *leftColor = AWColorFromRGB(224, 224, 224);
    
    NSArray *items = nil;
    if ( rate == 0 ) {
        value = 0;
        items = @[[PNPieChartDataItem dataItemWithValue:value color:leftColor]];
    } else if ( rate == 1.0 ) {
        value = 100;
        items = @[[PNPieChartDataItem dataItemWithValue:value color:MAIN_THEME_COLOR]];
    } else {
        value = (int)(rate * 100);
        items =
        @[[PNPieChartDataItem dataItemWithValue:value
                                          color:MAIN_THEME_COLOR],
          [PNPieChartDataItem dataItemWithValue:(100 - value)
                                          color:leftColor],
          ];
    }
    
    if ( !self.chartView ) {
        self.chartView = [[PNPieChart alloc] initWithFrame:CGRectZero
                                                     items:items];
        [self addSubview:self.chartView];
        
        [self.chartView addGestureRecognizer:
         [[UITapGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(tap)]];
        
        self.chartView.shouldHighlightSectorOnTouch = NO;
//        self.chartView.innerCircleRadius = 200;
        
        self.chartView.hideValues = YES;
        
//        [self.chartView recompute];
    } else {
        [self.chartView updateChartData:items];
    }
    
    [self.chartView strokeChart];
    
    if ( [chartData[@"type"] integerValue] == 1 ) {
        // 签约
        self.centerLabel.text = [NSString stringWithFormat:@"%d%%\n签约",value];
    } else {
        // 汇款
        self.centerLabel.text = [NSString stringWithFormat:@"%d%%\n回款", value];
    }
    
    if ( ![chartData[@"flag"] boolValue] ) {
        self.centerLabel.text = @"完成率";
    }
    
    self.planLabel.text = [NSString stringWithFormat:@"计划：%.2f亿", plan];
    self.realLabel.text = [NSString stringWithFormat:@"实际：%.2f亿", real];
    
    if ( [chartData[@"flag"] boolValue] ) {
//        self.planLabel.hidden = NO;
        self.realLabel.hidden = NO;
//        self.centerLabel.hidden = NO;
    } else {
//        self.planLabel.hidden = YES;
        self.realLabel.hidden = YES;
        
//        self.centerLabel.hidden = YES;
    }
    
    self.realLabel.textColor = MAIN_THEME_COLOR;
    
    [self setNeedsLayout];
}

- (void)tap
{
    if ( ![self.chartData[@"flag"] boolValue] ) {
        return;
    }
//    NSLog(@"tap...");
    if ( self.didClickChartBlock ) {
        self.didClickChartBlock(self);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.chartView.frame = CGRectMake(0, 0, 240, 240);
    self.chartView.center = CGPointMake(self.width / 2, self.chartView.height / 2);
    
    self.centerLabel.frame = CGRectMake(0, 0, 60, 60);
    self.centerLabel.center = self.chartView.center;
    
    self.planLabel.frame = CGRectMake(0, 0, self.chartView.width, 30);
    self.planLabel.center = CGPointMake(self.chartView.midX, self.chartView.bottom + 20 + self.planLabel.height / 2);
    
    self.realLabel.frame = self.planLabel.frame;
    self.realLabel.top = self.planLabel.bottom + 5;
}

- (UILabel *)planLabel
{
    if ( !_planLabel ) {
        _planLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   nil,
                                   AWColorFromRGB(58, 58, 58));
        [self addSubview:_planLabel];
    }
    return _planLabel;
}

- (UILabel *)realLabel
{
    if ( !_realLabel ) {
        _realLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   nil,
                                   self.planLabel.textColor);
        [self addSubview:_realLabel];
    }
    return _realLabel;
}

- (UILabel *)centerLabel
{
    if ( !_centerLabel ) {
        _centerLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   nil,
                                   self.planLabel.textColor);
        [self addSubview:_centerLabel];
        _centerLabel.numberOfLines = 2;
    }
    return _centerLabel;
}

@end

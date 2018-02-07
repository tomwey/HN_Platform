//
//  OutputInfoVC.m
//  HN_ERP
//
//  Created by tomwey on 29/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "OutputInfoVC.h"
#import "Defines.h"

@interface OutputInfoVC ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation OutputInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"产值合同信息";
    
//    NSLog(@"%@", self.params);
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // 项目
    UILabel *label1 = AWCreateLabel(CGRectMake(15, 15, self.contentView.width - 30,
                                               30),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, YES),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label1];
    
    label1.text = [NSString stringWithFormat:@"%@%@", [self.params[@"area"] areaName],
                   [self.params[@"project"] projectName]];
    
    // 合同
    UILabel *label2 = AWCreateLabel(CGRectMake(15, label1.bottom + 5,
                                               self.contentView.width - 30,
                                               50),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label2];
    label2.numberOfLines = 2;
    label2.adjustsFontSizeToFitWidth = YES;
    
    label2.text = self.params[@"item"][@"contractname"];
    
    UIColor *textColor = AWColorFromRGB(74, 74, 74);
    // 产值
    UILabel *planLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       textColor);
    [self.scrollView addSubview:planLabel];
    
    NSString *planMoney = [NSString stringWithFormat:@"%@\n本月计划产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthplan"], @"万")];
    planLabel.numberOfLines = 2;
    
    NSRange range1 = [planMoney rangeOfString:@"万"];
    //    range.length = range.location;
    //    range.location = 0;
    NSRange range2 = NSMakeRange(0, range1.location);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:planMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(12, NO)}
                    range:range1];
    
    planLabel.attributedText = string;
    [planLabel sizeToFit];
    
    planLabel.position = CGPointMake(15, label2.bottom + 10);
    
    // 实际产值
    UILabel *realLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(12, NO),
                                       textColor);
    [self.scrollView addSubview:realLabel];
    NSString *realMoney = [NSString stringWithFormat:@"%@\n本月实际产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthfact"], @"万")];
    realLabel.numberOfLines = 2;
    
    range1 = [realMoney rangeOfString:@"万"];
    range2 = NSMakeRange(0, range1.location);
    
    string = [[NSMutableAttributedString alloc] initWithString:realMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(12, NO)}
                    range:range1];
    
    realLabel.attributedText = string;
    [realLabel sizeToFit];
    
    realLabel.center = CGPointMake(self.contentView.width / 2.0, planLabel.midY);
    
    // 本月应付产值
    UILabel *totalLabel = AWCreateLabel(CGRectZero,
                                        nil,
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(12, NO),
                                        textColor);
    
    [self.scrollView addSubview:totalLabel];
    
    NSString *totalMoney = [NSString stringWithFormat:@"%@\n本月应付产值",
                            HNFormatMoney(self.params[@"item"][@"curmonthpayable"], @"万")];
    totalLabel.numberOfLines = 2;
    
    range1 = [totalMoney rangeOfString:@"万"];
    range2 = NSMakeRange(0, range1.location);
    
    string = [[NSMutableAttributedString alloc] initWithString:totalMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(12, NO)}
                    range:range1];
    
    totalLabel.attributedText = string;
    [totalLabel sizeToFit];
    
    totalLabel.center = CGPointMake(self.contentView.width - 15 - totalLabel.width / 2.0, planLabel.midY);
    
    // 累计实际产值
    UILabel *totalRealLabel = AWCreateLabel(CGRectZero,
                                            nil,
                                            NSTextAlignmentLeft,
                                            AWSystemFontWithSize(12, NO),
                                            textColor);
    [self.scrollView addSubview:totalRealLabel];
    totalRealLabel.frame = CGRectMake(15, totalLabel.bottom + 5,
                                      (self.contentView.width - 35) / 2.0, 30);
    
    totalRealLabel.adjustsFontSizeToFitWidth = YES;
    
    AWLabelFormatShow(totalRealLabel,
                      @"累计实际产值",
                      [HNFormatMoney(self.params[@"item"][@"contractfactoutvalue"], @"万")
                       stringByReplacingOccurrencesOfString:@"万" withString:@""],
                      @"万",
                      AWCustomFont(@"PingFang SC", 18),
                      MAIN_THEME_COLOR,
                      YES);
    // 累计应付产值
    UILabel *totalYFLabel = AWCreateLabel(CGRectZero,
                                          nil,
                                          NSTextAlignmentRight,
                                          AWSystemFontWithSize(12, NO),
                                          textColor);
    [self.scrollView addSubview:totalYFLabel];
    totalYFLabel.frame = totalRealLabel.frame;
    totalYFLabel.left  = totalRealLabel.right + 5;
    
    totalYFLabel.adjustsFontSizeToFitWidth = YES;
    
    AWLabelFormatShow(totalYFLabel,
                      @"累计应付产值",
                      [HNFormatMoney(self.params[@"item"][@"contractpayableoutvalue"], @"万")
                       stringByReplacingOccurrencesOfString:@"万" withString:@""],
                      @"万",
                      AWCustomFont(@"PingFang SC", 18),
                      MAIN_THEME_COLOR,
                      YES);
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

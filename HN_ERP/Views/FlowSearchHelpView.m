//
//  FlowSearchHelpView.m
//  HN_ERP
//
//  Created by tomwey on 3/1/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowSearchHelpView.h"
#import "Defines.h"

@interface FlowSearchHelpView ()

@property (nonatomic, strong) UILabel  *errorOrEmptyLabel;
@property (nonatomic, strong) AWButton *searchButton;

@property (nonatomic, strong) UILabel  *searchTipLabel;

@end

@implementation FlowSearchHelpView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.searchButton.center = CGPointMake(self.width / 2, self.height / 2);
    
    self.errorOrEmptyLabel.frame = CGRectMake(0, 0, self.width * 0.8, 34);
    self.errorOrEmptyLabel.center = CGPointMake(self.width / 2,
                                                self.searchButton.top - 30 - self.errorOrEmptyLabel.height / 2);
    
    self.searchTipLabel.frame = CGRectMake(0, 0, self.width * 0.8, 90);
    self.searchTipLabel.center = CGPointMake(self.width / 2,
                                             self.searchButton.bottom + 10 + self.searchTipLabel.height / 2);
}

- (void)setErrorOrEmptyMessage:(NSString *)errorOrEmptyMessage
{
    _errorOrEmptyMessage = errorOrEmptyMessage;
    self.errorOrEmptyLabel.text = errorOrEmptyMessage;
}

- (void)setSearchButtonTitle:(NSString *)searchButtonTitle
{
    _searchButtonTitle = searchButtonTitle;
    self.searchButton.title = searchButtonTitle;
}

- (UILabel *)errorOrEmptyLabel
{
    if ( !_errorOrEmptyLabel ) {
        _errorOrEmptyLabel = AWCreateLabel(CGRectZero,
                                           @"<无数据显示>",
                                           NSTextAlignmentCenter,
                                           AWSystemFontWithSize(14, NO),
                                           AWColorFromRGB(201, 201, 201));
        [self addSubview:_errorOrEmptyLabel];
    }
    return _errorOrEmptyLabel;
}

- (AWButton *)searchButton
{
    if ( !_searchButton ) {
        _searchButton = [AWButton buttonWithTitle:@"去搜索" color:MAIN_THEME_COLOR];
        [self addSubview:_searchButton];
        _searchButton.frame = CGRectMake(0, 0, 80, 40);
        _searchButton.titleAttributes = @{ NSFontAttributeName: AWSystemFontWithSize(14, NO) };
        _searchButton.outline = YES;
        [_searchButton addTarget:self forAction:@selector(btnClicked:)];
    }
    return _searchButton;
}

- (UILabel *)searchTipLabel
{
    if ( !_searchTipLabel ) {
        _searchTipLabel = AWCreateLabel(CGRectZero,
                                        @"或\n\n点击右上角“搜索按钮”",
                                        NSTextAlignmentCenter,
                                        AWSystemFontWithSize(15, NO),
                                        AWColorFromRGB(201, 201, 201));
        [self addSubview:_searchTipLabel];
        _searchTipLabel.numberOfLines = 4;
    }
    return _searchTipLabel;
}

- (void)btnClicked:(AWButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kForwardToSearchVCNotification" object:nil];
}

@end

//
//  MeetingOrderedView.m
//  HN_ERP
//
//  Created by tomwey on 5/12/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingOrderedView.h"
#import "Defines.h"

@interface MeetingOrderedView () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *tableContainerView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, copy) void (^selectCallback)(id item);
@property (nonatomic, copy) void (^closeCallback)(void);

@end

@implementation MeetingOrderedView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = AWFullScreenBounds();
    }
    return self;
}

+ (void)showInView:(UIView *)superView
       queryParams:(QueryParams *)params
    selectCallback:(void (^)(id item))callback
     closeCallback:(void (^)(void))closeCallback
{
    MeetingOrderedView *aView = [[MeetingOrderedView alloc] init];
    [superView addSubview:aView];
    [superView bringSubviewToFront:aView];
    
    aView.selectCallback = callback;
    aView.closeCallback = closeCallback;
    
    aView.tag = 110210;
    
    [aView showWithQueryParams:params];
}

+ (void)hideForView:(UIView *)superView animated:(BOOL)animated
{
    MeetingOrderedView *aView = (MeetingOrderedView *)[superView viewWithTag:110210];
    [aView hide];
}

- (void)showWithQueryParams:(QueryParams *)params
{
    self.maskView.alpha = 0.0;
    
    self.tableContainerView.top = - self.tableContainerView.height;
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.tableContainerView.top = 0;
    } completion:^(BOOL finished) {
        
    }];
    
    [self loadDataWithQueryParams:params];
}

- (void)loadDataWithQueryParams:(QueryParams *)params
{
    [self.spinner startAnimating];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateString = [df stringFromDate:params.currentDate];
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"会议室预定查询APP",
                       @"param1": params.meetingRoomId,
                       @"param2": dateString ?: @"",
                       }
     completion:^(id result, NSError *error)
     {
         [weakSelf handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [self.spinner stopAnimating];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            self.dataSource = result[@"data"];
        } else {
            self.dataSource = nil;
            [self.tableView showErrorOrEmptyMessage:@"<暂无预定>"
                                     reloadDelegate:nil];
        }
        
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfCols
{
    return 2;
}

- (NSInteger)numberOfRows
{
    NSInteger cols = [self numberOfCols];
    if (cols <= 0) return 0;
    
    return (self.dataSource.count + cols - 1 ) / cols;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self addContentsForCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)addContentsForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger totalCols = [self numberOfCols];
    NSInteger cols = totalCols;
    if (indexPath.row == [self numberOfRows] - 1) {
        cols = self.dataSource.count -  indexPath.row * totalCols;
    }
    
    // 移除因为重用导致的多出来的Grid
    for (int i=cols; i<totalCols; i++) {
        [[cell.contentView viewWithTag:100 + i] removeFromSuperview];
    }
    
    CGFloat padding = 15;
    CGFloat width = ( self.width - padding * ( totalCols + 1 ) ) / totalCols;
    for (int i=0; i<cols; i++) {
        UIButton *textBtn = (UIButton *)[cell.contentView viewWithTag:100 + i];
        if ( !textBtn ) {
            textBtn = AWCreateTextButton(CGRectZero,
                                         nil,
                                         AWColorFromRGB(133, 133, 133), self,
                                         @selector(btnClicked:));
            [cell.contentView addSubview:textBtn];
            textBtn.tag = 100 + i;
            
            textBtn.frame = CGRectMake(0, 0, width, 50);
            textBtn.position = CGPointMake(padding + ( width + padding ) * i, self.tableView.rowHeight / 2 - textBtn.height / 2);
            textBtn.cornerRadius = 8;
            textBtn.backgroundColor = [UIColor whiteColor];
            
            textBtn.layer.borderWidth = 0.6;
            textBtn.layer.borderColor = [textBtn titleColorForState:UIControlStateNormal].CGColor;
            
            textBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
        }
        
        NSInteger index = indexPath.row * totalCols + i;
        if ( index < self.dataSource.count ) {
            textBtn.userData = self.dataSource[index];
            [textBtn setTitle:[self formatOrderTime:textBtn.userData] forState:UIControlStateNormal];
        }
        
    }
}

- (NSString *)formatOrderTime:(id)item
{
    NSString *orderDate = [[item[@"orderdate"] componentsSeparatedByString:@"T"] firstObject];
    NSString *beginTime = [[[item[@"begintime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
    NSString *endTime   =
    [[[item[@"endtime"] componentsSeparatedByString:@"T"] lastObject] substringToIndex:5];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *prefix = nil;
    NSString *now = [df stringFromDate:[NSDate date]];
    if ( [orderDate isEqualToString:now] ) {
        prefix = @"今天";
    } else if ( [orderDate compare:now options:NSNumericSearch] == NSOrderedDescending ) {
        prefix = @"明天";
    } else {
        prefix = orderDate;
    }
    
    return [NSString stringWithFormat:@"%@ %@-%@",prefix, beginTime, endTime];
}


- (void)btnClicked:(UIButton *)sender
{
    if ( self.selectCallback ) {
        self.selectCallback(sender.userData);
    }
    
    [self hide];
}

- (void)hide
{
    if ( self.closeCallback ) {
        self.closeCallback();
    }
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.tableContainerView.top = - self.tableContainerView.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_maskView];
        
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.0;
        
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    }
    return _maskView;
}

- (UIView *)tableContainerView
{
    if ( !_tableContainerView ) {
        _tableContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 216)];
        [self addSubview:_tableContainerView];
        _tableContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _tableContainerView;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.tableContainerView.bounds
                                                  style:UITableViewStylePlain];
        [self.tableContainerView addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (UIActivityIndicatorView *)spinner
{
    if ( !_spinner ) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.hidesWhenStopped = YES;
        
        [self.tableContainerView addSubview:_spinner];
        
        _spinner.center = CGPointMake(self.tableContainerView.width / 2,
                                      self.tableContainerView.height / 2);
    }
    return _spinner;
}

@end

@implementation QueryParams


@end

//
//  EmploySearchView.m
//  HN_ERP
//
//  Created by tomwey on 3/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "EmploySearchView.h"
#import "Defines.h"
#import "EmployCell.h"
#import "AddContactsModel.h"

@interface EmploySearchView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL searching;

@property (nonatomic, copy) void (^completionBlock)(void);

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, assign, readwrite) CGSize searchResultsBoxSize;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation EmploySearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
//        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
}

- (void)startSearching:(NSString *)keyword
            atPosition:(CGPoint)position
       completionBlock:(void (^)(void))completionBlock
{
    if ([keyword trim].length == 0) {
        if ( self.completionBlock ) {
            self.completionBlock();
        }
        return;
    }
    
    self.hidden = NO;
    
    self.maskView.hidden = NO;
    
    self.tableView.position = position;
    
    self.tipLabel.hidden = YES;
    
    self.completionBlock = completionBlock;
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"selman",
                       @"manname": keyword,
                       } completion:^(id result, NSError *error) {
                           [me handleResult:result error:error];
                       }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    if ( self.completionBlock ) {
        self.completionBlock();
    }
    
    if ( error ) {
//        self.tableView.hidden = YES;
//        
//        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
        self.tipLabel.text = @"加载失败了";
        self.tipLabel.hidden = NO;
    } else {
        [self.dataSource removeAllObjects];
        
        if ( [result[@"rowcount"] integerValue] > 0 ) {
            
            NSArray *data = result[@"data"];
            for (id dict in data) {
                
                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                item[@"checked"] = @(NO);
                item[@"icon"] = @"default_avatar.png";
                item[@"id"]   = dict[@"man_id"] ?: @"";
                item[@"itype"] = @"0";
                item[@"job"] = dict[@"station_name"] ?: @"";
                item[@"level"] = dict[@"safelevel"] ?: @"";
                item[@"name"] = dict[@"man_name"] ?: @"";
                item[@"pid"] = dict[@"topdept_id"] ?: @"";
                item[@"supports_selecting"] = @(NO);
                
                Employ *emp = [[Employ alloc] initWithDictionary:item];
                
                [self.dataSource addObject:emp];
            }
            
            [self.tableView reloadData];
        } else {
            [self.tableView reloadData];
            
            self.tipLabel.text = @"<未搜索到结果>";
            self.tipLabel.hidden = NO;
//            [self.tableView showErrorOrEmptyMessage:@"<未搜索到结果>"
//                                     reloadDelegate:nil];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployCell *cell = (EmployCell *)[tableView dequeueReusableCellWithIdentifier:@"employ.cell"];
    if ( !cell ) {
        cell = [[EmployCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"employ.cell"];
    }
    
    if ( indexPath.row < self.dataSource.count ) {
        cell.employ = self.dataSource[indexPath.row];
    }
    
    return cell;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self, nil);
    }
    
    [self stopSearching];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self, self.dataSource[indexPath.row]);
    }
    
    [self stopSearching];
}

- (void)stopSearching
{
    self.hidden = YES;
}

- (void)setSearchResultsBoxPosition:(CGPoint)searchResultsBoxPosition
{    
    _searchResultsBoxPosition = searchResultsBoxPosition;
    self.tableView.position = searchResultsBoxPosition;
    
    self.tipLabel.center = self.tableView.center;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.3;
        [self addSubview:_maskView];
    }
    return _maskView;
}

- (UILabel *)tipLabel
{
    if ( !_tipLabel ) {
        _tipLabel = AWCreateLabel(CGRectMake(0, 0, self.tableView.width, 34),
                                  nil,
                                  NSTextAlignmentCenter,
                                  AWSystemFontWithSize(14, NO),
                                  AWColorFromRGB(201, 201, 201));
        [self addSubview:_tipLabel];
    }
    
    [self bringSubviewToFront:_tipLabel];
    
    return _tipLabel;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        self.searchResultsBoxSize = CGSizeMake(AWFullScreenWidth() * 0.618, 150);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.searchResultsBoxSize.width, self.searchResultsBoxSize.height) style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        _tableView.rowHeight = 60;
        
        _tableView.layer.borderColor = IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR.CGColor;
        _tableView.layer.borderWidth = 0.5;
        _tableView.layer.cornerRadius = 2;
        
        _tableView.clipsToBounds = YES;
        
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        
        [_tableView removeBlankCells];
    }
    
    [self bringSubviewToFront:_tableView];
    
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end

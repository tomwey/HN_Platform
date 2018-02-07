//
//  MeetingListView.m
//  HN_ERP
//
//  Created by tomwey on 5/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MeetingListView.h"
#import "Defines.h"
#import "MeetingCell.h"

@interface MeetingListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, copy) void (^completionBlock)(MeetingListView *sender);

@property (nonatomic, copy) NSString *dataType;

@end

@implementation MeetingListView

- (void)startLoadingWithParams:(NSDictionary *)params
                    completion:(void (^)(MeetingListView *sender))completion
{
    self.completionBlock = completion;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
//    NSString *dateString = [df stringFromDate:params[@"date"]] ?: @"";
    
    self.dataType = params[@"type"];
    
    __weak typeof(self) weakSelf = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"按周查询会议列表APP",
              @"param1": params[@"man_id"],
              @"param2": params[@"type"],
              @"param3": params[@"firstDate"] ?: @"",
              @"param4": params[@"lastDate"] ?: @"",
              }
     completion:^(id result, NSError *error) {
         [weakSelf handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    if ( self.completionBlock ) {
        self.completionBlock(self);
    }
    
    [self.tableView removeErrorOrEmptyTips];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription
                                 reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:LOADING_REFRESH_NO_RESULT reloadDelegate:nil];
            self.dataSource = nil;
        } else {
            NSArray *data = result[@"data"];
            NSMutableArray *temp = [NSMutableArray array];
            
            NSMutableSet *allKeys = [NSMutableSet set];
            for(id dict in data) {
                [allKeys addObject:dict[@"orderdate"] ?: @""];
            }
            
            NSArray *keys = [allKeys allObjects];
            keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            
            for (NSString *key in keys) {
                NSMutableDictionary *dict = [@{} mutableCopy];
                NSMutableArray *arr = [@[] mutableCopy];
                
                [dict setObject:arr forKey:key];
                
                for (id obj in data) {
                    if ([key isEqualToString:obj[@"orderdate"]]) {
                        id item = [obj mutableCopy];
                        item[@"data_type"] = self.dataType;
                        [arr addObject:item];
                    }
                }
                
                [temp addObject:dict];
            }
            
//            NSLog(@"temp: %@", temp);
            
//            for (id dict in data) {
//                id item = [dict mutableCopy];
//                item[@"data_type"] = self.dataType;
//                [temp addObject:item];
//            }
            self.dataSource = temp;//result[@"data"];
        }
        [self.tableView reloadData];
    }
}

//- (AWTableViewDataSource *)dataSource
//{
//    if ( !_dataSource ) {
//        _dataSource = AWTableViewDataSourceCreate(nil,
//                                                  @"MeetingCell",
//                                                  @"meeting.cell");
//    }
//    return _dataSource;
//}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        [self addSubview:_tableView];
        
        _tableView.dataSource = self;//self.dataSource;
        _tableView.delegate   = self;
        
//        _tableView.backgroundColor = AWColorFromRGB(245, 245, 245);
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 66;
        
//        [_tableView removeCompatibility];
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id dict = self.dataSource[section];
    NSString *key = [[dict allKeys] firstObject];
    
    return [dict[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meeting.cell"];
    
    if ( !cell ) {
        cell = [[MeetingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"meeting.cell"];
    }
    
    id dict = self.dataSource[indexPath.section];
    NSString *key = [[dict allKeys] firstObject];
    id data = dict[key][indexPath.row];
    
    [cell configData:data selectBlock:nil];
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    id dict = self.dataSource[section];
//    NSString *key = [[dict allKeys] firstObject];
//    return HNDateFromObject(key, @"T");
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.backgroundView.backgroundColor = [UIColor darkGrayColor];
    
    header.textLabel.font = AWSystemFontWithSize(14, NO);
    header.textLabel.textColor = AWColorFromHex(@"#b7b7b7");
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header.cell"];
    if ( !view ) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header.cell"];
    }
    
    id dict = self.dataSource[section];
    NSString *key = [[dict allKeys] firstObject];
//    view.textLabel.text = HNDateFromObject(key, @"T");
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateStr = HNDateFromObject(key, @"T");
    
    NSDate *date = [df dateFromString:dateStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dc = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday
                fromDate:date];
    
//    NSLog(@"%@", calendar.weekdaySymbols[dc.weekday-1]);
    
    view.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", calendar.weekdaySymbols[dc.weekday-1], dateStr];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id dict = self.dataSource[indexPath.section];
    NSString *key = [[dict allKeys] firstObject];
    id data = dict[key][indexPath.row];
    
    
    id item = [data mutableCopy];
    
    item[@"data_type"] = self.dataType ?: @"0";
    
    if ([self.dataType integerValue] == 0 && self.didSelectMeetingItemBlock ) {
        self.didSelectMeetingItemBlock(item);
    }
}

@end

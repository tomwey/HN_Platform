//
//  AttendanceFlowVC.m
//  HN_ERP
//
//  Created by tomwey on 7/13/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AttendanceFlowVC.h"
#import "Defines.h"

@interface AttendanceFlowVC ()

@property (nonatomic, copy) NSString *exceptionTypes;

@property (nonatomic, strong) NSMutableArray *inFormControls;

@end

@implementation AttendanceFlowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"考勤异常流程";
    
    __weak typeof(self) me = self;
    [self addRightItemWithTitle:@"提交" size:CGSizeMake(60, 40) callback:^{
        [me doCommit];
    }];
    
    self.exceptionTypes = @"公出,指纹未录入,指纹模糊,设备故障,忘记打卡";
    
    self.inFormControls = [@[] mutableCopy];
    
    [self addLeftItemWithView:HNCloseButton(30, self, @selector(close))];
    
    [self loadExceptTypes];
}

- (void)doCommit
{
    NSLog(@"%@", self.formObjects);
    
    NSArray *allKeys = [self.formObjects allKeys];
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *key in allKeys) {
        if ( [key rangeOfString:@"."].location != NSNotFound ) {
            NSString *prefix = [[key componentsSeparatedByString:@"."] firstObject];
            [set addObject:prefix];
        }
    }
    
    NSArray *arr = [[set allObjects] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    if ( arr.count == 0 ) {
        [self.contentView showHUDWithText:@"异常时间和异常类型必需" offset:CGPointMake(0, 20)];
        
        return;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *key in arr) {
        NSDate *dateTime = self.formObjects[[NSString stringWithFormat:@"%@.time",key]];
        
        if (!dateTime) {
            [self.contentView showHUDWithText:@"异常时间必选" offset:CGPointMake(0, 20)];
            
            return;
        }
        
        id type = self.formObjects[[NSString stringWithFormat:@"%@.type",key]];
        
        if (!type) {
            [self.contentView showHUDWithText:@"异常类型必选" offset:CGPointMake(0, 20)];
            
            return;
        }
        
        NSString *date = [[[df stringFromDate:dateTime] componentsSeparatedByString:@" "] firstObject];
        NSString *time = [[[df stringFromDate:dateTime] componentsSeparatedByString:@" "] lastObject];
        
        NSString *desc = self.formObjects[[NSString stringWithFormat:@"%@.desc",key]] ?: @"";
        
        NSDictionary *dict = @{
                               @"date": date ?: @"",
                               @"time": time ?: @"",
                               @"summary": desc,
                               @"type": type[@"value"] ?: @"",
                               };
        
        [temp addObject:dict];
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:temp
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"考勤异常流程发起APP",
              @"param1": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"",
              @"param2": manID,
              @"param3": self.formObjects[@"opinion"] ?: @"请审批",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if (error) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        [self resetForm];
        [self.contentView showHUDWithText:@"提交成功" succeed:YES];
    }
}

- (void)loadExceptTypes
{
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"考勤异常类型查询APP",
              } completion:^(id result, NSError *error) {
                  if ([result[@"rowcount"] integerValue] > 0) {
                      NSMutableArray *temp = [NSMutableArray array];
                      for (id dict in result[@"data"]) {
                          [temp addObject:dict[@"dic_name"]];
                      }
                      
                      me.exceptionTypes = [temp componentsJoinedByString:@","];
                  }
                  
                  [self updateFormControls];
              }];
}

- (void)updateFormControls
{
    
    for (NSInteger index = 0; index < [self.params[@"errors"] count]; index ++) {
        NSString *fieldName = [NSString stringWithFormat:@"attend_%d", index];
        
        [self.inFormControls addObject:@{
                                         @"data_type": @"18",
                                         @"datatype_c": @"考勤异常组件",
                                         @"describe": @"考勤异常",
                                         @"field_name": fieldName,
                                         @"item_name": self.exceptionTypes,
                                         @"item_value": self.exceptionTypes,
                                         }];
    }
    
    [self formControlsDidChange];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)formControls
{
    return self.inFormControls;
}

@end

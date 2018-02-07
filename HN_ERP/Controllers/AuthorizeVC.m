//
//  AuthorizeVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "AuthorizeVC.h"
#import "Defines.h"

@interface AuthorizeVC ()

@property (nonatomic, strong) NSMutableArray *selectedPeople;
@property (nonatomic, strong) UIButton *contactButton;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation AuthorizeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navBar.title = @"授权处理";
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addContact:)
                                                 name:@"kContactDidSelectNotification"
                                               object:nil];*/
}

- (void)addContact:(NSNotification *)noti
{
    [self hideKeyboard];
    
    if ( [noti.object isKindOfClass:[NSArray class]] ) {
        self.formObjects[@"contact"] = [noti.object firstObject];
        
        [self.tableView reloadData];
    }
}

- (NSArray *)formControls
{
    return @[@{
                 @"data_type": @"5",
                 @"datatype_c": @"添加单人",
                 @"describe": @"被授权人",
                 @"field_name": @"contact",
                 @"item_name": @"",
                 @"item_value": @"",
                 }];
}

- (NSDictionary *)apiParams
{
    //    mid(流程ID值),nodeid(节点ID),manid(操作人员ID),getmanids(接收者IDs, 中间以','号间隔), getmannames(接收者名称s, 中间以','号间隔), opinion(意见)
    Employ *item = [self.formObjects[@"contact"] firstObject];
    return @{
             @"dotype": @"flow",
             @"type": @"authorize",
             @"nodeid": self.params[@"nodeid"],
             @"getmanids": [item._id description] ?: @"",
             @"getmannames": item.name ?: @"",
             @"opinion_allow_null": self.params[@"opinion_allow_null"],
             };
}

@end

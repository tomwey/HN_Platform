//
//  FlowcopyVC.m
//  HN_ERP
//
//  Created by tomwey on 9/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowcopyVC.h"
#import "Defines.h"

@interface FlowcopyVC ()

@end

@implementation FlowcopyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *titleAttributes = @{ NSFontAttributeName: AWSystemFontWithSize(16, NO) };
    CGSize size = [@"复制" sizeWithAttributes:titleAttributes];
    size.width += 20;
    size.height = 40;
    
    __weak typeof(self) me = self;
    [self addRightItemWithTitle:@"复制"
                titleAttributes:titleAttributes
                           size:size
                    rightMargin:5
                       callback:^{
                           [me doCopy];
                       }];
}

- (NSArray *)formControls
{
    return @[@{
                 @"data_type": @"6",
                 @"datatype_c": @"添加多人",
                 @"describe": @"接收人",
                 @"field_name": @"contacts",
                 @"item_name": @"",
                 @"item_value": @"",
                 }];
}

- (void)doCopy
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    if ( [self.formObjects[@"contacts"] count] == 0 ) {
        [self.contentView showHUDWithText:@"接收人不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *ids  = [NSMutableArray array];
    for (id item in self.formObjects[@"contacts"]) {
        [temp addObject:[item name]];
        [ids addObject:[[item _id] description]];
    }
    
    NSString *opinion = self.formObjects[@"opinion"] ?: @"";
    
    if ( opinion.length == 0 ) {
        [self.contentView showHUDWithText:@"意见不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    [self hideKeyboard];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"流程复制",
              @"param1": [self.params[@"mid"] ?: @"" description],
              @"param2": manID,
              @"param3": [ids componentsJoinedByString:@","],
              @"param4": [temp componentsJoinedByString:@","],
              @"param5": [opinion description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        [self.navigationController.view showHUDWithText:@"流程复制成功" succeed:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)supportsAttachment
{
    return NO;
}

@end

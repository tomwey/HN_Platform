//
//  FlowOperationVC.m
//  HN_ERP
//
//  Created by tomwey on 1/23/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FlowOperationVC.h"
#import "Defines.h"

@interface FlowOperationVC ()

@property (nonatomic, copy, readwrite) NSString *manId;
@property (nonatomic, strong) UITextView *feedbackTextView;

@end

@implementation FlowOperationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.navBar.title = self.params[@"action"][@"name"];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    self.manId = manID;
    
    __weak typeof(self) me = self;
    [self addRightItemWithTitle:@"提交" size:CGSizeMake(40, 40) callback:^{
        [me doSend];
    }];
}

- (UITextView *)addFeedbackTextViewForFrame:(CGRect)frame inView:(UIView *)superView
{
    self.feedbackTextView.frame = frame;
    self.feedbackTextView.placeholder = @"签字意见";
    if ( superView ) {
        [superView addSubview:self.feedbackTextView];
    } else {
        [self.contentView addSubview:self.feedbackTextView];
    }
    return self.feedbackTextView;
}

- (UITextView *)feedbackTextView
{
    if ( !_feedbackTextView ) {
        _feedbackTextView = [[UITextView alloc] init];
//        _feedbackTextView.placeholder = @"签字意见";
        _feedbackTextView.layer.borderWidth = 0.5;
        _feedbackTextView.layer.borderColor = [AWColorFromRGB(199,199,199) CGColor];
        _feedbackTextView.backgroundColor = [UIColor clearColor];
    }
    return _feedbackTextView;
}

- (void)doSend
{
    if ( ![self apiParams] || [[self apiParams] count] == 0 ) {
        NSLog(@"没有设置提交参数");
        return;
    }
    
    NSMutableDictionary *params = [[self apiParams] mutableCopy];
    params[@"opinion"] = [self.feedbackTextView.text trim];
    params[@"did"] = [self.params[@"did"] description];
    
    NSLog(@"API Params:\n%@", params);
    
    [self.feedbackTextView resignFirstResponder];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:params completion:^(id result, NSError *error) {
         [me handleResult:result error:error];
     }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        [self.contentView makeToast:error.domain];
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
//        [self.navigationController.view makeToast:@"处理成功"];
        [self.navigationController.view showHUDWithText:@"处理成功" succeed:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFlowHandleSuccessNotification" object:nil];
        
        UIViewController *vc = [[self.navigationController viewControllers] firstObject];
        if ( [NSStringFromClass([vc class]) isEqualToString:@"LoginVC"] ) {
            [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (NSDictionary *)apiParams
{
    return nil;
}

@end

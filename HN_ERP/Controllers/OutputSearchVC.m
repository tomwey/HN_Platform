//
//  OutputSearchVC.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputSearchVC.h"
#import "Defines.h"

@interface OutputSearchVC ()

@property (nonatomic, strong) DMButton *areaButton;
@property (nonatomic, strong) DMButton *projButton;

@property (nonatomic, strong) NSMutableArray *outputAreas;
@property (nonatomic, strong) NSMutableDictionary *outputProjects;

@property (nonatomic, strong) OutputQueryParams *queryParams;

@end

@implementation OutputSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"合同高级搜索";
    
    UIButton *closeBtn = HNCloseButton(34, self, @selector(close));
    [self addLeftItemWithView:closeBtn leftMargin:2];
    
    self.queryParams = self.params[@"queryParams"];
    
    self.outputAreas = self.params[@"areas"];
    self.outputProjects = self.params[@"projects"];
    
    self.areaButton.frame = self.projButton.frame = CGRectMake(0, 0, self.contentView.width / 2,40);
    self.projButton.left = self.areaButton.right;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:AWColorFromRGB(201, 201, 201)
                                                            inView:self.contentView];
    line.position = CGPointMake(0, self.areaButton.bottom - 1);
    
    line = [AWHairlineView verticalLineWithHeight:self.areaButton.height
                                            color:AWColorFromRGB(201, 201, 201)
                                           inView:self.contentView];
    line.position = CGPointMake(self.areaButton.right, 0);
    
    [self setDefaultAreaProjects];
    
    
    self.tableView.height -= 40;
    self.tableView.top = 40;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)formControls
{
    return @[@{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"合同名称",
                 @"field_name": @"contract_name",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"1",
                 @"datatype_c": @"文本框",
                 @"describe": @"乙方名称",
                 @"field_name": @"supname",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"13",
                 @"datatype_c": @"日期范围选择框",
                 @"describe": @"产值计划月份",
                 @"field_name": @"plan_date",
                 @"sub_describe": @"起始月,截止月",
                 @"split_desc": @"至",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"14",
                 @"datatype_c": @"单选按钮",
                 @"describe": @"产值计划确认状态",
                 @"field_name": @"has_confirm",
                 @"item_name": @"已确认,未确认",
                 @"item_value": @"1,0",
                 },
             @{
                 @"data_type": @"13",
                 @"datatype_c": @"日期范围选择框",
                 @"describe": @"产值确认月份",
                 @"field_name": @"confirm_date",
                 @"sub_describe": @"起始月,截止月",
                 @"split_desc": @"至",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             @{
                 @"data_type": @"6",
                 @"datatype_c": @"添加多个人",
                 @"describe": @"创建人",
                 @"field_name": @"contacts",
                 @"item_name": @"",
                 @"item_value": @"",
                 },
             ];
}

- (void)setDefaultAreaProjects
{
    OutputArea *defaultArea = self.params[@"currentArea"];
    
    if ( !defaultArea ) {
        defaultArea = [self.outputAreas firstObject];
    }
    
    OutputProject *project = self.params[@"currentProject"];
    if ( !project ) {
        project = [self.outputProjects[defaultArea.areaId] firstObject];
    }
    
    self.areaButton.userData = defaultArea;
    self.projButton.userData = project;
    
    self.areaButton.title = defaultArea.areaName;
    self.projButton.title = project.projectName;
    
    self.queryParams.projID = project.projectId;
}

- (void)openPickerForData:(NSArray *)data sender:(DMButton *)sender
{
    if ( data.count == 0 ) {
        return;
    }
    
    UIView *superView = self.contentView;
    
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = superView.bounds;
    
    id currentOption = [sender.userData performSelector:@selector(shortItem) withObject:nil];
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        [temp addObject:[dict performSelector:@selector(shortItem) withObject:nil]];
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:superView];
    
    //    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *inSender, id selectedOption, NSInteger index) {
        
        if ( sender == self.areaButton ) {
            
            if ( ![selectedOption isEqualToDictionary:[self.areaButton.userData performSelector:@selector(shortItem) withObject:nil]] ) {
                sender.userData = data[index];
                self.projButton.title = @"选择项目";
            }
            
        } else if ( sender == self.projButton ) {
            
            if ( ![selectedOption isEqualToDictionary:[self.projButton.userData performSelector:@selector(shortItem) withObject:nil]] ) {
                sender.userData = data[index];
                
                self.queryParams.projID = [self.projButton.userData projectId];
                
//                [self startLoad];
            }
        }
        
        sender.title = selectedOption[@"name"];
        
    };
}

- (DMButton *)areaButton
{
    if ( !_areaButton ) {
        _areaButton = [[DMButton alloc] init];
        [self.contentView addSubview:_areaButton];
        
        __weak typeof(self) me = self;
        _areaButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.outputAreas sender:sender];
        };
        
        //        _areaButton.title = @"成都";
    }
    return _areaButton;
}

- (DMButton *)projButton
{
    if ( !_projButton ) {
        _projButton = [[DMButton alloc] init];
        [self.contentView addSubview:_projButton];
        
        __weak typeof(self) me = self;
        _projButton.selectBlock = ^(DMButton *sender) {
            OutputArea *area = me.areaButton.userData;
            [me openPickerForData:me.outputProjects[area.areaId] sender:sender];
        };
        //        _projButton.title = @"枫丹一期";
    }
    return _projButton;
}

@end

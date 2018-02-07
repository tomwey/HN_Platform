//
//  ContactsVC.m
//  HN_ERP
//
//  Created by tomwey on 1/17/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContactsVC.h"
#import "Defines.h"
#import "ContactInfo.h"
#import "ContactSectionInfo.h"
#import "AWSectionHeaderView.h"

@interface ContactsVC () <UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, SectionHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSArray *contactsSections;

@property (nonatomic) NSInteger openSectionIndex;

@end

@implementation ContactsVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                        image:[UIImage imageNamed:@"tab_contact.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_contact_click.png"]];
    }
    return self;
}

- (void)prepareContactsData
{
    self.contacts = [[NSMutableArray alloc] init];
    
    ContactInfo *info = [[ContactInfo alloc] init];
    info.title = @"成都合能房地产有限公司";
    info.icon  = @"contact_icon_logo.png";
    
    info.contacts = @[[[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"集团总部"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"成都合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"西安合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"成都合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"西安合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"成都合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"西安合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"成都合能"],
                      [[ContactInfo alloc] initWithIcon:@"create_sub_dept_line.png" title:@"西安合能"],
                      ];
    
    [self.contacts addObject:info];
    
//    ContactInfo *info2 = [[ContactInfo alloc] init];
//    info2.title = @"创建团队";
//    info2.icon  = @"contact_icon_add.png";
//    
//    [self.contacts addObject:info2];
//    
    ContactInfo *info3 = [[ContactInfo alloc] init];
    info3.title = @"集团总部-信息技术部-应用开发组";
    info3.icon  = @"contact_icon_normal.png";
    info3.contacts = @[[[ContactInfo alloc] initWithIcon:@"contact_icon_normal.png" title:@"吴思静"],
                       [[ContactInfo alloc] initWithIcon:@"contact_icon_normal.png" title:@"唐伟"],
                       [[ContactInfo alloc] initWithIcon:@"contact_icon_normal.png" title:@"左勇"],
                       [[ContactInfo alloc] initWithIcon:@"contact_icon_normal.png" title:@"鲜代明"],
                       [[ContactInfo alloc] initWithIcon:@"contact_icon_normal.png" title:@"景超"]];
//
    [self.contacts addObject:info3];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (ContactInfo *info in self.contacts) {
        ContactSectionInfo *sinfo = [[ContactSectionInfo alloc] init];
        sinfo.contact = info;
        sinfo.open = NO;
        
        NSInteger countOfContacts = [sinfo.contact.contacts count];
        for (NSInteger i = 0; i < countOfContacts; i++) {
            [sinfo insertObject:@60 inRowHeightsAtIndex:i];
        }
        
        [temp addObject:sinfo];
    }
    self.contactsSections = temp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"通讯录";
    
//    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self addLeftItemWithView:nil];
    
    [self prepareContactsData];
    
    self.openSectionIndex = NSNotFound;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    
    [self.contentView addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.tableView.rowHeight = 60;
    self.tableView.sectionHeaderHeight = 60;
    
    [self.tableView removeBlankCells];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 45)];
    tableHeader.backgroundColor = [UIColor whiteColor];
    [tableHeader addSubview:self.searchController.searchBar];
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR inView:tableHeader];
    line.position = CGPointMake(0, self.searchController.searchBar.bottom);
    
    self.tableView.tableHeaderView = tableHeader;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"count: %d", self.contacts.count);
    return self.contacts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ContactSectionInfo *secInfo = self.contactsSections[section];
    NSInteger count = secInfo.open ? [secInfo.contact.contacts count] : 0;
    NSLog(@"section: %d, count: %d", section, count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell.id"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ContactInfo *cInfo = [[self.contactsSections[indexPath.section] contact] contacts][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:cInfo.icon];
    
    if ( indexPath.section != 0 || indexPath.row == 0 ) {
        cell.imageView.layer.cornerRadius = 20;
        cell.imageView.clipsToBounds = YES;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    if ( indexPath.section == 0 && indexPath.row == 0 ) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    cell.textLabel.text = cInfo.title;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    AWSectionHeaderView *sectionHeaderView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"section.id"];
    if ( !sectionHeaderView ) {
        sectionHeaderView = [[AWSectionHeaderView alloc] init];
        sectionHeaderView.frame = CGRectMake(0, 0, self.contentView.width, 60);
//        sectionHeaderView.reuseIdentifier = @"section.id";
    }
    
//    NSLog(@"section: %d", section);
    
    ContactSectionInfo *sectionInfo = self.contactsSections[section];
    sectionInfo.headerView = sectionHeaderView;
    sectionInfo.headerView.opened = sectionInfo.open;
    
    sectionHeaderView.sectionData = sectionInfo.contact;
    
    sectionHeaderView.section = section;
    
    sectionHeaderView.delegate = self;
    
    return sectionHeaderView;
}

- (void)sectionHeaderView:(AWSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    
    ContactSectionInfo *sectionInfo = (self.contactsSections)[sectionOpened];
    
    if (sectionInfo.open) return;
    
    sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.contact.contacts count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        
//        ContactSectionInfo *previousOpenSection = (self.contactsSections)[previousOpenSectionIndex];
//        previousOpenSection.open = NO;
//        [previousOpenSection.headerView setOpened:NO animated:YES];
//        NSInteger countOfRowsToDelete = [previousOpenSection.contact.contacts count];
//        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
//            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
//        }
    }
    
    // style the animation so that there's a smooth flow in either direction
    UITableViewRowAnimation insertAnimation;
//    UITableViewRowAnimation deleteAnimation;
//    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
//        NSLog(@"1");
//        insertAnimation = UITableViewRowAnimationTop;
//        deleteAnimation = UITableViewRowAnimationBottom;
//    }
//    else {
//        NSLog(@"2");
//        insertAnimation = UITableViewRowAnimationBottom;
//        deleteAnimation = UITableViewRowAnimationTop;
//    }

//    if (sectionOpened == self.contacts.count - 1) {
//        insertAnimation = UITableViewRowAnimationBottom;
//    } else {
        insertAnimation = UITableViewRowAnimationAutomatic;
//    }
    // apply the updates
//    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
//    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
//    [self.tableView endUpdates];
    
    self.openSectionIndex = sectionOpened;
}

- (void)sectionHeaderView:(AWSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
    ContactSectionInfo *sectionInfo = (self.contactsSections)[sectionClosed];
    
    if (!sectionInfo.open) return;
    
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (UISearchController *)searchController
{
    if ( !_searchController ) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        
//        self.searchController.dimsBackgroundDuringPresentation = false;
        [_searchController.searchBar sizeToFit];
        
        _searchController.searchBar.placeholder = @"找人";
        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        
        self.searchController.searchBar.backgroundImage
        = AWImageFromColor(AWColorFromRGB(255, 255, 255));
    }
    return _searchController;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}

@end

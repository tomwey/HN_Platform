//
//  Defines.h
//  deyi
//
//  Created by tangwei1 on 16/9/2.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#import "AWMacros.h"

#import "AWGeometry.h"

#import "AWUITools.h"

#import "AWTextField.h"

#import "AWTableView.h"

#import "AWHairlineView.h"

#import "AWAPIManager.h"

#import "NSStringAdditions.h"
#import "NSDataAdditions.h"

#import "AWMediator.h"

#import "MBProgressHUD.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+ProgressIndicator.h"

#import "APIManager.h"

#import "UIWebView+RemoveGrayBackground.h"

#import "SVPullToRefresh.h"

//#import "UIButton+UserData.h"
#import "NSObject+UserData.h"

#define IOS_DEFAULT_NAVBAR_BOTTOM_LINE_COLOR  AWColorFromRGB(163, 164, 165)
#define IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR AWColorFromRGB(187, 188, 193)

#define MAIN_THEME_COLOR      AWColorFromRGB(231, 90, 22)

#define MAIN_BG_COLOR         AWColorFromRGB(255, 255, 255)
#define NAV_BAR_BG_COLOR      AWColorFromRGB(44,154,248)//AWColorFromRGB(50, 69, 255)
#define CONTENT_VIEW_BG_COLOR AWColorFromRGB(239, 239, 239)
#define MAIN_BLUE_COLOR       AWColorFromRGB(44,154,248)//AWColorFromRGB(38, 133, 247)

#define HOME_HAIRLINE_COLOR   MAIN_BG_COLOR//AWColorFromRGB(240, 240, 242)

#define BUTTON_COLOR          MAIN_THEME_COLOR//AWColorFromRGB(44,154,248)

#define LOADING_REFRESH_NO_RESULT @"<无数据显示>"
#define LOADING_MORE_NO_RESULT    @"没有更多数据了"

////// API接口
#define API_HOST      @"http://erp20-app.heneng.cn:16681"
#define H5_HOST       @"http://erp20.heneng.cn:16669"//@"http://erp2017-mobile.heneng.cn:8088" // @"https://erp20.heneng.cn:16669"

#define API_KEY    @"27654725447"
#define API_SECRET @"dfjhskdhsiwnvhkjhdguwnvbxmn"
#define AES_KEY    @"666AA4DF3533497D973D852004B975BC"

#define API_LOGIN          @"login" // username, password
#define API_TODO           @"todo"  // manid, flowdesc, createmainid, flowtype, pageindex
#define API_MAN_CARD       @"mancard" // manid
#define API_FLOW_BACK_LIST @"flowbacklist" // mid 流程ID, manid 处理人员ID

#define CHECK_VER_CODE     @""
#define IS_EXIST_USER_INFO @""
#define SEND_VER_CODE      @""
#define ADD_USER_INFO      @""
#define NFC_APP_URL        @""

#import "ParamUtil.h"

#import "NSDataAdditions.h"

#import "AWTableView.h"

#import "HNCacheHelper.h"

#import "AWLocationManager.h"

#import "UIViewController+CreateFactory.h"
#import "NSObject+RTIDataService.h"
#import "UITableView+RefreshControl.h"

#import "AppDelegate.h"

#import "CustomNavBar.h"

#import "AWButton.h"

#import "NetworkService.h"

#import "UIView+Toast.h"

#import "AWTextField.h"

#import "UITextView+AWPlaceholder.h"

#import "UIImageView+CustomAvatar.h"

#import "AWLoadingStateBaseView.h"
#import "AWLoadingStateView.h"

#import "NSDate+NVTimeAgo.h"

#import "APIService.h"

//#import "NSObject+APIService.h"

#import "UITableView+LoadEmptyOrErrorHandle.h"

#import "SVProgressHUD.h"
#import "DGActivityIndicatorView.h"

#import "ValuesUtils.h"
#import "ButtonHelper.h"
#import "HNAlertHelper.h"

#import "FontAwesomeKit.h"

#import "ValuesUtils.h"

// Models
#import "User.h"
#import "Employ.h"
#import "AppManager.h"
#import "Breadcrumb.h"
#import "HNCache.h"
//#import "AttachmentOperator.h"
#import "AddContactsModel.h"
#import "OfficeDocProtocol.h"

#import "OutputArea.h"
#import "OutputProject.h"
#import "OutputCatalog.h"
#import "OutputQueryParams.h"

// Services
#import "UserService.h"
#import "VersionCheckService.h"
#import "StoreService.h"
#import "HNNewFlowCountService.h"
#import "AttachmentDownloadService.h"
#import "HNBadgeService.h"
#import "SysLogService.h"
//#import "SearchHistoryService.h"

// Views
#import "SettingTableHeader.h"

#import "OAListView.h"
#import "PagerTabStripper.h"
#import "SwipeView.h"
#import "SelectPicker.h"
#import "AWPagerTabStrip.h"
#import "DocumentView.h"
#import "HNImageHelper.h"
#import "HNProgressHUDHelper.h"
#import "HNRefreshView.h"
#import "HNLoadingView.h"
#import "DMButton.h"

#import "PlanListView.h"
#import "PlanDocView.h"
#import "PlanProjectView.h"
#import "LandListView.h"
#import "MeetingRoom.h"
#import "DateSelectControl.h"
#import "DatePicker.h"
#import "FlowSubmitAlert.h"

#import "UIView+MBProgressHUD.h"

#import "FlowSearchHelpView.h"

#import "CustomOpinionView.h"

#import "SignCell.h"
#import "SignToolbar.h"

#import "HNBadge.h"

#import "Checkbox.h"

#import "SalaryPasswordView.h"
#import "SalaryPasswordUpdateView.h"

//#import "ExpandCellHeader.h"

// Controllers
//#import "WebViewVC.h"
#import "EmploySearchVC.h"

#endif /* Defines_h */

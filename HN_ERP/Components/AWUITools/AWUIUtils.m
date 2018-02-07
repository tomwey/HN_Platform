//
//  AWUIUtils.m
//  BayLe
//
//  Created by tangwei1 on 15/11/19.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#import "AWUIUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "sys/utsname.h"

@interface NBTarget : NSObject <UIWebViewDelegate>

+ (instancetype)sharedInstance;

@end

@implementation NBTarget

+ (instancetype)sharedInstance
{
    static NBTarget *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ( error.code == 101 ) {
        [[[UIAlertView alloc] initWithTitle:@"您还未安装QQ，不能打开"
                                    message:@""
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"确定", nil] show];
    }
}

@end

/**
 * 返回当前设备运行的iOS版本
 */
float AWOSVersion()
{
    return [AWOSVersionString() floatValue];
}

NSString* AWOSVersionString()
{
    return [[UIDevice currentDevice] systemVersion];
}

NSString* AWDeviceName()
{
    struct utsname name;
    uname(&name);
    
    NSString *machine = [NSString stringWithCString:name.machine encoding:NSUTF8StringEncoding];
    
    return machine;
}

NSString *AWDevicePlatformString()
{
    NSString *platform = AWDeviceName();
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return [UIDevice currentDevice].localizedModel;
}

NSString *AWDeviceCountryLangCode()
{
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    return [NSString stringWithFormat:@"%@_%@", languageCode ?: @"zh", countryCode ?: @"CN"];
}

NSString* AWDeviceSizeString()
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    int width = AWFullScreenWidth() * scale;
    int height = AWFullScreenHeight() * scale;
    
    return [NSString stringWithFormat:@"%dx%d", width, height];
}

/**
 * 检查当前设备运行的iOS版本是否小于给定的版本
 */
BOOL AWOSVersionIsLower(float version)
{
    return AWOSVersion() < version;
}

/**
 * 判断设备是否是iPad
 */
BOOL AWIsPad()
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

//BOOL AWIsKeyboardVisible()
//{
//    UIWindow* window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
//    
//    return !![window findFirstResponder];
//}

/**
 * 返回全屏大小
 */
CGRect AWFullScreenBounds()
{
    return [[UIScreen mainScreen] bounds];
}

/**
 * 全屏宽
 */
CGFloat AWFullScreenWidth()
{
    return CGRectGetWidth(AWFullScreenBounds());
}

/**
 * 全屏高
 */
CGFloat AWFullScreenHeight()
{
    return CGRectGetHeight(AWFullScreenBounds());
}

CGFloat AWHairlineSize()
{
    return ( 1.0 / [[UIScreen mainScreen] scale] ) / 2.0;
}

/**
 * 获取一个矩形的中心点
 */
CGPoint AWCenterOfRect(CGRect aRect)
{
    return CGPointMake(CGRectGetMidX(aRect), CGRectGetMidY(aRect));
}

UIWindow* AWAppWindow()
{
    return [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}

UIWindow* AWCreateAppWindow(UIColor* bgColor)
{
    UIWindow* anWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    anWindow.backgroundColor = bgColor;
    [anWindow makeKeyAndVisible];
    return anWindow;
}

void AWAppRateus(NSString* appId)
{
    NSString *url=nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        url=[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appId];
    }else{
        url=[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

void AWAppOpenQQ(NSString *qq)
{
    static UIWebView *webView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [AWAppWindow() addSubview:webView];
    });
    
    NSString *string = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", qq];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webView.delegate = [NBTarget sharedInstance];
    [webView loadRequest:request];
}

NSString* AWAppVersion()
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

NSString *AWChinese2PinyinWithSpace(NSString *chinese, BOOL yesOrNo)
{
    CFStringRef hanzi = (__bridge CFStringRef)chinese;
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, hanzi);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pinyin = (NSString *)CFBridgingRelease(string);
    if ( !yesOrNo ) {
        pinyin = [pinyin stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return pinyin;
}

UIImage *AWImageFromColor(UIColor *imageColor)
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    imageColor = imageColor ?: [UIColor blackColor];
    CGContextSetFillColorWithColor(ctx, imageColor.CGColor);
    CGContextFillRect(ctx, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

UIFont* AWSystemFontWithSize(CGFloat fontSize, BOOL isBold)
{
    if ( isBold ) {
        return [UIFont boldSystemFontOfSize:fontSize];
    }
    return [UIFont systemFontOfSize:fontSize];
}

UIFont* AWCustomFont(NSString* fontName, CGFloat fontSize)
{
    return [UIFont fontWithName:fontName size:fontSize];
}

UIColor* AWColorFromRGB(NSUInteger R, NSUInteger G, NSUInteger B)
{
    return AWColorFromRGBA(R, G, B, 1.0);
}

UIColor* AWColorFromRGBA(NSUInteger R, NSUInteger G, NSUInteger B, CGFloat A)
{
    return [UIColor colorWithRed:R / 255.0
                           green:G / 255.0
                            blue:B / 255.0
                           alpha:A];
}

UIColor* AWColorFromHex(NSString* hexString)
{
    unsigned rgbValue = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    scanner.scanLocation = 1; // 跳过#字符
    [scanner scanHexInt:&rgbValue];
    return AWColorFromRGBA( ( ( rgbValue & 0xFF0000 ) >> 16 ), ( ( rgbValue & 0xFF00 ) >> 8 ), ( rgbValue & 0xFF ), 1.0);
}

UIImage* AWSimpleResizeImage(UIImage* srcImage, CGSize newSize)
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    [srcImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 * 获取未缓存的图片
 */
UIImage *AWImageNoCached(NSString *imageName)
{
    NSString *imageFile = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFile];
    return image;
}

void AWSaveImageToPhotosAlbum(UIImage* anImage, NSString* groupName, SaveImageCompletionBlock completionBlock)
{
    static ALAssetsLibrary* photoLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !photoLibrary ) {
            photoLibrary = [[ALAssetsLibrary alloc] init];
        }
    });
    
    [photoLibrary writeImageToSavedPhotosAlbum:anImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if ( error.code == 0 ) {
            [photoLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if ( groupName ) {
                    [photoLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
                        if ( !group ) {
                            [photoLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                if ( [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:groupName] ) {
                                    [group addAsset:asset];
                                    *stop = YES;
                                }
                            } failureBlock:^(NSError *error) {
                                NSLog(@"enumerate groups with error: %@", error);
                            }];
                        } else {
                            [group addAsset:asset];
                        }
                    } failureBlock:^(NSError *error) {
                        NSLog(@"add assets group with error: %@", error);
                    }];
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"asset for url with error: %@", error);
            }];
            
            if ( completionBlock ) {
                completionBlock(YES, nil);
            }
            
        } else {
            if ( completionBlock ) {
                completionBlock(NO, error);
            }
        }
    }];
}

void AWSetAllTouchesDisabled(BOOL yesOrNo)
{
    if ( yesOrNo ) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

UIButton* AWCreateImageButton(NSString* imageName, id target, SEL action)
{
    return AWCreateImageButtonWithSize(imageName, CGSizeZero, target, action);
}

UIButton *AWCreateImageButtonWithColor(NSString *imageName, UIColor *btnColor, id target, SEL action)
{
    UIButton *btn = AWCreateImageButtonWithSize(imageName, CGSizeZero, target, action);
    if (btnColor) {
        UIImage *image = [btn imageForState:UIControlStateNormal];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:image forState:UIControlStateNormal];
        btn.tintColor = btnColor;
    }
    
    return btn;
}

UIButton* AWCreateImageButtonWithSize(NSString* imageName, CGSize size, id target, SEL action)
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    
    button.exclusiveTouch = YES;
    
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    if ( CGRectContainsRect(bounds, button.bounds) ) {
        button.bounds = bounds;
    } else if ( image.size.width < 34 ) {
        CGRect bounds = button.bounds;
        bounds.size.width = 34;
        button.bounds = bounds;
        
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, image.size.width / 2 - 34 / 2, 0, 0)];
    };
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

UIButton* AWCreateBackgroundImageAndTitleButton(NSString* backgroundImageName, NSString* title, id target, SEL action)
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage* backgroundImage = [UIImage imageNamed:backgroundImageName];
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    
    if ( backgroundImage ) {
        [[button titleLabel] setFont:AWSystemFontWithSize(backgroundImage.size.height * 0.3, NO)];
    } else {
        [[button titleLabel] setFont:AWSystemFontWithSize(24, NO)];
    }
    
    button.frame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);
    
    button.exclusiveTouch = YES;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

UIButton* AWCreateTextButton(CGRect frame, NSString* title, UIColor* titleColor, id target, SEL action)
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    button.frame = frame;
    
    button.exclusiveTouch = YES;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

UIBarButtonItem* AWCreateImageBarButtonItem(NSString* imageName, id target, SEL action)
{
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:AWCreateImageButton(imageName, target, action)];
    return item;
}

UIBarButtonItem* AWCreateImageBarButtonItemWithSize(NSString* imageName, CGSize size, id target, SEL action)
{
    UIBarButtonItem* item =
    [[UIBarButtonItem alloc] initWithCustomView:AWCreateImageButtonWithSize(imageName, size, target, action)];
    return item;
}

UIImageView* AWCreateImageView(NSString* imageName)
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imageView sizeToFit];
    return imageView;
}

UIImageView* AWCreateImageViewWithFrame(NSString* imageName, CGRect frame)
{
    UIImageView* imageView = AWCreateImageView(imageName);
    imageView.frame = frame;
    return imageView;
}

UILabel* AWCreateLabel(CGRect frame, NSString* text, NSTextAlignment alignment, UIFont* font, UIColor* textColor)
{
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = alignment;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    
    label.text = text;
    
    return label;
}

UITableView* AWCreateTableView(CGRect frame, UITableViewStyle style, UIView* superView, id <UITableViewDataSource> dataSource)
{
    UITableView* tableView = [[UITableView alloc] initWithFrame:frame style:style];
    [superView addSubview:tableView];
//    [tableView release];
    
    tableView.dataSource = dataSource;
    
    return tableView;
}

UIView* AWCreateLine(CGSize size, UIColor* color)
{
    return AWCreateLineInView(size, color, nil);
}

UIView* AWCreateLineInView(CGSize size, UIColor* color, UIView* containerView)
{
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    line.backgroundColor = color;
    if ( containerView ) {
        [containerView addSubview:line];
    }
    return line;
}

void AWLabelFormatShow(UILabel *label,
                       NSString *name,
                       id value,
                       NSString *unit,
                       UIFont *valueFont,
                       UIColor *valueColor,
                       BOOL horizontal)
{
    NSString *val = [value description];
    
    NSString *string = nil;
    if (horizontal) {
        string = [NSString stringWithFormat:@"%@: %@%@", name, value, unit];
    } else {
        string = [NSString stringWithFormat:@"%@%@\n%@", value, unit, name];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttributes:@{
                                NSFontAttributeName: valueFont,
                                NSForegroundColorAttributeName: valueColor
                                } range:[string rangeOfString:val]];
    
    label.attributedText = attrString;
    
}

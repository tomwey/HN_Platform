//
//  UploadImageControl.m
//  HN_ERP
//
//  Created by tomwey on 25/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "UploadImageControl.h"
#import "Defines.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "UIButton+AFNetworking.h"
#import <objc/runtime.h>

//#import <PhotosUI/PhotosUI.h>

@interface UploadImageControl () <TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) NSMutableArray *imageButtons;

@property (nonatomic, strong) AFHTTPRequestOperation *uploadOperation;

@property (nonatomic, strong) NSArray *uploadImages;

@property (nonatomic, strong) NSArray *currentUploadedIDs;

@property (nonatomic, strong) NSMutableArray *totalUploadImages;

@property (nonatomic, strong) NSMutableArray *deletedAttachments;

@end

@interface ImagePreviewVC : BaseNavBarVC

@end

#define kButtonCountPerRow 4

@implementation UploadImageControl

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if ( self = [super initWithFrame:frame] ) {
//        self.deletedAttachments = [@[] mutableCopy];
//        
//        [self.imageButtons addObject:self.addButton];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(deleteImage:)
//                                                     name:@"kUploadedImageDidDeleteNotification"
//                                                   object:nil];
//        
//        self.uploadImages = @[];
//        
//        [self addImages];
//    }
//    return self;
//}

- (instancetype)initWithAttachments:(NSArray *)attachments
{
    if (self = [super init]) {
        
        _enabled = YES;
        
        self.deletedAttachments = [@[] mutableCopy];
        
        [self.imageButtons addObject:self.addButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deleteImage:)
                                                     name:@"kUploadedImageDidDeleteNotification"
                                                   object:nil];
        
        self.uploadImages = attachments;
        
        [self addImages];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = ( self.width - (kButtonCountPerRow - 1) * 5 ) / kButtonCountPerRow;
    
//    NSInteger row = (self.imageButtons.count + kButtonCountPerRow - 1) / kButtonCountPerRow;
//    self.height = row * ( width + 5 ) - 5;
//    
    for (int i=0; i<self.imageButtons.count; i++) {
        UIButton *btn = self.imageButtons[i];
        
        btn.frame = CGRectMake(0, 0, width, width);
        
        int dtx = i % kButtonCountPerRow;
        int dty = i / kButtonCountPerRow;
        
        btn.position = CGPointMake(( width + 5 ) * dtx,
                                   ( width + 5) * dty);
    }
}

- (UIButton *)addButton
{
    if ( !_addButton ) {
        _addButton = AWCreateTextButton(CGRectZero,
                                        @"+",
                                        AWColorFromRGB(74, 74, 74),
                                        self,
                                        @selector(addImage));
        [self addSubview:_addButton];
        
        _addButton.layer.borderColor = _addButton.currentTitleColor.CGColor;
        _addButton.layer.borderWidth = 0.6;
        
        _addButton.titleLabel.font = AWSystemFontWithSize(18, NO);
    }
    return _addButton;
}

- (void)addImage
{
    if ( !self.enabled ) {
        return;
    }
    
    TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
    
    imagePickerVC.allowTakePicture  = YES;
    imagePickerVC.allowPickingVideo = NO;
    imagePickerVC.allowPickingImage = YES;
    imagePickerVC.allowPickingOriginalPhoto = YES;
    
    imagePickerVC.didFinishPickingPhotosHandle = ^( NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto ) {
        NSLog(@"photos: %@, assets: %@, origin: %d", photos, assets, isSelectOriginalPhoto);
        //        [self uploadImages:photos mimeType:@"image/png"];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (id asset in assets) {
            if ( [asset isKindOfClass:[PHAsset class]] ) {
                [[self class] getImageFromPHAsset:asset completion:^(NSData *data, NSString *filename, NSString *imageUTI) {
                    if ( data && filename ) {
                        [tempArray addObject:@{ @"imageData": data,
                                                @"imageName": filename,
                                                @"imageUTI": imageUTI,
//                                                @"imageURL": imageURL ?: @"",
                                                }];
                    }
                }];
            }
        }
        
        self.uploadImages = tempArray;
        
        [self uploadImages:tempArray mimeType:@"image/png"];
    };
    
    //        imagePickerVC.didFinishPickingVideoHandle = ^(UIImage *coverImage,id asset) {
    //            NSLog(@"coverImage: %@, asset: %@", coverImage, asset);
    //            if ( [asset isKindOfClass:[PHAsset class]] ) {
    //                PHAsset *movAsset = (PHAsset *)asset;
    //                [[self class] getVideoFromPHAsset:movAsset completion:^(NSData *data, NSString *filename) {
    //                    [self uploadData:data fileName:filename mimeType:@"video/mp4"];
    //                }];
    //            }
    //            //        [self uploadData: fileName:@"file.mov" mimeType:@"video/mp4"];
    //        };
    
    [self.owner presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)cancelUpload
{
    [self.uploadOperation cancel];
    self.uploadOperation = nil;
}

- (void)uploadFile:(NSDictionary *)params
     formDataBlock:( void (^)(id<AFMultipartFormData>  _Nonnull formData) )formDataBlock
{
    if (!self.annexTableName || !self.annexFieldName) {
        return;
    }
    
    [self cancelUpload];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [[MBProgressHUD appearance] setContentColor:MAIN_THEME_COLOR];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:AWAppWindow() animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.progress = 0.0f;
    hud.label.text = @"上传中...";
    
    NSString *tableName = self.annexTableName;//@"H_APP_Supplier_Contract_Change_Annex";
    NSString *fieldname = self.annexFieldName;//@"AnnexKeyID";
    NSString *mid = @"0";//self.params[@"mid"] ?: @"0";
//    if (self.currentAttachmentFormControl) {
//        //        id val = self.formObjects[self.currentAttachmentFieldName];
//        NSArray *temp = [self.currentAttachmentFormControl[@"item_value"] componentsSeparatedByString:@","];
//        if ( [temp firstObject] ) {
//            tableName = [temp firstObject];
//        }
//        
//        if ([temp lastObject]) {
//            fieldname = [temp lastObject];
//        }
//        
//        mid = @"";
//    }
    
    __weak typeof(self) weakSelf = self;
    NSString *uploadUrl = [NSString stringWithFormat:@"%@/upload", API_HOST];
    self.uploadOperation =
    [[AFHTTPRequestOperationManager manager] POST:uploadUrl
                                       parameters:@{
                                                    @"mid": mid,
                                                    @"domanid": manID,
                                                    @"tablename": tableName,
                                                    @"fieldname": fieldname,
                                                    }
                        constructingBodyWithBlock:formDataBlock
                                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
     {
         [weakSelf handleAnnexUploadSuccess:responseObject];
     }
     
                                          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
     {
         //
         NSLog(@"error: %@",error);
         [MBProgressHUD hideHUDForView:AWAppWindow() animated:YES];
         [AWAppWindow() showHUDWithText:@"附件上传失败" succeed:NO];
     }];
    [self.uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"%f", totalBytesWritten / (float)totalBytesExpectedToWrite);
        hud.progress = totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    
}

- (void)handleAnnexUploadSuccess:(id)responseObject
{
    [MBProgressHUD hideHUDForView:AWAppWindow() animated:YES];
    [AWAppWindow() showHUDWithText:@"附件上传成功" succeed:YES];
    
    NSArray *IDs = [responseObject[@"IDS"] componentsSeparatedByString:@","];
    self.currentUploadedIDs = IDs;
//
//    if ( IDs ) {
//        [self.attachmentIDs addObjectsFromArray:IDs];
//    }
//    
//    if ( self.currentAttachmentFieldName && IDs ) {
//        NSArray *ids = self.formObjects[self.currentAttachmentFieldName] ?: @[];
//        NSMutableArray *temp = [ids mutableCopy];
//        [temp addObjectsFromArray:IDs];
//        
//        self.formObjects[self.currentAttachmentFieldName] = temp;
//        
//        [self.tableView reloadData];
//    }
    
    [self addImages];
    
    NSLog(@"response: %@", responseObject);
}

- (void)addImages
{
    if (self.uploadImages.count == 0) return;
    
    CGFloat width = ( self.width - (kButtonCountPerRow - 1) * 5 ) / kButtonCountPerRow;
    
    for (int i=self.uploadImages.count - 1; i>=0; i--) {
        id data = self.uploadImages[i];
        
        NSString *id_ = @"";
        if ( self.currentUploadedIDs.count == 0 ) {
            id_ = [data[@"id"] ?: @"" description];
        } else {
            if (i < self.currentUploadedIDs.count) {
                id_ = [self.currentUploadedIDs[i] description];
            }
        }
        
        NSMutableDictionary *item = [data mutableCopy];
        [item setObject:id_ forKey:@"id"];
        
        UIButton *btn = AWCreateImageButton(nil, self, @selector(openImage:));
        [self addSubview:btn];
        [self.imageButtons insertObject:btn atIndex:0];
        
        btn.userData = item;
        
        if ( data[@"imageURL"] ) {
            [btn setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:data[@"imageURL"]]];
        } else {
            [btn setBackgroundImageData:data[@"imageData"]
                               imageUTI:data[@"imageUTI"]
                               forState:UIControlStateNormal];
        }
    }
    
    [self setNeedsLayout];
    
    NSInteger row = (self.imageButtons.count + kButtonCountPerRow - 1) / kButtonCountPerRow;
    self.height = row * ( width + 5 ) - 5;
    
    if ( self.didUploadedImagesBlock ) {
        self.didUploadedImagesBlock(self);
    }
}

- (void)updateHeight
{
    CGFloat width = ( self.width - (kButtonCountPerRow - 1) * 5 ) / kButtonCountPerRow;
    NSInteger row = (self.imageButtons.count + kButtonCountPerRow - 1) / kButtonCountPerRow;
    self.height = row * ( width + 5 ) - 5;
}

- (void)deleteImage:(NSNotification *)noti
{
    UIButton *sender = noti.object;
    
    [self.deletedAttachments addObject:[sender.userData[@"id"] description]];
    
    [self close:sender];
}

- (NSArray *)deletedAttachmentIDs
{
    return [self.deletedAttachments copy];
}

- (void)close:(UIButton *)sender
{
    [self.imageButtons removeObject:sender];
    
    [sender removeFromSuperview];
    
    [self setNeedsLayout];
    
    CGFloat width = ( self.width - (kButtonCountPerRow - 1) * 5 ) / kButtonCountPerRow;
    
    NSInteger row = (self.imageButtons.count + kButtonCountPerRow - 1) / kButtonCountPerRow;
    self.height = row * ( width + 5 ) - 5;
    
    if ( self.didUploadedImagesBlock ) {
        self.didUploadedImagesBlock(self);
    }
}

- (void)openImage:(UIButton *)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"ImagePreviewVC"
                                                                params:@{
                                                                         @"imageButton": sender,
                                                                         @"enabled": @(self.enabled),
                                                                         }];
    [self.owner presentViewController:vc animated:YES completion:nil];
}

- (void)uploadImages:(NSArray *)images mimeType:(NSString *)mimeType
{
    [self uploadFile:@{}
       formDataBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           for (id image in images) {
               [formData appendPartWithFileData:image[@"imageData"]
                                           name:@"file"
                                       fileName:image[@"imageName"]
                                       mimeType:mimeType];
               
           }
       }];
}

+ (void)getImageFromPHAsset:(PHAsset *)asset completion:(void (^)(NSData *data,
                                                                NSString *filename,
                                                                  NSString *imageUTI) ) result {
    __block NSData *data;
    __block NSString *imageUTI;
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             data = [NSData dataWithData:imageData];
             imageUTI = info[@"PHImageFileUTIKey"];
//             NSLog(@"%@, %@", info[@"PHImageFileURLKey"], [info[@"PHImageFileURLKey"] class]);
//             NSLog(@"data uri: %@, info: %@", dataUTI, info);
             // info
//             PHImageFileDataKey = <PLXPCShMemData: 0x189d3220> bufferLength=188416 dataLength=185665;
//             PHImageFileOrientationKey = 0;
//             PHImageFileSandboxExtensionTokenKey = "d98ef2d84a8655072f9c5be9b4cd1718fe2c60b7;00000000;00000000;0000001a;com.apple.app-sandbox.read;00000001;01000003;00000000007fe4f7;/private/var/mobile/Media/DCIM/100APPLE/IMG_0295.PNG";
//             PHImageFileURLKey = "file:///var/mobile/Media/DCIM/100APPLE/IMG_0295.PNG";
//             PHImageFileUTIKey = "public.png";
//             PHImageResultDeliveredImageFormatKey = 9999;
//             PHImageResultIsDegradedKey = 0;
//             PHImageResultIsInCloudKey = 0;
//             PHImageResultIsPlaceholderKey = 0;
//             PHImageResultOptimizedForSharing = 0;
//             PHImageResultWantedImageFormatKey = 9999;
         }];
    }
    
    if (result) {
        if (data.length <= 0) {
            result(nil, nil, nil);
        } else {
            result(data, resource.originalFilename, imageUTI);
        }
    }
}

- (NSMutableArray *)imageButtons
{
    if ( !_imageButtons ) {
        _imageButtons = [@[] mutableCopy];
    }
    return _imageButtons;
}

- (NSArray *)attachmentIDs
{
    NSMutableArray *IDs = [NSMutableArray array];
    for (int i=0; i<self.imageButtons.count - 1;i++) {
        UIButton *sender = self.imageButtons[i];
        [IDs addObject:sender.userData[@"id"] ?: @""];
    }
    return [IDs copy];
}

- (NSArray *)attachments
{
    NSMutableArray *temp = [NSMutableArray array];
    for (int i=0; i<self.imageButtons.count - 1;i++) {
        UIButton *sender = self.imageButtons[i];
        [temp addObject:sender.userData ?: @{}];
    }
    return [temp copy];
}

@end

@interface ImagePreviewVC () <UIAlertViewDelegate>

@end

@implementation ImagePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id data  = [self.params[@"imageButton"] userData];
    self.navBar.title = data[@"imageName"];
    
    UIButton *closeBtn = HNCloseButton(34, self, @selector(close));
    [self addLeftItemWithView:closeBtn leftMargin:2];
    
    BOOL enabled = [self.params[@"enabled"] boolValue];
    
    if (enabled) {
        __weak typeof(self) me = self;
        [self addRightItemWithTitle:@"删除"
                    titleAttributes:@{  }
                               size:CGSizeMake(44, 40)
                        rightMargin:5
                           callback:^{
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您确定要删除吗？" message:@""
                                                                              delegate:me
                                                                     cancelButtonTitle:nil
                                                                     otherButtonTitles:@"取消", @"确定", nil];
                               [alert show];
                           }];
    }
    
    UIImageView *imageView = AWCreateImageView(nil);
    [self.contentView addSubview:imageView];
    imageView.frame = self.contentView.bounds;
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (data[@"imageURL"]) {
        [imageView setImageWithURL:[NSURL URLWithString:data[@"imageURL"]]];
    } else {
        imageView.image = [UIImage imageWithData:data[@"imageData"]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        [self close];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUploadedImageDidDeleteNotification"
                                                            object:self.params[@"imageButton"]];
    }
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation UIButton (ImageData)

- (void)setBackgroundImageData:(NSData *)imageData
                      imageUTI:(NSString *)uti
                      forState:(UIControlState)state
{
    [self cancelImageRequestOperationForState:state];
    
    UIImage *cachedImage = [[[self class] sharedCache] objectForKey:[imageData md5Hash]];
    if ( cachedImage ) {
        [self setBackgroundImage:cachedImage forState:state];
    } else {
        NSInvocationOperation *operation =
            [[NSInvocationOperation alloc] initWithTarget:self
                                                 selector:@selector(decodeImage:)
                                                   object:@{ @"uti": uti ?: @"public.png",
                                                             @"data": imageData ?: [NSNull null],
                                                             @"state": @(state),
                                                             }];
        [self af_setBackgroundImageOperation:operation forState:state];
        
        [[[self class] af_sharedImageDecodeOperationQueue] addOperation:operation];
    }
}

- (void)decodeImage:(id)data
{
    CGImageRef img = YYCGImageCreateDecodedCopy(data[@"data"], data[@"uti"], YES);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageWithCGImage:img];
        [[[self class] sharedCache] setObject:image forKey:[data[@"data"] md5Hash]];
        
        [self setBackgroundImage:image forState:[data[@"state"] integerValue]];
    });
}

CGColorSpaceRef YYCGColorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

CGImageRef YYCGImageCreateDecodedCopy(NSData *imageData, NSString *imageUTI, BOOL decodeForDisplay) {
    
    CGImageRef imageRef = NULL;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)imageData);
    
    if ([imageUTI isEqualToString:@"public.png"]) {
        imageRef = CGImageCreateWithPNGDataProvider(dataProvider,  NULL, true, kCGRenderingIntentDefault);
    } else if ([imageUTI isEqualToString:@"public.jpeg"] || [imageUTI isEqualToString:@"public.jpg"]) {
        imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        
        if (imageRef) {
            CGColorSpaceRef imageColorSpace = CGImageGetColorSpace(imageRef);
            CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(imageColorSpace);
            
            // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so fall back to AFImageWithDataAtScale
            if (imageColorSpaceModel == kCGColorSpaceModelCMYK) {
                CGImageRelease(imageRef);
                imageRef = NULL;
            }
        }
    }
    
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    if (decodeForDisplay) { //decode with redraw (may lose some precision)
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, YYCGColorSpaceGetDeviceRGB(), bitmapInfo);
        if (!context) return NULL;
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef newImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        return newImage;
        
    } else {
        CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
        size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        if (bytesPerRow == 0 || width == 0 || height == 0) return NULL;
        
        CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
        if (!dataProvider) return NULL;
        CFDataRef data = CGDataProviderCopyData(dataProvider); // decode
        if (!data) return NULL;
        
        CGDataProviderRef newProvider = CGDataProviderCreateWithCFData(data);
        CFRelease(data);
        if (!newProvider) return NULL;
        
        CGImageRef newImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, bitmapInfo, newProvider, NULL, false, kCGRenderingIntentDefault);
        CFRelease(newProvider);
        return newImage;
    }
}

+ (NSCache *)sharedCache
{
    static NSCache *imageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:imageCache
                                                 selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    });
    return imageCache;
}

- (void)cancelBackgroundImageOperationForState:(UIControlState)state {
    [[self af_backgroundImageOperationForState:state] cancel];
    [self af_setBackgroundImageOperation:nil forState:state];
}

+ (NSOperationQueue *)af_sharedImageDecodeOperationQueue {
    static NSOperationQueue *decodeOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decodeOperationQueue = [[NSOperationQueue alloc] init];
        decodeOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return decodeOperationQueue;
}

#pragma mark -

static char HNBackgroundImageRequestOperationNormal;
static char HNBackgroundImageRequestOperationHighlighted;
static char HNBackgroundImageRequestOperationSelected;
static char HNBackgroundImageRequestOperationDisabled;

static const char * af_backgroundImageOperationKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &HNBackgroundImageRequestOperationHighlighted;
        case UIControlStateSelected:
            return &HNBackgroundImageRequestOperationSelected;
        case UIControlStateDisabled:
            return &HNBackgroundImageRequestOperationDisabled;
        case UIControlStateNormal:
        default:
            return &HNBackgroundImageRequestOperationNormal;
    }
}

- (NSInvocationOperation *)af_backgroundImageOperationForState:(UIControlState)state {
    return (NSInvocationOperation *)objc_getAssociatedObject(self, af_backgroundImageOperationKeyForState(state));
}

- (void)af_setBackgroundImageOperation:(NSInvocationOperation *)imageOperation
                                     forState:(UIControlState)state
{
    objc_setAssociatedObject(self, af_backgroundImageOperationKeyForState(state), imageOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

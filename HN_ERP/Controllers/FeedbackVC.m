//
//  FeedbackVC.m
//  RTA
//
//  Created by tangwei1 on 16/11/7.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "FeedbackVC.h"
#import "Defines.h"
#import <Photos/Photos.h>
#import "TZImagePickerController.h"

@interface FeedbackVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,TZImagePickerControllerDelegate>

@property (nonatomic, weak) UITextView *bodyView;
@property (nonatomic, weak) AWTextField *titleField;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) AFHTTPRequestOperation *uploadOperation;
@property (nonatomic, strong) NSMutableArray *attachmentIDs;

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navBar.title = @"意见反馈";
    
    AWTextField *textField = [[AWTextField alloc] initWithFrame:CGRectMake(15, 15, self.contentView.width - 30, 34)];
    [self.contentView addSubview:textField];
    textField.placeholder = @"标题";
    textField.backgroundColor = [UIColor whiteColor];
    
    self.titleField = textField;
    
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textField.cornerRadius = 2;
    textField.padding = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textField.returnKeyType = UIReturnKeyDone;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(15, textField.bottom + 10, self.contentView.width - 30,
                                                                           120)];
    [self.contentView addSubview:textView];
    textView.placeholder = @"内容";
    textView.layer.borderWidth = 0.5;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.cornerRadius = 2;
    textView.font = textField.font;
    textView.placeholderAttributes = @{ NSFontAttributeName: textField.font };
    textView.placeholderPosition = CGPointMake(5, 3);
    
    textView.backgroundColor = [UIColor whiteColor];
    
    self.bodyView = textView;
    
    // 附件上传
    FAKIonIcons *attachIcon = [FAKIonIcons androidAttachIconWithSize:20];
    [attachIcon addAttributes:@{ NSForegroundColorAttributeName: IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR }];
    UIButton *attachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [textView addSubview:attachBtn];
    [attachBtn setImage:[attachIcon imageWithSize:CGSizeMake(30, 30)] forState:UIControlStateNormal];
    attachBtn.frame = CGRectMake(textView.width - 40, textView.height - 40,
                                 40, 40);
    [attachBtn addTarget:self
                  action:@selector(uploadAttachment) forControlEvents:UIControlEventTouchUpInside];
    
    attachBtn.backgroundColor = [UIColor clearColor];
    
    AWButton *sendBtn = [AWButton buttonWithTitle:@"提交" color:BUTTON_COLOR];
    sendBtn.frame = textView.frame;
    sendBtn.height = 44;
    sendBtn.top = textView.bottom  + 20;
    [self.contentView addSubview:sendBtn];
    
    [sendBtn addTarget:self forAction:@selector(send:)];
    
    [[SysLogService sharedInstance] logType:20
                                      keyID:0
                                    keyName:@"意见反馈"
                                    keyMemo:nil];
}

- (void)uploadAttachment
{
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"从相册选择"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self selectMedia];
                                                         }];
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:@"拍照"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self takePhoto];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    UIAlertController *actionCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionCtrl addAction:takeAction];
    [actionCtrl addAction:selectAction];
    [actionCtrl addAction:cancelAction];
    
    [self presentViewController:actionCtrl animated:YES completion:nil];
}

- (void)takePhoto
{
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [self authAndOpenPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [self showAlertWithTitle:@"当前设备不支持拍照"];
    }
}

- (void)showAlertForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    NSString *message = nil;
    NSString *url     = nil;
    
    if ( sourceType == UIImagePickerControllerSourceTypeCamera ) {
        message = @"“合能地产”需要获得访问相机的权限";
        url = @"App-Prefs:root=Privacy&path=CAMERA";
    } else {
        message = @"“合能地产”需要获得访问照片的权限";
        url = @"App-Prefs:root=Privacy&path=PHOTOS";
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    UIAlertAction *okAction   = [UIAlertAction actionWithTitle:@"设置"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                                                       }];
    UIAlertController *alertCtrl =
    [UIAlertController alertControllerWithTitle:@"需要权限"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:cancelAction];
    [alertCtrl addAction:okAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)openPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if ( sourceType == UIImagePickerControllerSourceTypeCamera ) {
        self.imagePicker.sourceType = sourceType;
        
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
        
        self.imagePicker.videoMaximumDuration = 30;
        self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    } else {
        // 打开相册
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
        
        imagePickerVC.allowTakePicture  = NO;
        imagePickerVC.allowPickingVideo = YES;
        imagePickerVC.allowPickingImage = YES;
        imagePickerVC.allowPickingOriginalPhoto = YES;
        
        imagePickerVC.didFinishPickingPhotosHandle = ^( NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto ) {
            NSLog(@"photos: %@, assets: %@, origin: %d", photos, assets, isSelectOriginalPhoto);
            //        [self uploadImages:photos mimeType:@"image/png"];
            NSMutableArray *tempArray = [NSMutableArray array];
            for (id asset in assets) {
                if ( [asset isKindOfClass:[PHAsset class]] ) {
                    [[self class] getImageFromPHAsset:asset completion:^(NSData *data, NSString *filename) {
                        if ( data && filename ) {
                            [tempArray addObject:@{ @"imageData": data,
                                                    @"imageName": filename
                                                    }];
                        }
                    }];
                }
            }
            
            [self uploadImages:tempArray mimeType:@"image/png"];
        };
        
        imagePickerVC.didFinishPickingVideoHandle = ^(UIImage *coverImage,id asset) {
            NSLog(@"coverImage: %@, asset: %@", coverImage, asset);
            if ( [asset isKindOfClass:[PHAsset class]] ) {
                PHAsset *movAsset = (PHAsset *)asset;
                [[self class] getVideoFromPHAsset:movAsset completion:^(NSData *data, NSString *filename) {
                    [self uploadData:data fileName:filename mimeType:@"video/mp4"];
                }];
            }
            //        [self uploadData: fileName:@"file.mov" mimeType:@"video/mp4"];
        };
        
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

- (void)showAlertWithTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"info: %@", info);
    
    NSData   *fileData = nil;
    NSString *fileName = nil;
    NSString *mimeName = nil;
    
    NSString *mediaType = [info[UIImagePickerControllerMediaType] description];
    if ( [mediaType isEqualToString:@"public.movie"] ) {
        fileData = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];
        fileName = @"file.mov";
        mimeName = @"video/mp4";
        
        if ( fileData ) {
            [self uploadData:fileData fileName:fileName mimeType:mimeName];
        }
        
    } else if ( [mediaType isEqualToString:@"public.image"] ) {
        fileData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 1.0);//UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]);
        fileName = @"image.png";
        mimeName = @"image/png";
        
        if ( fileData ) {
            id image = @{
                         @"imageData": fileData,
                         @"imageName": @"IMG_0001.PNG"
                         };
            [self uploadImages:@[image] mimeType:mimeName];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController *)imagePicker
{
    if ( !_imagePicker ) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
//        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

- (NSMutableArray *)attachmentIDs
{
    if ( !_attachmentIDs ) {
        _attachmentIDs = [[NSMutableArray alloc] init];
    }
    return _attachmentIDs;
}

- (void)authAndOpenPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
//    NSString *alertTitle = sourceType == UIImagePickerControllerSourceTypePhotoLibrary ? @"拒绝访问相册，可去“设置->隐私->照片”下开启" : @"拒绝访问摄像头，可去“设置->隐私->相机”下开启";
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( granted ) {
                            [self openPickerWithSourceType:sourceType];
                        } else {
                            [self showAlertForSourceType:sourceType];
                        }
                    });
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied:
            {
                [self showAlertForSourceType:sourceType];
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                [self openPickerWithSourceType:sourceType];
            }
                break;
                
            default:
                break;
        }
        
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
            {
                // 请求授权
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( status == PHAuthorizationStatusAuthorized ) {
                            [self openPickerWithSourceType:sourceType];
                        } else {
                            [self showAlertForSourceType:sourceType];
                        }
                    });
                }];
            }
                break;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
            {
                [self showAlertForSourceType:sourceType];
            }
                break;
            case PHAuthorizationStatusAuthorized:
            {
                [self openPickerWithSourceType:sourceType];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)selectMedia
{
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        [self authAndOpenPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        [self showAlertWithTitle:@"当前设备不支持拍照"];
    }
}

- (void)uploadData:(NSData *)fileData
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
{
    [self cancelUpload];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.progress = 0.0f;
    hud.label.text = @"上传中...";
    //    hud.tintColor = MAIN_THEME_COLOR;
    
    NSString *uploadUrl = [NSString stringWithFormat:@"%@/upload", API_HOST];
    self.uploadOperation =
    [[AFHTTPRequestOperationManager manager] POST:uploadUrl
                                       parameters:@{
                                                    @"mid": self.params[@"mid"] ?: @"0",
                                                    @"domanid": manID,
                                                    @"tablename": @"H_SY_Feedback_Info",
                                                    @"fieldname": @"About_Annex",
                                                    }
                        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         [formData appendPartWithFileData:fileData
                                     name:@"file"
                                 fileName:fileName
                                 mimeType:mimeType];
     }
                                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
     {
         //
         [MBProgressHUD hideHUDForView:self.contentView animated:YES];
         [self.contentView showHUDWithText:@"附件上传成功" succeed:YES];
         
         NSArray *IDs = [responseObject[@"IDS"] componentsSeparatedByString:@","];
         
         if ( IDs ) {
             [self.attachmentIDs addObjectsFromArray:IDs];
         }
         
         NSLog(@"response: %@", responseObject);
     }
     
                                          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
     {
         //
         NSLog(@"error: %@",error);
         [MBProgressHUD hideHUDForView:self.contentView animated:YES];
         [self.contentView showHUDWithText:@"附件上传失败" succeed:NO];
     }];
    [self.uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"%f", totalBytesWritten / (float)totalBytesExpectedToWrite);
        hud.progress = totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
}

- (void)cancelUpload
{
    [self.uploadOperation cancel];
    self.uploadOperation = nil;
}

- (void)uploadImages:(NSArray *)images mimeType:(NSString *)mimeType
{
    [self cancelUpload];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [[MBProgressHUD appearance] setContentColor:MAIN_THEME_COLOR];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.progress = 0.0f;
    hud.label.text = @"上传中...";
    
    NSString *uploadUrl = [NSString stringWithFormat:@"%@/upload", API_HOST];
    self.uploadOperation =
    [[AFHTTPRequestOperationManager manager] POST:uploadUrl
                                       parameters:@{
                                                    @"mid": self.params[@"mid"] ?: @"0",
                                                    @"domanid": manID,
                                                    @"tablename": @"H_SY_Feedback_Info",
                                                    @"fieldname": @"About_Annex",
                                                    }
                        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         for (id image in images) {
             [formData appendPartWithFileData:image[@"imageData"]
                                         name:@"file"
                                     fileName:image[@"imageName"]
                                     mimeType:mimeType];
             
         }
     }
                                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
     {
         //
         [MBProgressHUD hideHUDForView:self.contentView animated:YES];
         
         [self.contentView showHUDWithText:@"附件上传成功" succeed:YES];
         
         NSLog(@"response: %@", responseObject);
         
         NSArray *IDs = [responseObject[@"IDS"] componentsSeparatedByString:@","];
         
         if ( IDs ) {
             [self.attachmentIDs addObjectsFromArray:IDs];
         }
     }
     
                                          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
     {
         //
         NSLog(@"error: %@",error);
         [MBProgressHUD hideHUDForView:self.contentView animated:YES];
         [self.contentView showHUDWithText:@"附件上传失败" succeed:NO];
     }];
    [self.uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"%f", totalBytesWritten / (float)totalBytesExpectedToWrite);
        hud.progress = totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
}


+ (void)getVideoFromPHAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSString *filename))result
{
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        if ( assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo ) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    if (asset.mediaType == PHAssetMediaTypeVideo ||
        asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive ) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:
         [NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:
         ^(NSError * _Nullable error)
         {
             if (error) {                                                                  result(nil, nil);
             } else {
                 NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:PATH_MOVIE_FILE]];                                                                  result(data, fileName);
             }
             [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE
                                                        error:nil];                                                          }];
    } else {
        result(nil, nil);
    }
}

+ (void)getImageFromPHAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSString *filename) ) result {
    __block NSData *data;
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
         }];
    }
    
    if (result) {
        if (data.length <= 0) {
            result(nil, nil);
        } else {
            result(data, resource.originalFilename);
        }
    }
}

- (void)send:(id)sender
{
    if ( [self.titleField.text trim].length == 0 ) {
        [self.contentView makeToast:@"标题不能为空" duration:2.0 position:CSToastPositionTop];
        return;
    }
    
    [self.titleField resignFirstResponder];
    
    if ( [self.bodyView.text trim].length == 0 ) {
        [self.contentView makeToast:@"内容不能为空" duration:2.0 position:CSToastPositionTop];
        return;
    }
    
    [self.bodyView resignFirstResponder];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil params:@{
                       @"dotype": @"GetData",
                       @"funname": @"意见反馈APP",
                       @"param1": [self.titleField.text trim],
                       @"param2": [self.bodyView.text trim],
                       @"param3": manID,
                       @"param4": self.attachmentIDs.count > 0 ? [self.attachmentIDs componentsJoinedByString:@","] : @"",
                       } completion:^(id result, NSError *error) {
                           [me handleResult:result error:error];
                       }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    if ( error ) {
        [self.contentView showHUDWithText:error.domain succeed:NO];
    } else {
        self.titleField.text = nil;
        self.bodyView.text   = nil;
        self.bodyView.placeholder = @"内容";
        [self.attachmentIDs removeAllObjects];
        
        [self.contentView showHUDWithText:@"提交成功" succeed:YES];
    }
}

@end

//
//  AWLocationManager.m
//  deyi
//
//  Created by tangwei1 on 16/9/5.
//  Copyright © 2016年 tangwei1. All rights reserved.
//

#import "AWLocationManager.h"
#import "WGS84ToGCJ02.h"

@interface AWLocationManager () <CLLocationManagerDelegate>

/** 返回当前最新的位置 */
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;

@property (nonatomic, strong, readwrite) id currentGeocodeLocation;
@property (nonatomic, strong) NSURLSessionDataTask *geocodeDataTask;

@property (nonatomic, strong, readwrite) NSError    *locatedError;
@property (nonatomic, strong, readwrite) NSError    *geocodingError;

@property (nonatomic, copy) void (^completionBlock)(CLLocation *location, NSError *error);

@property (nonatomic, assign, readwrite) BOOL locating;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

static NSString * const QQLBSServer        = @"http://apis.map.qq.com";
static NSString * const QQLBSServiceAPIKey = @"5TXBZ-RDMH3-6GN36-3YZ6J-2QJYK-XIFZI";

static NSString * const QQGeocodeAPI       = @"/ws/geocoder/v1";
static NSString * const QQPOISearchAPI     = @"/ws/place/v1/search";

NSString * const AWLocationManagerDidFinishLocatingNotification = @"AWLocationManagerDidFinishLocatingNotification";
NSString * const AWLocationManagerDidFinishGeocodingLocationNotification = @"AWLocationManagerDidFinishGeocodingLocationNotification";

@implementation AWLocationManager

#define kLocationFormat @"%.06f,%.06f"

+ (AWLocationManager *)sharedInstance
{
    static AWLocationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[AWLocationManager alloc] init];
        }
    });
    return instance;
}

- (void)startUpdatingLocation:(void (^)(CLLocation *, NSError *))completionBlock
{
    if ( self.locating ) {
        [self log:@"正在定位中..."];
        return;
    }
    
    self.locating = YES;
    
    self.completionBlock = completionBlock;
    
    // 检查定位服务是否可用
    if ( [self isLocationServiceEnabled] == NO ) return;
    
    // 检查定位服务使用权限
    if ( [self isAllowedUseLocationService] == NO ) return;
    
    self.locationManager.delegate = self;
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if ( authStatus == kCLAuthorizationStatusNotDetermined ) {
        if ( [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] ) {
            [self.locationManager requestAlwaysAuthorization];
        } else {
            [self.locationManager startUpdatingLocation];
        }
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation
{
    self.locating = NO;
    
    self.locationManager.delegate = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)startGeocodingLocation:(CLLocation *)aLocation
                    completion:(void (^)(id result, NSError *error))completion
{
    if ( !aLocation ) {
        if ( completion ) {
            completion(nil, [NSError errorWithDomain:@"位置为空" code:4004 userInfo:nil]);
        }
        return;
    }
    
    if ( !CLLocationCoordinate2DIsValid(aLocation.coordinate) ) {
        if ( completion ) {
            completion(nil, [NSError errorWithDomain:@"位置所在的坐标无效" code:-2 userInfo:nil]);
        }
        return;
    }
    
    [self.geocodeDataTask cancel];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:
                             [NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString* locationVal = [NSString stringWithFormat:@"%.06lf,%.06lf", aLocation.coordinate.latitude, aLocation.coordinate.longitude];
    // coord_type = 1表示GPS坐标
    // coord_type = 5表示火星坐标
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?location=%@&key=%@&coord_type=5",
                                       QQLBSServer, QQGeocodeAPI, locationVal, QQLBSServiceAPIKey]];
#if DEBUG
    NSLog(@"开始解析位置：%@", url);
#endif
    self.geocodeDataTask = [session dataTaskWithURL:url
                                  completionHandler:^(NSData * _Nullable data,
                                                     NSURLResponse * _Nullable response,
                                                     NSError * _Nullable error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completion ) {
                if ( error ) {
                    completion(nil, error);
                    self.geocodingError = error;
                } else {
                    NSError *jsonError = nil;
                    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    if ( jsonError ) {
                        self.geocodingError = [NSError errorWithDomain:@"解析JSON出错" code:-2 userInfo:nil];
                        completion(nil, self.geocodingError);
                    } else {
                        if ( [obj[@"status"] intValue] == 0 ) {
                            self.currentGeocodeLocation = obj[@"result"];
                            completion(obj[@"result"], nil);
                        } else {
                            self.geocodingError = [NSError errorWithDomain:obj[@"message"] code:-2 userInfo:nil];
                            completion(nil, self.geocodingError);
                        }
                    }
                    
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AWLocationManagerDidFinishGeocodingLocationNotification object:nil];
        });
    }];
    
    [self.geocodeDataTask resume];
}

/** 返回当前位置的经纬度格式化字符串，格式为：经度,纬度 */
- (NSString *)formatedCurrentLocation_1
{
    if ( self.currentLocation == nil ) return nil;
    
    return [NSString stringWithFormat:kLocationFormat,
            self.currentLocation.coordinate.longitude,
            self.currentLocation.coordinate.latitude];
}

/** 返回当前位置的经纬度格式化字符串，格式为：纬度,经度 */
- (NSString *)formatedCurrentLocation_2
{
    if ( self.currentLocation == nil ) return nil;
    
    return [NSString stringWithFormat:kLocationFormat,
            self.currentLocation.coordinate.latitude,
            self.currentLocation.coordinate.longitude];
}

#pragma mark -----------------------------------------------------------
#pragma mark CLLocationManager delegate
#pragma mark -----------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    
//    NSLog(@"转换前：%@", location);
    // 转换成火星坐标
    self.currentLocation = [[CLLocation alloc] initWithCoordinate:[self transformWGS84ToGCJ:location.coordinate]
                                                         altitude:location.altitude
                                               horizontalAccuracy:location.horizontalAccuracy
                                                 verticalAccuracy:location.verticalAccuracy
                                                           course:location.course
                                                            speed:location.speed
                                                        timestamp:location.timestamp];
    
    //[[CLLocation alloc] initWithLatitude:[self transformWGS84ToGCJ:location.coordinate].latitude
      //                                                longitude:[self transformWGS84ToGCJ:location.coordinate].longitude];
//    NSLog(@"转换后：%@", self.currentLocation);
    
    [self handleCompletion:self.currentLocation error:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self handleCompletion:nil error:[NSError errorWithDomain:@"定位失败"
                                                         code:error.code
                                                     userInfo:nil]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ( status == kCLAuthorizationStatusAuthorizedAlways ||
         status == kCLAuthorizationStatusAuthorizedWhenInUse ) {
        [self.locationManager startUpdatingLocation];
    }
}

- (CLLocationManager *)locationManager
{
    if ( !_locationManager ) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

- (BOOL)isLocationServiceEnabled
{
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    if ( enabled == NO ) {
        NSError *error = [NSError errorWithDomain:@"定位服务不可用"
                                             code:AWLocationErrorNotEnabled
                                         userInfo:nil];
        [self handleCompletion:nil error: error];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)isAllowedUseLocationService
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if ( authStatus == kCLAuthorizationStatusRestricted ) {
        [self handleCompletion:nil error:[NSError errorWithDomain:@"定位服务限制使用"
                                                             code:AWLocationErrorDenied
                                                         userInfo:nil
                                          ]];
        
        return NO;
    }
    
    if ( authStatus == kCLAuthorizationStatusDenied ) {
        [self handleCompletion:nil error:[NSError errorWithDomain:@"用户拒绝使用定位"
                                                             code:AWLocationErrorDenied
                                                         userInfo:nil
                                          ]];
        
        return NO;
    }
    
    return YES;
}

- (void)handleCompletion:(CLLocation *)location error:(NSError *)error
{
    self.locatedError = error;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AWLocationManagerDidFinishLocatingNotification object:self];
    
    if ( self.completionBlock ) {
        self.completionBlock(location, error);
        self.completionBlock = nil;
    }
    
    self.locating = NO;
    
    [self.locationManager stopUpdatingLocation];
    
    if ( location ) {
        [self log:[NSString stringWithFormat:@"定位成功：%@", location]];
    } else {
        [self log:[NSString stringWithFormat:@"定位失败：%@", error.domain]];
    }
}

- (void)log:(NSString *)msg
{
#if DEBUG
    NSLog(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,msg);
#endif
}

- (CLLocationCoordinate2D)transformWGS84ToGCJ:(CLLocationCoordinate2D)wgs84Loc
{
    return [WGS84ToGCJ02 transformFromWGSToGCJ:wgs84Loc];
}

@end

//
//  WGS84ToGCJ02.h
//  RTA
//
//  Created by tangwei1 on 16/11/8.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WGS84ToGCJ02 : NSObject

// 判断是否已经超出中国范围
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

// 将WGS-84转为GCJ-02(火星坐标)
// 转GCJ-02
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end

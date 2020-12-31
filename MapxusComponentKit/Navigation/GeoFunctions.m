//
//  GeoFunctions.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "GeoFunctions.h"

@implementation GeoFunctions

+ (BOOL)isPoint0:(CLLocationCoordinate2D)p0 equalToPoint1:(CLLocationCoordinate2D)p1 {
    if (p0.latitude != p1.latitude) {
        return NO;
    } else {
        return p0.longitude == p1.longitude;
    }
}

+ (double)arithmeticDistanceBetweenPoint0:(CLLocationCoordinate2D)p0 andPoint1:(CLLocationCoordinate2D)p1 {
    double dx = p0.latitude - p1.latitude;
    double dy = p0.longitude - p1.longitude;
    return sqrt(dx * dx + dy * dy);
}

+ (double)geoDistanceBetweenPoint0:(CLLocationCoordinate2D)p0 andPoint1:(CLLocationCoordinate2D)p1 {
    double dx = p0.longitude - p1.longitude; // 经度差值
    double dy = p0.latitude - p1.latitude; // 纬度差值
    double b = (p0.latitude + p1.latitude) / 2.0; // 平均纬度
    double Lx = [GeoFunctions radiansConvertFromDegrees:dx] * 6367000.0 * cos([GeoFunctions radiansConvertFromDegrees:b]); // 东西距离
    double Ly = 6367000.0 * [GeoFunctions radiansConvertFromDegrees:dy]; // 南北距离
    return sqrt(Lx * Lx + Ly * Ly);  // 用平面的矩形对角距离公式计算总距离
}

+ (double)radiansConvertFromDegrees:(double)degrees {
    return degrees * M_PI / 180.0;
}

@end

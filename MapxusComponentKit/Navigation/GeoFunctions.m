//
//  GeoFunctions.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "GeoFunctions.h"

static const double R_EARTH_MEAN = 6371008.7714; // Mean Radius Earth [m]; WGS-84
//static const double R_EARTH_MAJOR = 6378137.0; // Radius Earth [m]; WGS-84

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

+ (double)actualDistanceBetweenPoint0:(CLLocationCoordinate2D)p0 andPoint1:(CLLocationCoordinate2D)p1 {
    double radian0 = [self toRadianFromAngle:p0.latitude];
    double radian1 = [self toRadianFromAngle:p1.latitude];
    double a = radian0 - radian1;
    double b = [self toRadianFromAngle:(p0.longitude - p1.longitude)];
    double sa2 = sin(a / 2.0);
    double sb2 = sin(b / 2.0);
    double dist = 2 * R_EARTH_MEAN * asin(sqrt(sa2 * sa2 + cos(radian0) * cos(radian1) * sb2 * sb2));
    return dist;
}

+ (double)toRadianFromAngle:(double)angle {
    return M_PI / 180.0 * angle;
}

@end

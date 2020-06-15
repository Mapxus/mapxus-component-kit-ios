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

@end

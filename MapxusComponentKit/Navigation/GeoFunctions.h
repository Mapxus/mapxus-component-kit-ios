//
//  GeoFunctions.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeoFunctions : NSObject

+ (BOOL)isPoint0:(CLLocationCoordinate2D)p0 equalToPoint1:(CLLocationCoordinate2D)p1;

+ (double)arithmeticDistanceBetweenPoint0:(CLLocationCoordinate2D)p0 andPoint1:(CLLocationCoordinate2D)p1;

@end

NS_ASSUME_NONNULL_END

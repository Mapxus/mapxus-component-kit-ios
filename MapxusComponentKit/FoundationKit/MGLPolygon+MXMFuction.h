//
//  MGLPolygon+MXMFuction.h
//  MapxusMapSDK
//
//  Created by guochenghao on 2023/11/7.
//  Copyright © 2023 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import <CoreLocation/CLLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGLPolygon (MXMFuction)

// 计算落在外框的面上
- (BOOL)mxmRingContains:(CLLocationCoordinate2D)coordinate ignoreBoundary:(BOOL)ignoreBoundary;

// 计算落在外框与孔间的面上，落在边框上也算
- (BOOL)mxmContains:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END

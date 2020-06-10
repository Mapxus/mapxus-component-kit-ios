//
//  MXMRouteProjection.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MXMLineSegment.h"
#import "MXMNavigationPathDTO+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXMRouteProjection : NSObject

+ (nullable CLLocation *)getProjectedResultWithPathDTO:(MXMNavigationPathDTO *)DTO userPosition:(CLLocation *)position key:(NSString *)key maximumDrift:(double)maximumDrift;

+ (nullable MXMLineSegment *)findNearestLineSegmentOnList:(NSArray<MXMLineSegment *> *)list usingCoordinate:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END

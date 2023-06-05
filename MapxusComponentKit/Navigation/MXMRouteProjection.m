//
//  MXMRouteProjection.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMRouteProjection.h"
#import "GeoFunctions.h"
#import "CLLocation+ChangeFloor.h"

@implementation MXMRouteProjection

+ (nullable CLLocation *)getProjectedResultWithPathDTO:(MXMNavigationPathDTO *)DTO userPosition:(CLLocation *)position key:(NSString *)key maximumDrift:(double)maximumDrift {
    CLLocationCoordinate2D projectedCoordinate = [self getProjectionLatLonWithPathDTO:DTO position:position key:key];
    if (CLLocationCoordinate2DIsValid(projectedCoordinate)) {
        double distance = [GeoFunctions geoDistanceBetweenPoint0:projectedCoordinate andPoint1:position.coordinate];
        // 对路线漂移量过大
        if (distance > maximumDrift) {
            return nil;
        }
        CLLocation *location;
        if (@available(iOS 13.4, *)) {
            location = [[CLLocation alloc] initWithCoordinate:projectedCoordinate
                                                     altitude:position.altitude
                                           horizontalAccuracy:position.horizontalAccuracy
                                             verticalAccuracy:position.verticalAccuracy
                                                       course:position.course
                                               courseAccuracy:position.courseAccuracy
                                                        speed:position.speed
                                                speedAccuracy:position.speedAccuracy
                                                    timestamp:position.timestamp];
        } else {
            // Fallback on earlier versions
            location = [[CLLocation alloc] initWithCoordinate:projectedCoordinate
                                                     altitude:position.altitude
                                           horizontalAccuracy:position.horizontalAccuracy
                                             verticalAccuracy:position.verticalAccuracy
                                                       course:position.course
                                                        speed:position.speed
                                                    timestamp:position.timestamp];
        }
        CLFloor *floor = position.floor;
        if (floor) {
            location.myFloor = floor;
        }
        return location;
    } else {
        // 找不到映射点
        return nil;
    }
}

+ (CLLocationCoordinate2D)getProjectionLatLonWithPathDTO:(MXMNavigationPathDTO *)DTO position:(CLLocation *)position key:(NSString *)key {
    NSArray *list = [DTO fragmenntWithKey:key];
    if (list) {
        CLLocationCoordinate2D coordinate = position.coordinate;
        MXMLineSegment *nearestLineSegment = [self findNearestLineSegmentOnList:list usingCoordinate:coordinate];
        if (nearestLineSegment) {
            return [nearestLineSegment findClosestPointInStartEndProjectionToPoint:coordinate];
        }
        return kCLLocationCoordinate2DInvalid;
    } else {
        return kCLLocationCoordinate2DInvalid;
    }
}

+ (nullable MXMLineSegment *)findNearestLineSegmentOnList:(NSArray<MXMLineSegment *> *)list usingCoordinate:(CLLocationCoordinate2D)coordinate {
  MXMLineSegment *nearest = nil;
  double min = DBL_MAX;
  int index = 0;
  for (MXMLineSegment *c in list) {
    double distance;
    if (index == list.count-1) {
      distance = [c closestDistanceToThePointIncludeStartEndProjection:coordinate];
    } else {
      distance = [c closestDistanceToThePointIncludeStartProjection:coordinate];
    }
    if (distance < min) {
      nearest = c;
      min = distance;
    }
    index++;
  }
  return nearest;
}


@end

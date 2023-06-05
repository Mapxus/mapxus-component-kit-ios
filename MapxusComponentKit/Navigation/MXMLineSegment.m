//
//  MXMLineSegment.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMLineSegment.h"
#import "GeoFunctions.h"

@implementation MXMLineSegment

- (instancetype)initWithEndPoint0:(CLLocationCoordinate2D)point0 andEndPoint1:(CLLocationCoordinate2D)point1 onInstructionIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _instructionIndex = index;
        _p0 = point0;
        _p1 = point1;
    }
    return self;
}

- (CLLocationCoordinate2D)projectionOfThePoint:(CLLocationCoordinate2D)point {
    if (![GeoFunctions isPoint0:point equalToPoint1:self.p0] && ![GeoFunctions isPoint0:point equalToPoint1:self.p1]) {
        double r = [self projectionFactorOfThePoint:point];
        double lat = self.p0.latitude + r * (self.p1.latitude - self.p0.latitude);
        double lon = self.p0.longitude + r * (self.p1.longitude - self.p0.longitude);
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
        return coord;
    } else {
        return point;
    }
}

//- (CLLocationCoordinate2D)closestPointToThePoint:(CLLocationCoordinate2D)point {
//    double factor = [self projectionFactorOfThePoint:point];
//    if (factor > 0.0 && factor < 1.0) {
//        return [self projectionOfThePoint:point];
//    } else {
//        double dist0 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p0 andPoint1:point];
//        double dist1 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p1 andPoint1:point];
//        return dist0 < dist1 ? self.p0 : self.p1;
//    }
//}
//
//- (double)distancePerpendicularFromThePoint:(CLLocationCoordinate2D)point {
//    double len2 = (self.p1.latitude - self.p0.latitude) * (self.p1.latitude - self.p0.latitude) + (self.p1.longitude - self.p0.longitude) * (self.p1.longitude - self.p0.longitude);
//    double s = ((self.p0.longitude - point.longitude) * (self.p1.latitude - self.p0.latitude) - (self.p0.latitude - point.latitude) * (self.p1.longitude - self.p0.longitude)) / len2;
//    return fabs(s) * sqrt(len2);
//}

/**
 * 获取当前线段与定位最接近的点的距离：投影点/线段起点/线段终点
 * 如果投影系数为1.0，表示点在线段的终点；如果投影系数在0.0到1.0之间，表示点在线段的中间位置。
 * 返回 "当前定位" 与线段的垂直距离\与线段起点的距离\与线段终点的距离 之中最短的那个距离
 */
- (double)closestDistanceToThePointIncludeStartEndProjection:(CLLocationCoordinate2D)point {
  // 投影系数
  double factor = [self projectionFactorOfThePoint:point];
  // 线段起点-》定位点 的距离
  double dist0 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p0 andPoint1:point];
  // 线段终点-》定位点 的距离
  double dist1 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p1 andPoint1:point];
  
  // 有投影点
  if (factor > 0.0 && factor < 1.0) {
    
    // 定位的投影点
    CLLocationCoordinate2D projection = [self projectionOfThePoint:point];
    
    // 定位点-》线段 的距离
    double dist2 = [GeoFunctions arithmeticDistanceBetweenPoint0:projection andPoint1:point];
    
    // 返回：投影点/线段起点/线段终点 三个点到，到定位点最短的距离的那个
    return  MIN(MIN(dist0, dist1), dist2);
  } else {
    // 没有投影点
    
    // 返回：线段起点/线段终点 两个点，到定位点最短的距离的那个
    return MIN(dist0, dist1);
  }
}

/**
 * 获取当前线段与定位最接近的点的距离：投影点/线段起点
 * 如果投影系数为1.0，表示点在线段的终点；如果投影系数在0.0到1.0之间，表示点在线段的中间位置。
 * 返回 "当前定位" 与线段的垂直距离\与线段起点的距离\与线段终点的距离 之中最短的那个距离
 */
- (double)closestDistanceToThePointIncludeStartProjection:(CLLocationCoordinate2D)point {
  // 投影系数
  double factor = [self projectionFactorOfThePoint:point];
  // 线段起点-》定位点 的距离
  double dist0 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p0 andPoint1:point];
  
  // 有投影点
  if (factor > 0.0 && factor < 1.0) {
    
    // 定位的投影点
    CLLocationCoordinate2D projection = [self projectionOfThePoint:point];
    
    // 定位点-》线段 的距离
    double dist2 = [GeoFunctions arithmeticDistanceBetweenPoint0:projection andPoint1:point];
    
    // 返回：投影点/线段起点 两个点到，到定位点最短的距离的那个
    return MIN(dist0, dist2);
  } else {
    // 没有投影点 直接返回起点
    return dist0;
  }
}

/**
 * 获取当前线段与定位最接近的点的距离：投影点/线段起点/线段终点
 * 如果投影系数为1.0，表示点在线段的终点；如果投影系数在0.0到1.0之间，表示点在线段的中间位置。
 * 返回 投影点/线段起点/线段终点 之中最接近的那个点
 */
- (CLLocationCoordinate2D)findClosestPointInStartEndProjectionToPoint:(CLLocationCoordinate2D)point {
  // 投影系数
  double factor = [self projectionFactorOfThePoint:point];
  // 线段起点-》定位点 的距离
  double dist0 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p0 andPoint1:point];
  // 线段终点-》定位点 的距离
  double dist1 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p1 andPoint1:point];
  
  // 有投影点
  if (factor > 0.0 && factor < 1.0) {
    // 定位的投影点
    CLLocationCoordinate2D projection = [self projectionOfThePoint:point];
    
    // 定位点-》线段 的距离
    double dist2 = [GeoFunctions arithmeticDistanceBetweenPoint0:projection andPoint1:point];
    
    // 返回：投影点/线段起点/线段终点 三个点到，到定位点最短的距离的那个
    double resultDistance = MIN(MIN(dist0, dist1), dist2);
    
    if (resultDistance == dist0) {
      return self.p0;
    } else if (resultDistance == dist2) {
      return projection;
    } else {
      return self.p1;
    }

  } else {
    // 没有投影点
    
    // 返回：线段起点/线段终点 两个点，到定位点最短的距离的那个
    double resultDistance = MIN(dist0, dist1);
    
    if (resultDistance == dist0) {
      return self.p0;
    } else {
      return self.p1;
    }
    
  }
}

- (double)projectionFactorOfThePoint:(CLLocationCoordinate2D)point {
    if ([GeoFunctions isPoint0:point equalToPoint1:self.p0]) {
        return 0.0;
    } else if ([GeoFunctions isPoint0:point equalToPoint1:self.p1]) {
        return 1.0;
    } else {
        double dx = self.p1.latitude - self.p0.latitude;
        double dy = self.p1.longitude - self.p0.longitude;
        double len = dx * dx + dy * dy;
        if (len <= 0.0) {
            return NAN;
        } else {
            double r = ((point.latitude - self.p0.latitude) * dx + (point.longitude - self.p0.longitude) * dy) / len;
            return r;
        }
    }
}

@end

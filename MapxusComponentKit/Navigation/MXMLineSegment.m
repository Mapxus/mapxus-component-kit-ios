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

- (CLLocationCoordinate2D)closestPointToThePoint:(CLLocationCoordinate2D)point {
    double factor = [self projectionFactorOfThePoint:point];
    if (factor > 0.0 && factor < 1.0) {
        return [self projectionOfThePoint:point];
    } else {
        double dist0 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p0 andPoint1:point];
        double dist1 = [GeoFunctions arithmeticDistanceBetweenPoint0:self.p1 andPoint1:point];
        return dist0 < dist1 ? self.p0 : self.p1;
    }
}

- (double)distancePerpendicularFromThePoint:(CLLocationCoordinate2D)point {
    double len2 = (self.p1.latitude - self.p0.latitude) * (self.p1.latitude - self.p0.latitude) + (self.p1.longitude - self.p0.longitude) * (self.p1.longitude - self.p0.longitude);
    double s = ((self.p0.longitude - point.longitude) * (self.p1.latitude - self.p0.latitude) - (self.p0.latitude - point.latitude) * (self.p1.longitude - self.p0.longitude)) / len2;
    return fabs(s) * sqrt(len2);
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

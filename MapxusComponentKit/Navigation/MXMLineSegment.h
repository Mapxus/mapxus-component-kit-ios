//
//  MXMLineSegment.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXMLineSegment : NSObject

@property (nonatomic, assign, readonly) NSUInteger instructionIndex;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D p0;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D p1;

- (instancetype)initWithEndPoint0:(CLLocationCoordinate2D)point0 andEndPoint1:(CLLocationCoordinate2D)point1 onInstructionIndex:(NSUInteger)index;

- (CLLocationCoordinate2D)projectionOfThePoint:(CLLocationCoordinate2D)point;

- (CLLocationCoordinate2D)closestPointToThePoint:(CLLocationCoordinate2D)point;

- (double)distancePerpendicularFromThePoint:(CLLocationCoordinate2D)point;

@end

NS_ASSUME_NONNULL_END

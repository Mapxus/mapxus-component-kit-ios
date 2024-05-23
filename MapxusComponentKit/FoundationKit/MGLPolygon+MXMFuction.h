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

/// This category extends the `MGLPolygon` class with additional methods for checking if a geographic coordinate falls within the polygon.
@interface MGLPolygon (MXMFuction)


/// Determines if a given geographic coordinate falls within the polygon's outer boundary.
///
/// @param coordinate The geographic coordinate to check.
/// @param ignoreBoundary If `YES`, the method considers a coordinate on the boundary as outside the polygon.
/// @return A Boolean value indicating whether the coordinate is within the polygon's outer boundary.
///
/// This method is ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L77-L108
- (BOOL)mxmRingContains:(CLLocationCoordinate2D)coordinate ignoreBoundary:(BOOL)ignoreBoundary;


/// Determines if a given geographic coordinate falls within the polygon, including its holes.
///
/// @param coordinate The geographic coordinate to check.
/// @return A Boolean value indicating whether the coordinate is within the polygon, including its holes.
///
/// A coordinate on the boundary is considered as inside the polygon.
- (BOOL)mxmContains:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END

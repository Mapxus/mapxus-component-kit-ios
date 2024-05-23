//
//  MXMRouteAdsorber.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/9.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusComponentKit/MXMNavigationPathDTO.h>

NS_ASSUME_NONNULL_BEGIN

/// Enumeration representing the adsorption status.
typedef enum : NSUInteger {
  /// Represents the normal adsorption state.
  MXMAdsorptionStateDefault,
  /// Represents the state where, due to the density of the road network and positioning errors, the adsorption point cannot be found at the beginning of navigation. This indicates that the user is still some distance away from the planned route. This situation is generally not classified as an error and the user can be guided closer to the starting point of the planned route.
  MXMAdsorptionStateNotStartBinding,
  /// Represents the state where positioning has drifted and the adsorption point cannot be found, but the number of drifts is less than or equal to `numberOfAllowedDrifts`.
  MXMAdsorptionStateDrifting,
  /// Represents the state where the number of consecutive failed adsorption points during the normal adsorption state is greater than `numberOfAllowedDrifts`.
  MXMAdsorptionStateDriftsNumberExceeded,
} MXMAdsorptionState;



/// Protocol for the callback of adsorption calculation results.
@protocol MXMRouteAdsorberDelegate <NSObject>


@optional
/// Callback method that outputs the calculated adsorption point information.
///
/// @param location The calculated adsorption point. When the `state` value is `MXMAdsorptionStateNotStartBinding` or `MXMAdsorptionStateDriftsNumberExceeded`, 
///        the returned `location` and `actual` will be equal. When the `state` value is `MXMAdsorptionStateDrifting`, the returned value will be the last calculated adsorption point.
/// @param venueId The calculated ID of the venue where the adsorption point is located.
/// @param buildingId The calculated ID of the building where the adsorption point is located.
/// @param floorId The calculated ID of the floor where the adsorption point is located.
/// @param state The adsorption status.
/// @param actual The original location.
- (void)refreshTheAdsorptionLocation:(CLLocation *)location
                             venueId:(nullable NSString *)venueId
                          buildingId:(nullable NSString *)buildingId
                             floorId:(nullable NSString *)floorId
                               state:(MXMAdsorptionState)state
                          fromActual:(CLLocation *)actual;

- (void)refreshTheAdsorptionLocation:(CLLocation *)location
                          buildingID:(nullable NSString *)buildingID
                               floor:(nullable NSString *)floor
                               state:(MXMAdsorptionState)state
                          fromActual:(CLLocation *)actual
DEPRECATED_MSG_ATTRIBUTE("Please use `- [MXMRouteAdsorberDelegate refreshTheAdsorptionLocation:venueId:buildingId:floorId:state:fromActual:]`");

@end



/// Adsorber class, responsible for calculating the adsorption position of the positioning point for a given planned route.
@interface MXMRouteAdsorber : NSObject


/// Property for the number of drifts allowed, default value is 3.
@property (nonatomic, assign) NSUInteger numberOfAllowedDrifts;


/// Property for the maximum permissible drift in meters, default value is 20m.
@property (nonatomic, assign) double maximumDrift;


/// This property is a delegate of the `MXMRouteAdsorber` class.
@property (nonatomic, weak) id<MXMRouteAdsorberDelegate> delegate;


/// Method to enter navigation data for the selected planning route.
///
/// @param navigationPathDTO Navigation data for selected planning routes.
- (void)updateNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO;


/// Method to calculate adsorption points relative to the planned route by real positioning.
///
/// @param actual The actual location.
- (void)calculateTheAdsorptionLocationFromActual:(CLLocation *)actual;

@end

NS_ASSUME_NONNULL_END

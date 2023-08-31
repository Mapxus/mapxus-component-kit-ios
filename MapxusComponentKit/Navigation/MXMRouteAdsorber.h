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


/**
 * Adsorption status
 */
typedef enum : NSUInteger {
    /// Normal adsorption state
    MXMAdsorptionStateDefault,
    
    /// Because of the density of the road network and positioning errors, at the beginning of the navigation there will be a situation where the adsorption point cannot be found, indicating that the user is still some distance away from the planned route, this situation is generally not classified as an error and the user can be guided closer to the starting point of the planned route
    MXMAdsorptionStateNotStartBinding,
    
    /// Positioning has drifted and the adsorption point cannot be found, but the number is less than or equal to `numberOfAllowedDrifts`
    MXMAdsorptionStateDrifting,
    
    /// The number of consecutive failed adsorption points during the normal adsorption state is greater than `numberOfAllowedDrifts`.
    MXMAdsorptionStateDriftsNumberExceeded,

    
} MXMAdsorptionState;


/**
 * Callback protocol for adsorption calculation results
 */
@protocol MXMRouteAdsorberDelegate <NSObject>

@optional

/**
 * The callback outputs the calculated adsorption point information
 *
 * @param location The calculated adsorption point. When the `state` value is `MXMAdsorptionStateNotStartBinding` and `MXMAdsorptionStateDriftsNumberExceeded`, the `location` and `actual` returned will be equal. When the value of `state` is `MXMAdsorptionStateDrifting`, the returned value will be the last calculated adsorption point
 * @param venueId Calculated ID of the venue where the adsorption point is located
 * @param buildingId Calculated ID of the building where the adsorption point is located
 * @param floorId Calculated ID of the floor where the adsorption point is located
 * @param state Adsorption status
 * @param actual Original location
 */
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


/**
 * Adsorber, calculation of the adsorption position of the positioning point for a given planning route
 */
@interface MXMRouteAdsorber : NSObject

/// Number of drifts allowed, default value is 3
@property (nonatomic, assign) NSUInteger numberOfAllowedDrifts;

/// Maximum permissible drift in (m), default value is 20m
@property (nonatomic, assign) double maximumDrift;

/// Handle
@property (nonatomic, weak) id<MXMRouteAdsorberDelegate> delegate;

/**
 * Enter navigation data for the selected planning route
 *
 * @param navigationPathDTO Navigation data for selected planning routes
 */
- (void)updateNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO;

/**
 * Calculation of adsorption points relative to the planned route by real positioning
 *
 * @param actual The actual location
 */
- (void)calculateTheAdsorptionLocationFromActual:(CLLocation *)actual;

@end

NS_ASSUME_NONNULL_END

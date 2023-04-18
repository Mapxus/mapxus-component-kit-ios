//
//  MXMRouteShortener.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>
#import <MapxusComponentKit/MXMNavigationPathDTO.h>

NS_ASSUME_NONNULL_BEGIN

@class MXMRouteShortener;


/**
 * Results callback protocol from route shortener
 */
@protocol MXMRouteShortenerDelegate <NSObject>

/**
 * Shorten the calculation result callback. After the result has been calculated, the calculation result is output by calling this method
 *
 * @param shortener Performing shortened executors
 * @param path Shortened route
 * @param index Subscripts on the original complete route
 */
- (void)routeShortener:(MXMRouteShortener *)shortener redrawingNewPath:(MXMPath *)path fromInstructionIndex:(NSUInteger)index;

@end


/**
 * Route shortening tool with which to perform route shortening calculations
 */
@interface MXMRouteShortener : NSObject

/// Handle
@property (nonatomic, weak) id<MXMRouteShortenerDelegate> delegate;

/// The original complete route
@property (nonatomic, strong, readonly) MXMPath *originalPath;

/// The original full list of waypoints
@property (nonatomic, strong, readonly) NSArray<MXMIndoorPoint *> *originalWayPoints;

/**
 * Enter calculation elements
 *
 * @param path Select the planned route to be displayed
 * @param wayPoints List of passing points
 * @param navigationPathDTO Navigation data
 */
- (void)inputSourceWithOriginalPath:(MXMPath *)path originalWayPoints:(NSArray<MXMIndoorPoint *> *)wayPoints andNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO;

/**
 * Calculation of shortened routes from mapping points
 *
 * @param projection Mapped positioning of original positioning points on the route
 * @param buildingID Locate the building ID
 * @param floor Locate the name of the floor you are on
 */
- (void)cutFromTheLocationProjection:(CLLocation *)projection buildingID:(nullable NSString *)buildingID andFloor:(nullable NSString *)floor;

@end

NS_ASSUME_NONNULL_END

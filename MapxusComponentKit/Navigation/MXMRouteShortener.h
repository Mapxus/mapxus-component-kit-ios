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



/// `MXMRouteShortenerDelegate` is a protocol that defines the callback methods for the route shortening process.
@protocol MXMRouteShortenerDelegate <NSObject>


/// This method is a callback that outputs the result of the route shortening calculation.
///
/// @param shortener The `MXMRouteShortener` instance that performed the route shortening.
/// @param path The shortened route.
/// @param index The index on the original complete route where the shortening took place.
- (void)routeShortener:(MXMRouteShortener *)shortener 
      redrawingNewPath:(MXMPath *)path
  fromInstructionIndex:(NSUInteger)index;

@end



/// `MXMRouteShortener` is a tool for performing route shortening calculations.
@interface MXMRouteShortener : NSObject


/// The delegate to handle route shortening events.
@property (nonatomic, weak) id<MXMRouteShortenerDelegate> delegate;


/// The original complete route that needs to be shortened.
@property (nonatomic, strong, readonly) MXMPath *originalPath;


/// The original full list of waypoints on the route.
@property (nonatomic, strong, readonly) NSArray<MXMIndoorPoint *> *originalWayPoints;


/// This method inputs the source data for route shortening calculations.
///
/// @param path The planned route to be displayed.
/// @param wayPoints The list of passing points on the route.
/// @param navigationPathDTO The navigation data for the route.
- (void)inputSourceWithOriginalPath:(MXMPath *)path 
                  originalWayPoints:(NSArray<MXMIndoorPoint *> *)wayPoints
               andNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO;


/// This method calculates the shortened route from the mapped points.
///
/// @param projection The mapped positioning of original positioning points on the route.
/// @param floorId The ID of the floor where the user is located.
- (void)cutFromTheLocationProjection:(CLLocation *)projection floorId:(nullable NSString *)floorId;

- (void)cutFromTheLocationProjection:(CLLocation *)projection buildingID:(nullable NSString *)buildingID andFloor:(nullable NSString *)floor DEPRECATED_MSG_ATTRIBUTE("Please use `- [MXMRouteShortener cutFromTheLocationProjection:floorId:]`");

@end

NS_ASSUME_NONNULL_END

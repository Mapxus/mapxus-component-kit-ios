//
//  MXMRoutePainter.h
//  MXMComponentKit
//
//  Created by Chenghao Guo on 2018/10/17.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>

#import <MapxusComponentKit/MXMPainterPathDto.h>
#import <MapxusComponentKit/MXMWaypointInfo.h>


NS_ASSUME_NONNULL_BEGIN

/// This class is a tool for drawing planned routes and provides route rendering.
@interface MXMRoutePainter : NSObject


/// Color of the indoor line segment.
@property (nonatomic, strong) UIColor *indoorLineColor;


/// Color of the outdoor line segment.
@property (nonatomic, strong) UIColor *outdoorLineColor;


/// Color of the shuttle bus line segment.
@property (nonatomic, strong) UIColor *shuttleBusLineColor;


/// Color of the dashed line segment.
@property (nonatomic, strong) UIColor *dashLineColor;


/// Interval of the line direction indication icon.
@property (nonatomic, strong) NSNumber *arrowSymbolSpacing;


/// Icon indicating the direction of the line.
@property (nonatomic, strong) UIImage *arrowIcon;


/// Starting point icon
@property (nonatomic, strong) UIImage *startIcon DEPRECATED_MSG_ATTRIBUTE("`startIcon` is deprecated, please use `waypointInfos`");


/// Endpoint icon
@property (nonatomic, strong) UIImage *endIcon DEPRECATED_MSG_ATTRIBUTE("`endIcon` is deprecated, please use `waypointInfos`");


/// Each waypoint is represented by an icon.
///
/// @discussion
/// The first data in the queue is used for the start of the `waypointInfos`, while the last data in the queue is used for
/// the end of the `waypointInfos`. For the middle point of the waypoint, if the serial number is less than the total number of `waypointInfos` in the queue
/// minus one, the icon corresponding to the serial number of the `waypointInfos` will be used. All other waypoints will use the last icon in the `waypointInfos` queue.
/// If you have some of these points that you don't want to use icons for, set the `icon` property of `MXMWaypointInfo` to nil and add this `MXMWaypointInfo`
/// object to this queue.
@property (nonatomic, copy, null_resettable) NSArray<MXMWaypointInfo *> *waypointInfos;


/// Icon for the lift up.
@property (nonatomic, strong) UIImage *elevatorUpIcon;


/// Icon for the lift down.
@property (nonatomic, strong) UIImage *elevatorDownIcon;


/// Icon for the escalator up.
@property (nonatomic, strong) UIImage *escalatorUpIcon;


/// Icon for the escalator down.
@property (nonatomic, strong) UIImage *escalatorDownIcon;


/// Icon for the ramp up.
@property (nonatomic, strong) UIImage *rampUpIcon;


/// Icon for the ramp down.
@property (nonatomic, strong) UIImage *rampDownIcon;


/// Icon for the stairs up.
@property (nonatomic, strong) UIImage *stairsUpIcon;


/// Icon for the stairs down.
@property (nonatomic, strong) UIImage *stairsDownIcon;


/// Icon for the gate.
@property (nonatomic, strong) UIImage *buildingGateIcon;


/// Add the dashed line segment from the start point to the start of the road network.
@property (nonatomic, assign) BOOL isAddStartDash;


/// Add a dashed end between the incoming waypoints and the waypoints of the returned results.
@property (nonatomic, assign) BOOL isAddViaDash;


/// Add a dashed line segment from the end point to the end of the road network.
@property (nonatomic, assign) BOOL isAddEndDash;


/// Hide routes on unselected floors, default is NO.
@property (nonatomic, assign) BOOL hiddenTranslucentPaths;


/// Select the data source to be plotted.
@property (nonatomic, strong, nullable) MXMPainterPathDto *dto;


/// Disable the following two initializations.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


/// Initializer for the route painter.
///
/// @param mapView The view where the rendering will take place.
/// @return An instance of the MXMRoutePainter object.
- (instancetype)initWithMapView:(MGLMapView *)mapView;


/// Paint a planned route.
///
/// @param path One of the route planning results.
/// @param list List of waypoints.
///
/// @discussion
/// This method is available in the `- [MXMSearchDelegate onRouteSearchDone:response:]` method.
- (void)paintRouteUsingPath:(MXMPath *)path wayPoints:(NSArray<MXMIndoorPoint *> *)list;


/// Clear the drawn route on the mapView.
- (void)cleanRoute;


/// Toggle the transparency of the paragraphs on the corresponding building and floor.
///
/// @param venueId The id of the venue which you want to show.
/// @param ordinal The ordinal of the floor you want to show.
///
/// @discussion
/// This method is called in the `- [MapxusMapDelegate map:didChangeSelectedFloor:inSelectedBuildingId:atSelectedVenueId:` method.
- (void)changeOnVenue:(nullable NSString *)venueId ordinal:(nullable MXMOrdinal *)ordinal;


/// Zoom focus to a given paragraph.
///
/// @param keys List of focus paragraphs.
/// @param insets Zoom margins.
- (void)focusOnKeys:(NSArray<NSString*> *)keys edgePadding:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END

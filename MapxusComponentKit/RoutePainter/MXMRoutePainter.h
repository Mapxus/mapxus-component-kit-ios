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


NS_ASSUME_NONNULL_BEGIN


/**
 Planned route drawing tool, providing planned route rendering
 */
@interface MXMRoutePainter : NSObject

/// Indoor line segment colour
@property (nonatomic, strong) UIColor *indoorLineColor;

/// Outdoor line segment colour
@property (nonatomic, strong) UIColor *outdoorLineColor;

/// Dashed segment colour
@property (nonatomic, strong) UIColor *dashLineColor;

/// Line direction indication icon interval
@property (nonatomic, strong) NSNumber *arrowSymbolSpacing;

/// Line direction indicator icon
@property (nonatomic, strong) UIImage *arrowIcon;

/// Starting point icon
@property (nonatomic, strong) UIImage *startIcon;

/// Endpoint icon
@property (nonatomic, strong) UIImage *endIcon;

/// Lift up icon
@property (nonatomic, strong) UIImage *elevatorUpIcon;

/// Lift down icon
@property (nonatomic, strong) UIImage *elevatorDownIcon;

/// Escalator up icon
@property (nonatomic, strong) UIImage *escalatorUpIcon;

/// Escalator down icon
@property (nonatomic, strong) UIImage *escalatorDownIcon;

/// Ramp up icon
@property (nonatomic, strong) UIImage *rampUpIcon;

/// Ramp down icon
@property (nonatomic, strong) UIImage *rampDownIcon;

/// Stairs up icon
@property (nonatomic, strong) UIImage *stairsUpIcon;

/// Stairs down icon
@property (nonatomic, strong) UIImage *stairsDownIcon;

/// Gate icon
@property (nonatomic, strong) UIImage *buildingGateIcon;

/// Add the dotted line segment from the start point to the start of the road network
@property (nonatomic, assign) BOOL isAddStartDash;

/// Add a dashed line segment from the end point to the end of the road network
@property (nonatomic, assign) BOOL isAddEndDash;

/// Hide routes on unselected floors, default is NO
@property (nonatomic, assign) BOOL hiddenTranslucentPaths;

/// Select the data source to be plotted
@property (nonatomic, strong, nullable) MXMPainterPathDto *dto;

/// Disable the following two initializations
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Initialising the route painter
 @param mapView Rendering view
 @return MXMRoutePainter object
 */
- (instancetype)initWithMapView:(MGLMapView *)mapView;

/**
 Paint a planned route, available in the `MXMSearchDelegate` - onRouteSearchDone:response: method
 @param path One of route planning result
 @param list Way points list
 */
- (void)paintRouteUsingPath:(MXMPath *)path wayPoints:(NSArray<MXMIndoorPoint *> *)list;

/**
 Clear the drawn route on the mapView
 */
- (void)cleanRoute;

/**
 Toggle the transparency of the paragraphs on the corresponding building and floor, called in the `MapxusMapDelegate` - mapView:didChangeFloor:atBuilding: method
 @param venueId The id of venue which you want to show
 @param ordinal The ordinal of floor you want to show
 */
- (void)changeOnVenue:(nullable NSString *)venueId ordinal:(nullable MXMOrdinal *)ordinal;

/**
 Zoom focus to a given paragraph
 @param keys Focus paragraph list
 @param insets Zoom Margins
 */
- (void)focusOnKeys:(NSArray<NSString*> *)keys edgePadding:(UIEdgeInsets)insets;


@end

NS_ASSUME_NONNULL_END

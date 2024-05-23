//
//  MXMPainterPathDto.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/26.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MXMCommonObj.h>
#import <MapxusComponentKit/MXMParagraph.h>


NS_ASSUME_NONNULL_BEGIN

/// This class is used to collate data for route planning.
@interface MXMPainterPathDto : NSObject


/// The starting point of the route. This property is deprecated, please use `wayPoints` instead.
@property (nonatomic, strong, readonly) MXMIndoorPoint *startPoint DEPRECATED_MSG_ATTRIBUTE("Please use `waypoints` instead.");


/// The ending point of the route. This property is deprecated, please use `wayPoints` instead.
@property (nonatomic, strong, readonly) MXMIndoorPoint *endPoint DEPRECATED_MSG_ATTRIBUTE("Please use `waypoints` instead.");


/// The raw waypoints that were passed in during navigation searches.
@property (nonatomic, strong, readonly) NSArray<MXMIndoorPoint *> *waypoints;


/// The keys used in planning order. 
///
/// @discussion
/// Outdoor passages are separated from indoor passages by outdoor-1, outdoor-2 or buildingId-floor-1... to distinguish them. The indoor sections are grouped
/// together by buildingId and floor.
@property (nonatomic, strong, readonly) NSArray<NSString*> *keys;


/// The details of each paragraph.
@property (nonatomic, strong, readonly) NSDictionary<NSString *, MXMParagraph *> *paragraphs;


/// Initialisation function.
///
/// @param path One of the paths from the planning interface `- [ MXMSearchAPI MXMRouteSearch:]`.
/// @param start The starting point.
/// @param end The ending point.
/// @return An MXMPainterPathDto object.
- (instancetype)initWithPath:(MXMPath *)path startPoint:(MXMIndoorPoint *)start endPoint:(MXMIndoorPoint *)end DEPRECATED_MSG_ATTRIBUTE("Please use `- initWithPath:wayPoints:` instead.");


/// Initialisation function.
///
/// @param path One of the paths from the planning interface `- [ MXMSearchAPI MXMRouteSearch:]`.
/// @param points The waypoints.
/// @return An MXMPainterPathDto object.
- (instancetype)initWithPath:(MXMPath *)path wayPoints:(NSArray<MXMIndoorPoint *> *)points;

@end

NS_ASSUME_NONNULL_END

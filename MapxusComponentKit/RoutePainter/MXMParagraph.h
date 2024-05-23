//
//  MXMParagraph.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/13.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// Paragraph Turning Point Types
typedef NS_ENUM(NSUInteger, MXMParagraphTurningType) {
    StartEndPoint = 0,
    ElevatorUp,
    ElevatorDown,
    EscalatorUp,
    EscalatorDown,
    RampUp,
    RampDown,
    StairsUp,
    StairsDown,
    BuildingGate,
};



/// This class represents a segment model. Each segment consists of consecutive outdoor coordinates or consecutive indoor coordinates of the same building floor.
@interface MXMParagraph : NSObject


/// The key used in planning order. 
///
/// @discussion
/// Outdoor passages are separated from indoor passages by identifiers such as outdoor-1, outdoor-2 or buildingId-floor-1, etc. Indoor sections are grouped together
/// by buildingId and floor.
@property (nonatomic, strong) NSString *key;


/// The type of line color. 0 represents outdoor, 1 represents indoor, and 2 represents bus.
@property (nonatomic, assign) NSInteger lineColorType;


/// The ID of the venue where the segment is located. If the segment is outdoor, this property is nil.
@property (nonatomic, strong, nullable) NSString *venueId;


/// The ID of the building where the segment is located. If the segment is outdoor, this property is nil.
@property (nonatomic, strong, nullable) NSString *buildingId;


/// The ID of the floor where the segment is located. If the segment is outdoor, this property is nil.
@property (nonatomic, strong, nullable) NSString *floorId;


/// The ordinal of the floor where the segment is located. If the segment is outdoor, this property is nil.
@property (nonatomic, strong, nullable) MXMOrdinal *ordinal;


/// The floor where the segment is located. This property is deprecated, please use `floorId` instead.
@property (nonatomic, strong, nullable) NSString *floor DEPRECATED_MSG_ATTRIBUTE("Please use `floorId`");


/// The type of turning point at the beginning of a segment.
@property (nonatomic, assign) MXMParagraphTurningType startPointType;


/// The types of turning points at the end of a segment.
@property (nonatomic, assign) MXMParagraphTurningType endPointType;


/// The coordinate points contained in a segment.
@property (nonatomic, strong) NSMutableArray<MXMGeoPoint *> *points;

@end

NS_ASSUME_NONNULL_END

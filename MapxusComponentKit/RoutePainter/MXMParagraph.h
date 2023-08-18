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

/**
 Paragraph Turning Point Types
 */
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



/**
 A segment model, with consecutive outdoor coordinates or consecutive indoor coordinates of the same building floor as a segment.
 */
@interface MXMParagraph : NSObject
/**
 Key in planning order, where outdoor passages are separated by indoor passages by outdoor 1, outdoor 2 or buildingId-floor 1... to distinguish them.
 The indoor sections are grouped together by buildingId and floor.
 */
@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong, nullable) NSString *venueId;
/// ID of the building in which the segment is located, nil means outside
@property (nonatomic, strong, nullable) NSString *buildingId;
/// The floorId where the paragraph is located, nil means outside
@property (nonatomic, strong, nullable) NSString *floorId;
/// The floor ordinal where the paragraph is located, nil means outside
@property (nonatomic, strong, nullable) MXMOrdinal *ordinal;
/// The floor where the paragraph is located, nil means outside
@property (nonatomic, strong, nullable) NSString *floor DEPRECATED_MSG_ATTRIBUTE("Please use `floorId`");
/// Type of turning point at the beginning of a paragraph
@property (nonatomic, assign) MXMParagraphTurningType startPointType;
/// Types of turning points at the end of paragraphs
@property (nonatomic, assign) MXMParagraphTurningType endPointType;
/// Coordinate points contained in a paragraph
@property (nonatomic, strong) NSMutableArray<MXMGeoPoint *> *points;
@end

NS_ASSUME_NONNULL_END

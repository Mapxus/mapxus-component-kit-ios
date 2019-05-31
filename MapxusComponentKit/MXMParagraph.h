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

typedef NS_ENUM(NSUInteger, RoutePainterNodeType) {
    StartEndPoint,
    ElevatorGoodUp,
    ElevatorGoodDown,
    EscalatorUp,
    EscalatorDown,
    RampUp,
    RampDown,
    StairsUp,
    StairsDown,
    BuildingGate,
};


@interface MXMParagraph : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong, nullable) NSString *buildingId;
@property (nonatomic, strong, nullable) NSString *floor;
@property (nonatomic, assign) RoutePainterNodeType startPointType;
@property (nonatomic, assign) RoutePainterNodeType endPointType;
@property (nonatomic, strong) NSMutableArray<MXMGeoPoint *> *points;

@end

NS_ASSUME_NONNULL_END

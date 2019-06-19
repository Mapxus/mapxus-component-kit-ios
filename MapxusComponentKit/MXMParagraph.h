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
 段落转折点类型
 - StartEndPoint: 起始点
 - ElevatorUp: 电梯上行
 - ElevatorDown: 电梯下行
 - EscalatorUp: 扶手梯上行
 - EscalatorDown: 扶手梯下行
 - RampUp: 斜坡上行
 - RampDown: 斜坡下行
 - StairsUp: 楼梯上行
 - StairsDown: 楼梯下行
 - BuildingGate: 穿过门口
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
 * 段落模型，连续的室外坐标或连续同一建筑楼层的室内坐标为一个段落。
 */
@interface MXMParagraph : NSObject
/**
 段落关键字，室外段落如果有室内段落隔开，以 outdoor1、outdoor2... 来区分标识，
 室内段落 key 以 buildingId-floor 拼接而成。
 */
@property (nonatomic, strong) NSString *key;
/// 段落所在建筑的ID，nil表示在室外
@property (nonatomic, strong, nullable) NSString *buildingId;
/// 段落所在楼层，nil表示在室外
@property (nonatomic, strong, nullable) NSString *floor;
/// 段落开始处的转折点类型
@property (nonatomic, assign) MXMParagraphTurningType startPointType;
/// 段落结尾处的转折点类型
@property (nonatomic, assign) MXMParagraphTurningType endPointType;
/// 段落包含的坐标点
@property (nonatomic, strong) NSMutableArray<MXMGeoPoint *> *points;
@end

NS_ASSUME_NONNULL_END

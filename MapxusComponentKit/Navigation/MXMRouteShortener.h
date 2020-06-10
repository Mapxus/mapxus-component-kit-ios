//
//  MXMRouteShortener.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>
#import "MXMNavigationPathDTO.h"

NS_ASSUME_NONNULL_BEGIN

@class MXMRouteShortener;


/**
 * 路线缩短工具的结果回调协议
 */
@protocol MXMRouteShortenerDelegate <NSObject>

/**
 * 缩短计算结果回调。在计算好结果后，通过调用此方法输出计算结果
 *
 * @param shortener 进行缩短的对象
 * @param path 进行缩短后的路线
 * @param index 在原始完整路线上的下标号
 */
- (void)routeShortener:(MXMRouteShortener *)shortener redrawingNewPath:(MXMPath *)path fromInstructionIndex:(NSUInteger)index;

@end


/**
 * 路线缩短工具，通过此工具进行路线缩短计算
 */
@interface MXMRouteShortener : NSObject

/// 委托人句柄
@property (nonatomic, weak) id<MXMRouteShortenerDelegate> delegate;

/// 原始的完整路线
@property (nonatomic, strong, readonly) MXMPath *originalPath;

/// 原始的完整途经点列表
@property (nonatomic, strong, readonly) NSArray<MXMIndoorPoint *> *originalWayPoints;

/**
 * 输入计算要素
 *
 * @param path 选择要显示的规划路线
 * @param wayPoints 途经点列表
 * @param navigationPathDTO 导航数据
 */
- (void)inputSourceWithOriginalPath:(MXMPath *)path originalWayPoints:(NSArray<MXMIndoorPoint *> *)wayPoints andNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO;

/**
 * 从映射点开始计算缩短路线
 *
 * @param projection 原始定位点在路线上的映射定位
 * @param buildingID 定位所在建筑ID
 * @param floor 定位所在楼层名字
 */
- (void)cutFromTheLocationProjection:(CLLocation *)projection buildingID:(nullable NSString *)buildingID andFloor:(nullable NSString *)floor;

@end

NS_ASSUME_NONNULL_END

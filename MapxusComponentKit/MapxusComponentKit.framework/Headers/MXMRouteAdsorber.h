//
//  MXMRouteAdsorber.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/9.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXMNavigationPathDTO.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * 吸附状态
 */
typedef enum : NSUInteger {
    /// 正常吸附状态
    MXMAdsorptionStateDefault,
    
    /// 因为路网密度及定位误差原因，在导航开始时会出现找不到吸附点的情况，表明用户离可规划路线还有一定距离，这种情况一般不归为错误，可引导用户向规划路线起点靠近
    MXMAdsorptionStateNotStartBinding,
    
    /// 定位发生了漂移，找不到吸附点，但次数小于等于`numberOfAllowedDrifts`
    MXMAdsorptionStateDrifting,
    
    /// 在正常吸附状态期间，连续找不到吸附点次数大于`numberOfAllowedDrifts`
    MXMAdsorptionStateDriftsNumberExceeded,

    
} MXMAdsorptionState;


/**
 * 吸附计算结果回调协议
 */
@protocol MXMRouteAdsorberDelegate <NSObject>

/**
 * 回调输出计算出的吸附点信息
 *
 * @param location 计算出的吸附点。当`state`值为`MXMAdsorptionStateNotStartBinding`与`MXMAdsorptionStateDriftsNumberExceeded`时，返回的`location`与`actual`会相等；
 *                当`state`值为`MXMAdsorptionStateDrifting`时，返回值为上一次计算的吸附点
 * @param buildingID 计算出的吸附点所在建筑ID
 * @param floor 计算出的吸附点所在的楼层名字
 * @param state 吸附状态标识
 * @param actual 原始的定位点
 */
- (void)refreshTheAdsorptionLocation:(CLLocation *)location buildingID:(nullable NSString *)buildingID floor:(nullable NSString *)floor state:(MXMAdsorptionState)state fromActual:(CLLocation *)actual;

@end


/**
 * 吸附器，计算定位点在给定规划路线的吸附位置
 */
@interface MXMRouteAdsorber : NSObject

/// 允许漂移次数，默认值为3
@property (nonatomic, assign) NSUInteger numberOfAllowedDrifts;

/// 最大允许漂移量，单位(m)，默认值为20m
@property (nonatomic, assign) double maximumDrift;

/// 委托人句柄
@property (nonatomic, weak) id<MXMRouteAdsorberDelegate> delegate;

/**
 * 输入选定规划路线的导航数据
 *
 * @param navigationPathDTO 选定规划路线的导航数据
 */
- (void)updateNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO;

/**
 * 通过真实定位计算出相对于规划路线的吸附点
 *
 * @param actual 真实的定位
 */
- (void)calculateTheAdsorptionLocationFromActual:(CLLocation *)actual;

@end

NS_ASSUME_NONNULL_END

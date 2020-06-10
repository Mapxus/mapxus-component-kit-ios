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

#import "MXMPainterPathDto.h"


NS_ASSUME_NONNULL_BEGIN


/**
 * 规划路线绘制工具，提供规划路线渲染功能
 */
@interface MXMRoutePainter : NSObject

/// 室内线段颜色
@property (nonatomic, strong) UIColor *indoorLineColor;

/// 室外线段颜色
@property (nonatomic, strong) UIColor *outdoorLineColor;

/// 虚线段颜色
@property (nonatomic, strong) UIColor *dashLineColor;

/// 线路方向指示图标间隔
@property (nonatomic, strong) NSNumber *arrowSymbolSpacing;

/// 线路方向指示图标
@property (nonatomic, strong) UIImage *arrowIcon;

/// 起点图标
@property (nonatomic, strong) UIImage *startIcon;

/// 终点图标
@property (nonatomic, strong) UIImage *endIcon;

/// 电梯上行图标
@property (nonatomic, strong) UIImage *elevatorUpIcon;

/// 电梯下行图标
@property (nonatomic, strong) UIImage *elevatorDownIcon;

/// 扶梯上行图标
@property (nonatomic, strong) UIImage *escalatorUpIcon;

/// 扶梯下行图标
@property (nonatomic, strong) UIImage *escalatorDownIcon;

/// 斜坡上行图标
@property (nonatomic, strong) UIImage *rampUpIcon;

/// 斜坡下行图标
@property (nonatomic, strong) UIImage *rampDownIcon;

/// 楼梯上行图标
@property (nonatomic, strong) UIImage *stairsUpIcon;

/// 楼梯下行图标
@property (nonatomic, strong) UIImage *stairsDownIcon;

/// 门口图标
@property (nonatomic, strong) UIImage *buildingGateIcon;

@property (nonatomic, assign) BOOL isAddStartDash;

@property (nonatomic, assign) BOOL isAddEndDash;

/// 选中绘制的数据源
@property (nonatomic, strong, nullable) MXMPainterPathDto *dto;

/// 禁用下面两个初始化
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 初始化路线规划绘制工具
 @param mapView 用于展示路线的mapView
 @return 初始化后的对象
 */
- (instancetype)initWithMapView:(MGLMapView *)mapView;

/**
 绘制规划路线，可在`MXMSearchDelegate` - onRouteSearchDone:response:方法里获取规划结果
 @param result 路线规划结果
 */
- (void)paintRouteUsingResult:(MXMRouteSearchResponse *)result DEPRECATED_MSG_ATTRIBUTE("Use `-paintRouteUsingPath:wayPoints:` instead.");

/**
 绘制规划路线，可在`MXMSearchDelegate` - onRouteSearchDone:response:方法里获取规划结果
 @param path 路线规划结果
 @param list 始终点列表
 */
- (void)paintRouteUsingPath:(MXMPath *)path wayPoints:(NSArray<MXMIndoorPoint *> *)list;

/**
 清除mapView上已绘制的路线
 */
- (void)cleanRoute;

/**
 切换对应建筑与楼层上的段落透明度，可在`MapxusMapDelegate` - mapView:didChangeFloor:atBuilding:方法里调用
 @param buildingId 建筑ID
 @param floor 楼层名字
 */
- (void)changeOnBuilding:(nullable NSString *)buildingId floor:(nullable NSString *)floor;

/**
 缩放聚焦到给定的段落
 @param keys 给定聚焦段落
 @param insets 缩放边距
 */
- (void)focusOnKeys:(NSArray<NSString*> *)keys edgePadding:(UIEdgeInsets)insets;


@end

NS_ASSUME_NONNULL_END

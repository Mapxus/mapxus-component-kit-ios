//
//  MXMRoutePainter.h
//  MXMComponentKit
//
//  Created by Chenghao Guo on 2018/10/17.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>
#import <Mapbox/Mapbox.h>

NS_ASSUME_NONNULL_BEGIN

/**
 路线规划绘制类，对结果进行分层与渲染
 */
@interface MXMRoutePainter : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 初始化路线规划绘制类

 @param mapView 用于展示路线的mapView
 @return 路线规划绘制类
 */
- (instancetype)initWithMapView:(MGLMapView *)mapView map:(MapxusMap *)map;

/**
 清除mapView上已绘制的路线
 */
- (void)cleanRoute;

/**
 切换对应建筑与楼层上的路线，可在`MapxusMapDelegate` - mapView:didChangeFloor:atBuilding:方法里调用切换

 @param buildingId 建筑ID
 @param floor 楼层名字
 */
- (void)changeOnBuilding:(NSString *)buildingId floor:(NSString *)floor;

/**
 绘制规划路线，可在`MXMSearchDelegate` - onRouteSearchDone:response:方法里调用

 @param request 路线规划请求对象
 @param result 路线规划结果
 */
- (void)paintRouteUsingRequest:(MXMRouteSearchRequest *)request Result:(MXMRouteSearchResponse *)result;

@end

NS_ASSUME_NONNULL_END

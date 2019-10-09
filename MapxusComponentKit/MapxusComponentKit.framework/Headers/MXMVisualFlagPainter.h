//
//  MXMVisualFlagPainter.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2018/11/30.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>

typedef NSDictionary<NSString*, id> NodeDictionary;

NS_ASSUME_NONNULL_BEGIN


/**
 点击节点后执行的代码块.
 @param node 节点上所带的可视化数据信息
 */
typedef void(^CircleOnClickBlock)(NodeDictionary *node);


/**
 * 可视化地图标注点绘制工具
 */
@interface MXMVisualFlagPainter : NSObject


/**
 点击节点后执行的代码块
 */
@property (nonatomic, copy) CircleOnClickBlock circleOnClickBlock;


/**
 绘制工具初始化
 @param mapView 绘制的地图对象.
 @return 绘制对象.
 */
- (instancetype)initWithMapView:(MGLMapView *)mapView;


/**
 渲染数据
 @param nodes MXMNode 转换成json的队列
 */
- (void)renderFlagUsingNodes:(NSArray<NodeDictionary*> *)nodes;


/**
 清除所有可视化标注点
 */
- (void)cleanLayer;


/**
 切换显示对应建筑楼层的可视化标注点。 可以在 ` MapxusMapDelegate ` - mapView: didChangeFloor: atBuilding: 回调方法中调用.
 @param buildingId 地图当前显示的建筑
 @param floor 地图当前显示的楼层
 */
- (void)changeOnBuilding:(NSString *)buildingId floor:(NSString *)floor;



@end

NS_ASSUME_NONNULL_END

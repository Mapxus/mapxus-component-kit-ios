//
//  MXMPainterPathDto.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/26.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MXMCommonObj.h>

#import "MXMParagraph.h"


NS_ASSUME_NONNULL_BEGIN


/**
 * 规划路线的数据模型
 */
@interface MXMPainterPathDto : NSObject

/// 起点
@property (nonatomic, strong, readonly) MXMIndoorPoint *startPoint;

/// 终点
@property (nonatomic, strong, readonly) MXMIndoorPoint *endPoint;

/**
 按规划顺序排列的key，其中室外段落如果有室内段落隔开，以 outdoor1、outdoor2... 来区分标识，
 室内段落 key 以 buildingId-floor 拼接而成。
 */
@property (nonatomic, strong, readonly) NSArray *keys;

/// 各段落的详细信息
@property (nonatomic, strong, readonly) NSDictionary<NSString *, MXMParagraph *> *paragraphs;

/**
 初始化函数
 @param path 路线规划接口 -(void)MXMRouteSearch: 返回结果中其中一个方案的路线模型
 @param start 起始点室内坐标
 @param end 结束点室内坐标
 @return 整理后的数据模型
 */
- (instancetype)initWithPath:(MXMPath *)path startPoint:(MXMIndoorPoint *)start endPoint:(MXMIndoorPoint *)end;

@end

NS_ASSUME_NONNULL_END

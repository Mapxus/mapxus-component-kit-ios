//
//  MXMPainterPathDto.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/26.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXMParagraph.h"
#import <MapxusMapSDK/MXMCommonObj.h>

NS_ASSUME_NONNULL_BEGIN


@interface MXMPainterPathDto : NSObject
/// 起点
@property (nonatomic, strong, readonly) MXMIndoorPoint *startPoint;
/// 终点
@property (nonatomic, strong, readonly) MXMIndoorPoint *endPoint;
/// 按规划顺序排列的
@property (nonatomic, strong, readonly) NSArray *keys;
/// 各路段
@property (nonatomic, strong, readonly) NSDictionary<NSString *, MXMParagraph *> *paragraphs;


- (instancetype)initWithPath:(MXMPath *)path startPoint:(MXMIndoorPoint *)start endPoint:(MXMIndoorPoint *)end;

@end

NS_ASSUME_NONNULL_END

//
//  MXMNavigationPathDTO+Private.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/9.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//
#import "MXMNavigationPathDTO.h"
#import "MXMLineSegment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSArray<MXMLineSegment *> LineArray;

@interface MXMNavigationPathDTO ()

@property (nonatomic, strong, readonly) NSDictionary<NSString *, LineArray *> *fragments;

- (nullable LineArray *)fragmenntWithKey:(NSString *)key;

+ (NSString *)generateKeyUsingBuildingId:(nullable NSString *)buildingId andFloor:(nullable NSString *)floor;

@end

NS_ASSUME_NONNULL_END

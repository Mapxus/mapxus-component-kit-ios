//
//  MXMLocation.h
//  MapxusComponentKit
//
//  Created by guochenghao on 2024/5/6.
//  Copyright © 2024 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXMLocation : NSObject

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong, nullable) NSString *floorCode; // 正式发布时不需要开放给开发者使用
@property (nonatomic, strong, nullable) NSString *floorId;
@property (nonatomic, strong, nullable) NSString *buildingId;
@property (nonatomic, strong, nullable) NSString *venueId;

@end

NS_ASSUME_NONNULL_END

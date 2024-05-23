//
//  CLFloor+Factory.h
//  BeeMapDemo
//
//  Created by Chenghao Guo on 2018/12/28.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// This category extends the CLFloor class with a factory method.
@interface CLFloor (Factory)


/// This class method creates a new instance of CLFloor with a specified level.
///
/// @param level The level for the new CLFloor instance.
/// @return A new instance of CLFloor with the specified level.
+ (CLFloor *)createFloorWihtLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END

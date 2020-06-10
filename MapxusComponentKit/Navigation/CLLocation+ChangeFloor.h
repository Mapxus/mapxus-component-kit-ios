//
//  CLLocation+ChangeFloor.h
//  BeeMapDemo
//
//  Created by Chenghao Guo on 2018/12/28.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation (ChangeFloor)

@property (nonatomic, strong, nullable) CLFloor *myFloor;

@end

NS_ASSUME_NONNULL_END

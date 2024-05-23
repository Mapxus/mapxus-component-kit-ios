//
//  CLLocation+ChangeFloor.h
//  BeeMapDemo
//
//  Created by Chenghao Guo on 2018/12/28.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// This is a category of CLLocation that allows modification of the floor information.
@interface CLLocation (ChangeFloor)


/// This property holds the floor information.
///
/// @discussion
/// Because `CLLocation.floor` does not have a defined setter method, you can change the value when you get `CLLocation.floor` using this property.
/// If it is set to nil, `CLLocation.floor` will return the original value when the getter method is called.
@property (nonatomic, strong, nullable) CLFloor *myFloor;

@end

NS_ASSUME_NONNULL_END

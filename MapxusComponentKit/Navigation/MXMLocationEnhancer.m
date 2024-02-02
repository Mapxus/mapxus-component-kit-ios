//
//  MXMLocationEnhancer.m
//  MapxusComponentKit
//
//  Created by guochenghao on 2023/12/14.
//

#import <CoreLocation/CoreLocation.h>
#import "MXMLocationEnhancer.h"

extern NSInteger historyFloor;

@interface MXMLocationEnhancer () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation MXMLocationEnhancer

+ (instancetype)shared {
  static MXMLocationEnhancer *_shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _shared = [[MXMLocationEnhancer alloc] init];
  });
  return _shared;
}

- (void)start {
  [self.locationManager startUpdatingLocation];
}

- (void)stop {
  [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  // 一般情况下返回数量不会超出int的范围，所以NSUInteger强制转换成int
  // the most recent location update is at the end of the array. 所以用倒序遍历
  for (int i = (int)locations.count - 1; i >= 0; i--) {
    CLLocation *loc = locations[i];
    if (loc.floor != nil) {
      historyFloor = loc.floor.level;
    }
  }
}

- (CLLocationManager *)locationManager {
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }
  return _locationManager;
}

@end

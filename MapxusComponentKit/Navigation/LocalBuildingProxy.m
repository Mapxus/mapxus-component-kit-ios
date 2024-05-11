//
//  LocalBuildingProxy.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/8.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "LocalBuildingProxy.h"
#import "MXMHttpManager.h"
#import "MXMConstants.h"
#import "JXJsonFunctionDefine.h"
#import <Mapbox/Mapbox.h>
#import <MapxusMapSDK/MapxusMapSDK.h>
#import "MGLPolygon+MXMFuction.h"
#import "CLLocation+ChangeFloor.h"
#import "CLFloor+Factory.h"

extern NSInteger historyFloor;



/// Stores floor frames and associated building information
@interface MXMShape : NSObject

@property (nonatomic, strong) MGLShape *shape;
@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *buildingId;
@property (nonatomic, strong) NSString *floorId;
@property (nonatomic, strong) NSString *floorCode;
@property (nonatomic, strong) MXMOrdinal *floorOrdinal;

@end

@implementation MXMShape

+ (nullable MXMShape *)createShapeFrom:(NSDictionary *)dic {
  NSDictionary *polygonDic = DecodeDicFromDic(dic, @"polygon");
  if (polygonDic) {
    NSMutableDictionary *polygonMuDic = [NSMutableDictionary dictionaryWithDictionary:polygonDic];
    polygonMuDic[@"type"] = @"MultiPolygon"; // 后端接口只有一种情况，且接口返回的是全小写，要换成单词大写才符合geojson格式
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:polygonMuDic options:0 error:NULL];
    if (jsonData) {
      MXMShape *mxmShape = [[MXMShape alloc] init];
      mxmShape.shape = [MGLShape shapeWithData:jsonData encoding:NSUTF8StringEncoding error:nil];
      mxmShape.venueId = DecodeStringFromDic(dic, @"venueId");
      mxmShape.buildingId = DecodeStringFromDic(dic, @"buildingId");
      mxmShape.floorId = DecodeStringFromDic(dic, @"id");
      mxmShape.floorCode = DecodeStringFromDic(dic, @"code");
      NSNumber *ordinal = DecodeNumberFromDic(dic, @"ordinal");
      if (ordinal) {
        mxmShape.floorOrdinal = [[MXMOrdinal alloc] init];
        mxmShape.floorOrdinal.level = [ordinal integerValue];
      }
      return mxmShape;
    }
  }
  return nil;
}

@end




@interface LocalBuildingProxy () {
  dispatch_queue_t _queue;
}
@property (nonatomic, strong) NSMutableArray<MXMShape *> *shapeList;
@property (nonatomic, assign) CLLocationCoordinate2D center;
@property (nonatomic, assign) double maxDistance;
@property (nonatomic, assign) BOOL isNetworking;

@end

@implementation LocalBuildingProxy

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.isNetworking = NO;
    // 设置初始值
    self.center = kCLLocationCoordinate2DInvalid;
    // 第一次获取以50m为半径，减少数据量，以减少请求回复时间
    self.maxDistance = 50;
    _queue = dispatch_queue_create("com.mapxus.locationQueue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)queryLocalBuildingByLocation:(CLLocation *)location completion:(void(^)(MXMLocation *result))completion {
  // 延续`- [MXMGeoCodeSearch reverseGeoCode:]`的逻辑，当定位没有floor时，使用历史定位的floor
  if (location.floor == nil) {
    CLFloor *floor = [CLFloor createFloorWihtLevel:historyFloor];
    location.myFloor = floor;
  }
  
  /// 设计思路：
  /// 人的平均步行速度为1.25m/s。在移动到距离圆的边5米的时候进行网络请求，以获取新的周边楼层数据。
  /// 网络请求在应在4s内完成请求，如果未能返回，用户有可能会走到未知区域内。
  /// 在上一次网络请求未完成前，不应再请求第二次。
  /// 如果发生4s内未完成请求的情况，也会出现两种情形：
  /// 1. 用户走到上次请求区域外，但上一次请求的数据还有效（譬如请求区域内的楼层向外伸展），则能返回有效的室内数据，可以返回结果。
  /// 2. 用户走到上次请求区域外，上一次请求的数据未能找到有效的室内数据，则不返回结果。
  dispatch_async(_queue, ^{
    
    // 第一次或者距边沿5m内，应再次请求楼层数据
    BOOL shouldNetworkRequest = NO;
    if (CLLocationCoordinate2DIsValid(self.center)) {
      double distance = [self distanceBetweenPoint1:self.center point2:location.coordinate];
      shouldNetworkRequest = (distance + 5 > self.maxDistance);
    } else {
      shouldNetworkRequest = YES;
    }
    
    // 如果有请求正在进行，也不应该再次调起请求
    if (shouldNetworkRequest && !self.isNetworking) {
      
      self.isNetworking = YES;
      [self searchWithLocation:location completion:^(NSDictionary *content) {
        dispatch_async(self->_queue, ^{
          if (content) {
            [self.shapeList removeAllObjects];
            NSArray *floors = DecodeArrayFromDic(content, @"floors");
            for (NSDictionary *dic in floors) {
              MXMShape *mxmShape = [MXMShape createShapeFrom:dic];
              if (mxmShape) {
                [self.shapeList addObject:mxmShape];
              }
            }
            // 能成功更新数据才更新中心点，以便及时更新floor队列
            self.maxDistance = 100;
            self.center = location.coordinate;
          }
          
          self.isNetworking = NO;
          
          MXMLocation *indoorLocation = [self findIndoorInfomationWithLocation:location];
          completion(indoorLocation);
        });
      }];
      
    } else {
      MXMLocation *indoorLocation = [self findIndoorInfomationWithLocation:location];
      if (indoorLocation.floorId) {
        completion(indoorLocation);
      } else {
        if (!self.isNetworking) {
          completion(indoorLocation);
        }
      }
      
    }
    
  });
}




- (void)searchWithLocation:(CLLocation *)location completion:(void(^)(NSDictionary *content))completion {
  NSString *url = [NSString stringWithFormat:@"%@%@", MXMAPIHOSTURL, @"/bms/api/v4/floors"];
  NSDictionary *dic = @{
    @"center": [NSString stringWithFormat:@"%f,%f", location.coordinate.longitude, location.coordinate.latitude],
    @"distance": @(self.maxDistance)
  };
  [MXMHttpManager MXMGET:url parameters:dic success:^(NSDictionary *content) {
    completion(content);
  } failure:^(NSError *error) {
    completion(nil);
  }];
  
}

- (MXMLocation *)findIndoorInfomationWithLocation:(CLLocation *)location {
  MXMLocation *indoorLocation = [[MXMLocation alloc] init];
  indoorLocation.location = location;
  for (MXMShape *shape in self.shapeList) {
    if ([shape.shape isKindOfClass:[MGLPolygon class]]) {
      MGLPolygon *polygon = (MGLPolygon *)shape.shape;
      if ([polygon mxmContains:location.coordinate] && shape.floorOrdinal.level == location.floor.level) {
        indoorLocation.venueId = shape.venueId;
        indoorLocation.buildingId = shape.buildingId;
        indoorLocation.floorId = shape.floorId;
        indoorLocation.floorCode = shape.floorCode;
        break;
      }
    }
    else if ([shape.shape isKindOfClass:[MGLMultiPolygon class]]) {
      MGLMultiPolygon *multiPolygon = (MGLMultiPolygon *)shape.shape;
      BOOL inMultiPolygon = NO;
      for (MGLPolygon *polygon in multiPolygon.polygons) {
        if ([polygon mxmContains:location.coordinate]) {
          inMultiPolygon = YES;
          break;
        }
      }
      if (inMultiPolygon && shape.floorOrdinal.level == location.floor.level) {
        indoorLocation.venueId = shape.venueId;
        indoorLocation.buildingId = shape.buildingId;
        indoorLocation.floorId = shape.floorId;
        indoorLocation.floorCode = shape.floorCode;
        break;
      }
    }
  }
  return indoorLocation;
}

- (double)distanceBetweenPoint1:(CLLocationCoordinate2D)point1 point2:(CLLocationCoordinate2D)point2 {
  double dx = point1.longitude - point2.longitude; // 经度差值
  double dy = point1.latitude - point2.latitude; // 纬度差值
  double b = (point1.latitude + point2.latitude) / 2.0; // 平均纬度
  double Lx = [self degreesToRadians:dx] * 6367000.0 * cos([self degreesToRadians:b]); // 东西距离
  double Ly = 6367000.0 * [self degreesToRadians:dy]; // 南北距离
  return sqrt(Lx * Lx + Ly * Ly);  // 用平面的矩形对角距离公式计算总距离
}

- (double)degreesToRadians:(double)degrees {
  return degrees * M_PI / 180;
}



- (NSMutableArray<MXMShape *> *)shapeList {
  if (!_shapeList) {
    _shapeList = [NSMutableArray array];
  }
  return _shapeList;
}

@end

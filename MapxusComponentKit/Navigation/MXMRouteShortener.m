//
//  MXMRouteShortener.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/5.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMRouteShortener.h"
#import "MXMRouteProjection.h"
#import "GeoFunctions.h"

@interface MXMRouteShortener ()

@property (nonatomic, strong) MXMNavigationPathDTO *routePathDTO;

@end


@implementation MXMRouteShortener

- (void)inputSourceWithOriginalPath:(MXMPath *)path originalWayPoints:(NSArray<MXMIndoorPoint *> *)wayPoints andNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO {
  _routePathDTO = navigationPathDTO;
  _originalPath = path;
  _originalWayPoints = wayPoints;
}

- (void)cutFromTheLocationProjection:(CLLocation *)projection floorId:(NSString *)floorId {
  if (floorId == nil) {
    floorId = @"outdoor";
  }
  NSString *key = self.routePathDTO.floorIdMap[floorId];
  CLLocationCoordinate2D projectionCoordinate = projection.coordinate;
  [self cutWithKey:key projectionCoordinate:projectionCoordinate];
}

- (void)cutFromTheLocationProjection:(CLLocation *)projection 
                          buildingID:(nullable NSString *)buildingID
                            andFloor:(nullable NSString *)floor {
  NSString *key = [MXMNavigationPathDTO generateKeyUsingBuildingId:buildingID andFloor:floor];
  CLLocationCoordinate2D projectionCoordinate = projection.coordinate;
  [self cutWithKey:key projectionCoordinate:projectionCoordinate];
}

- (void)cutWithKey:(NSString *)key projectionCoordinate:(CLLocationCoordinate2D)projectionCoordinate {
  NSArray *points = self.originalPath.points.coordinates;
  NSArray *fragmentList = [self.routePathDTO fragmenntWithKey:key];
  // 找不到路线数据
  if (fragmentList == nil) {
    return;
  }
  MXMLineSegment *nearestLineSegment = [MXMRouteProjection findNearestLineSegmentOnList:fragmentList usingCoordinate:projectionCoordinate];
  
  NSUInteger index = nearestLineSegment.instructionIndex;
  NSArray *instructions = self.originalPath.instructions;
  MXMInstruction *currentInstruction = instructions[index];
  
  // 线段两端点是同一个点
  BOOL samePointLineSegment = [GeoFunctions isPoint0:nearestLineSegment.p0 equalToPoint1:nearestLineSegment.p1];
  
  int i = 0;
  for (MXMGeoPoint *point in points) {
    CLLocationCoordinate2D firstPointCoordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
    if ([GeoFunctions isPoint0:firstPointCoordinate equalToPoint1:nearestLineSegment.p0]) {
      if (samePointLineSegment) {
        if ([GeoFunctions isPoint0:firstPointCoordinate equalToPoint1:nearestLineSegment.p1]) {
          break;
        }
      } else {
        MXMGeoPoint *nextPoint = points[i+1];
        CLLocationCoordinate2D nextPointCoordinate = CLLocationCoordinate2DMake(nextPoint.latitude, nextPoint.longitude);
        if ([GeoFunctions isPoint0:nextPointCoordinate equalToPoint1:nearestLineSegment.p1]) {
          break;
        }
      }
    }
    i++;
  }
  
  // 线段两端点是同一个点，做另类操作
  if (samePointLineSegment) {
    if (i > points.count-1) {
      return;
    }
    
    NSRange residueRange = NSMakeRange(i, points.count-i);
    NSArray *residueCoordinates = [points subarrayWithRange:residueRange];
    
    MXMGeometry *newGeometry = [[MXMGeometry alloc] init];
    newGeometry.coordinates = residueCoordinates;
    newGeometry.type = self.originalPath.points.type;
    
    NSMutableArray *newInstructions = [NSMutableArray array];
    
    for (NSUInteger j=index; j<instructions.count; j++) {
      MXMInstruction *indexInstruction = instructions[j];
      NSUInteger first = indexInstruction.interval.firstObject.unsignedIntegerValue;
      NSUInteger last = indexInstruction.interval.lastObject.unsignedIntegerValue;
      
      MXMInstruction *tmpInstruction = [[MXMInstruction alloc] init];
      tmpInstruction.buildingId = indexInstruction.buildingId;
      tmpInstruction.floor = indexInstruction.floor;
      tmpInstruction.floorId = indexInstruction.floorId;
      tmpInstruction.venueId = indexInstruction.venueId;
      tmpInstruction.ordinal = indexInstruction.ordinal;
      tmpInstruction.streetName = indexInstruction.streetName;
      tmpInstruction.distance = indexInstruction.distance;
      tmpInstruction.heading = indexInstruction.heading;
      tmpInstruction.sign = indexInstruction.sign;
      tmpInstruction.text = indexInstruction.text;
      tmpInstruction.time = indexInstruction.time;
      tmpInstruction.type = indexInstruction.type;
      tmpInstruction.interval = @[@(first-i), @(last-i)];
      [newInstructions addObject:tmpInstruction];
    }
    
    MXMPath *newPath = [[MXMPath alloc] init];
    newPath.bbox = self.originalPath.bbox;
    newPath.instructions = [newInstructions copy];
    newPath.points = newGeometry;
    
    NSUInteger tim = 0;
    double dis = 0.0;
    for (MXMInstruction *ins in newInstructions) {
      tim += ins.time;
      dis += ins.distance;
    }
    newPath.distance = dis;
    newPath.time = tim;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(routeShortener:redrawingNewPath:fromInstructionIndex:)]) {
      [self.delegate routeShortener:self redrawingNewPath:newPath fromInstructionIndex:index];
    }
    return;
  }
  
  
  
  // 两点匹配，i最多到points.count-2
  if (i > points.count-2) {
    return;
  }
  
  // 线段两端点不是同一个点，做常规操作
  NSRange residueRange = NSMakeRange(i+1, points.count-1-i);
  NSArray *residueCoordinates = [points subarrayWithRange:residueRange];
  MXMGeoPoint *startPoint = [MXMGeoPoint locationWithLatitude:projectionCoordinate.latitude longitude:projectionCoordinate.longitude];
  NSMutableArray *newCoordinates = [NSMutableArray arrayWithArray:residueCoordinates];
  [newCoordinates insertObject:startPoint atIndex:0];
  
  MXMGeometry *newGeometry = [[MXMGeometry alloc] init];
  newGeometry.coordinates = [newCoordinates copy];
  newGeometry.type = self.originalPath.points.type;
  
  NSMutableArray *newInstructions = [NSMutableArray array];
  
  // 如果是到达了梯子上，直接丢弃，不再绘制
  //    if (currentInstruction.sign != MXMDownstairs && currentInstruction.sign != MXMUpstairs) {
  MXMInstruction *newCurrentInstruction = [[MXMInstruction alloc] init];
  newCurrentInstruction.buildingId = currentInstruction.buildingId;
  newCurrentInstruction.floor = currentInstruction.floor;
  newCurrentInstruction.floorId = currentInstruction.floorId;
  newCurrentInstruction.venueId = currentInstruction.venueId;
  newCurrentInstruction.ordinal = currentInstruction.ordinal;
  newCurrentInstruction.streetName = currentInstruction.streetName;
  newCurrentInstruction.heading = currentInstruction.heading;
  newCurrentInstruction.sign = currentInstruction.sign;
  newCurrentInstruction.text = currentInstruction.text;
  newCurrentInstruction.type = currentInstruction.type;
  NSUInteger end = currentInstruction.interval.lastObject.unsignedIntegerValue;
  newCurrentInstruction.interval = @[@(0), @(end-i)];
  // 重新计算距离与时间
  double oldDistance = currentInstruction.distance;
  double newDistance = 0.0;
  for (int j = 0; j<=end-i-1; j++) {
    MXMGeoPoint *fpp = newCoordinates[j];
    CLLocationCoordinate2D ff = CLLocationCoordinate2DMake(fpp.latitude, fpp.longitude);
    MXMGeoPoint *lpp = newCoordinates[j+1];
    CLLocationCoordinate2D ll = CLLocationCoordinate2DMake(lpp.latitude, lpp.longitude);
    newDistance += [GeoFunctions geoDistanceBetweenPoint0:ff andPoint1:ll];
  }
  newCurrentInstruction.distance = newDistance;
  if (currentInstruction.time != 0) {
    newCurrentInstruction.time = (NSUInteger)(newDistance / ( oldDistance / currentInstruction.time));
  } else {
    newCurrentInstruction.time = currentInstruction.time;
  }
  
  [newInstructions addObject:newCurrentInstruction];
  //    }
  
  // 去到最后一个instruction，就只保留最后一个，之后的不需要再遍历，因为没有之后的instruction了
  if (index != instructions.count-1) {
    for (NSUInteger j=index+1; j<instructions.count; j++) {
      MXMInstruction *indexInstruction = instructions[j];
      NSUInteger first = indexInstruction.interval.firstObject.unsignedIntegerValue;
      NSUInteger last = indexInstruction.interval.lastObject.unsignedIntegerValue;
      
      MXMInstruction *tmpInstruction = [[MXMInstruction alloc] init];
      tmpInstruction.buildingId = indexInstruction.buildingId;
      tmpInstruction.floor = indexInstruction.floor;
      tmpInstruction.floorId = indexInstruction.floorId;
      tmpInstruction.venueId = indexInstruction.venueId;
      tmpInstruction.ordinal = indexInstruction.ordinal;
      tmpInstruction.streetName = indexInstruction.streetName;
      tmpInstruction.distance = indexInstruction.distance;
      tmpInstruction.heading = indexInstruction.heading;
      tmpInstruction.sign = indexInstruction.sign;
      tmpInstruction.text = indexInstruction.text;
      tmpInstruction.time = indexInstruction.time;
      tmpInstruction.type = indexInstruction.type;
      tmpInstruction.interval = @[@(first-i), @(last-i)];
      [newInstructions addObject:tmpInstruction];
    }
  }
  
  MXMPath *newPath = [[MXMPath alloc] init];
  newPath.bbox = self.originalPath.bbox;
  newPath.instructions = [newInstructions copy];
  newPath.points = newGeometry;
  
  NSUInteger tim = 0;
  double dis = 0.0;
  for (MXMInstruction *ins in newInstructions) {
    tim += ins.time;
    dis += ins.distance;
  }
  newPath.distance = dis;
  newPath.time = tim;
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(routeShortener:redrawingNewPath:fromInstructionIndex:)]) {
    [self.delegate routeShortener:self redrawingNewPath:newPath fromInstructionIndex:index];
  }
}

@end

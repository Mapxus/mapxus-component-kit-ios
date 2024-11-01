//
//  MXMNavigationPathDTO.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/8.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMNavigationPathDTO+Private.h"

// TODO: 换成floorId
@implementation MXMNavigationPathDTO

- (instancetype)initWithPath:(MXMPath *)path {
  self = [super init];
  if (self) {
    NSMutableDictionary *floorIdMap = [NSMutableDictionary dictionary];
    floorIdMap[@"outdoor"] = @"outdoor";
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *instructions = path.instructions;
    NSArray *points = path.points.coordinates;
    int i = 0;
    for (MXMInstruction *instruction in instructions) {
      // 小节的楼层标签
      NSString *key = [MXMNavigationPathDTO generateKeyUsingBuildingId:instruction.buildingId andFloor:instruction.floor];
      if (instruction.floorId) {
        floorIdMap[instruction.floorId] = key;
      }
      
      // 加上前后两段的原因是因为楼梯线段只属于某一层楼，在上电梯时容易因为定位精度问题吸附不了，所以在两层楼的端点都加上电梯段来预防
      /// 前一段
      LineArray *list1;
      if (i-1 >= 0 && i-1 < instructions.count) {
        MXMInstruction *preInstruction = instructions[i-1];
        /// 是梯子转换段
        if (preInstruction.sign == MXMDownstairs ||
            preInstruction.sign == MXMUpstairs ||
            preInstruction.sign == MXMLeaveBuilding ||
            preInstruction.sign == MXMEnterBuilding ||
            preInstruction.sign == MXMPassGateline ||
            preInstruction.sign == MXMThroughConnectingCorridor ||
            preInstruction.sign == MXMPassArea) {
          list1 = [self breakUpLineSegmentWithInstruction:preInstruction index:i-1 points:points];
        }
      }
      /// 当前遍历段
      LineArray *list2 = [self breakUpLineSegmentWithInstruction:instruction index:i points:points];
      /// 后一段
      LineArray *list3;
      if (i+1 >= 0 && i+1 < instructions.count) {
        MXMInstruction *nextInstruction = instructions[i+1];
        if (nextInstruction.sign == MXMDownstairs || 
            nextInstruction.sign == MXMUpstairs ||
            nextInstruction.sign == MXMLeaveBuilding ||
            nextInstruction.sign == MXMEnterBuilding ||
            nextInstruction.sign == MXMPassGateline ||
            nextInstruction.sign == MXMThroughConnectingCorridor ||
            nextInstruction.sign == MXMPassArea) {
          list3 = [self breakUpLineSegmentWithInstruction:nextInstruction index:i+1 points:points];
        }
      }
      NSMutableArray *oldList = dictionary[key];
      NSMutableArray *newList = [NSMutableArray array];
      if (oldList) {
        [newList addObjectsFromArray:oldList];
        [newList addObjectsFromArray:list1];
        [newList addObjectsFromArray:list2];
        [newList addObjectsFromArray:list3];
      } else {
        [newList addObjectsFromArray:list1];
        [newList addObjectsFromArray:list2];
        [newList addObjectsFromArray:list3];
      }
      dictionary[key] = [newList copy];
      
      i++;
    }
    _fragments = [dictionary copy];
    _floorIdMap = [floorIdMap copy];
  }
  return self;
}

- (LineArray *)breakUpLineSegmentWithInstruction:(MXMInstruction *)instruction index:(NSUInteger)index points:(NSArray<MXMGeoPoint *> *)points {
  NSMutableArray *list = [NSMutableArray array];
  NSUInteger fIndex = [instruction.interval.firstObject unsignedIntegerValue];
  NSUInteger lIndex = [instruction.interval.lastObject unsignedIntegerValue];
  // warning 应该规避数组越限，但通过接口上报情况
  if (points.count == 0) {
    return [list copy];
  }
  
  NSRange range;
  if (lIndex >= points.count && fIndex >= points.count) {
    range = NSMakeRange(points.count-1, 1);
  } else if (lIndex >= points.count && fIndex < points.count) {
    range = NSMakeRange(fIndex, points.count-fIndex);
  } else {
    range = NSMakeRange(fIndex, lIndex-fIndex+1);
  }
  NSArray *subArr = [points subarrayWithRange:range];
  // 当只有一个点时，两点都取同一个，以保证能吸附
  if (subArr.count == 1) {
    MXMGeoPoint *point = subArr.firstObject;
    CLLocationCoordinate2D p0 = CLLocationCoordinate2DMake(point.latitude, point.longitude);
    CLLocationCoordinate2D p1 = CLLocationCoordinate2DMake(point.latitude, point.longitude);
    MXMLineSegment *line = [[MXMLineSegment alloc] initWithEndPoint0:p0 andEndPoint1:p1 onInstructionIndex:index];
    [list addObject:line];
    return [list copy];
  }
  // 当多于一个点时，取前后两点组成线段
  int i = 0;
  for (MXMGeoPoint *point in subArr) {
    if (i+1 < subArr.count) {
      CLLocationCoordinate2D p0 = CLLocationCoordinate2DMake(point.latitude, point.longitude);
      MXMGeoPoint *nextPoint = subArr[i+1];
      CLLocationCoordinate2D p1 = CLLocationCoordinate2DMake(nextPoint.latitude, nextPoint.longitude);
      MXMLineSegment *line = [[MXMLineSegment alloc] initWithEndPoint0:p0 andEndPoint1:p1 onInstructionIndex:index];
      [list addObject:line];
    }
    i++;
  }
  return [list copy];
}

- (nullable LineArray *)fragmenntWithKey:(NSString *)key {
  return self.fragments[key];
}

+ (NSString *)generateKeyUsingBuildingId:(nullable NSString *)buildingId andFloor:(nullable NSString *)floor {
  NSString *key;
  if (buildingId != nil && floor != nil && buildingId.length != 0 && floor.length != 0) {
    key = [NSString stringWithFormat:@"%@-%@", buildingId, floor];
  } else {
    key = @"outdoor";
  }
  return key;
}
@end

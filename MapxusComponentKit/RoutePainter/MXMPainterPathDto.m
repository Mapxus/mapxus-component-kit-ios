//
//  MXMPainterPathDto.m
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/26.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMPainterPathDto+Private.h"
#import "NSString+Compare.h"

@implementation MXMPainterPathDto

- (instancetype)initWithPath:(MXMPath *)path startPoint:(MXMIndoorPoint *)start endPoint:(MXMIndoorPoint *)end
{
  self = [super init];
  if (self) {
    _startPoint = start;
    _endPoint = end;
    [self dualWithPath:path];
  }
  return self;
}

- (void)dualWithPath:(MXMPath *)path
{
  [self.mutableKeys removeAllObjects];
  [self.mutableParagraphs removeAllObjects];
  
  NSArray *pointList = path.points.coordinates;
  
  MXMParagraph *paph;
  
  for (MXMInstruction *ins in path.instructions) {
    NSString *floor = nil;
    if (ins.floor) {
      floor = ins.floor;
    }
    if (ins.floorId) {
      floor = ins.floorId;
    }
    // 上一 instruction 的 key
    NSString *lastKey = self.mutableKeys.lastObject?:@"";
    // 当前 instruction 的预设 key
    NSString *currentKey;
    if ([NSString isEmpty:ins.buildingId] ||
        [NSString isEmpty:floor] ||
        [NSString isEmpty:ins.venueId] ||
        ins.ordinal == nil) {
      currentKey = @"outdoor";
    } else {
      if (ins.floorId) {
        currentKey = ins.floorId;
      } else {
        currentKey = [NSString stringWithFormat:@"%@-%@", ins.buildingId, ins.floor];
      }
    }
    
    // 把ShuttleBus路线单独拆成一个Paragraph
    if (ins.sign == MXMShuttleBus ||
        ins.sign == MXMShuttleBusStation ||
        ins.sign == MXMShuttleBusWaiting ||
        ins.sign == MXMShuttleBusEndTrip) {
      currentKey = [NSString stringWithFormat:@"ShuttleBus-%@", currentKey];//[currentKey stringByAppendingString:@"-ShuttleBus"];
    }
    
    if ([lastKey hasPrefix:currentKey]) { // 当前 instruction 与上一 instruction 的 key 一致，currentKey 沿用上一 instruction 的 key
      currentKey = lastKey;
    } else { // 当前 instruction 与上一 instruction 的 key 不一致，创建新 key
      int i = 0;
      for (NSString *key in self.mutableKeys) {
        if ([key hasPrefix:currentKey]) {
          i++;
        }
      }
      if (i != 0) {
        currentKey = [currentKey stringByAppendingFormat:@"-%d", i];
      }
    }
    // 配置venue-ordinal映射
    if ([currentKey containsString:@"outdoor"]) {
      self.keyMapping[currentKey] = @"outdoor";
    } else {
      NSString *venueKey = [NSString stringWithFormat:@"%@-%ld", ins.venueId, ins.ordinal.level];
      self.keyMapping[currentKey] = venueKey;
    }

    // 建筑或楼层有变化
    if (![lastKey isEqualToString:currentKey]) {
      MXMParagraph *lastPaph = [self.mutableParagraphs objectForKey:lastKey];
      
      paph = [[MXMParagraph alloc] init];
      paph.venueId = ins.venueId;
      paph.buildingId = ins.buildingId;
      paph.floorId = ins.floorId;
      paph.ordinal = ins.ordinal;
      paph.floor = ins.floor;
      paph.key = currentKey;
      paph.startPointType = lastPaph?lastPaph.endPointType:StartEndPoint;
      
      if (ins.sign == MXMLeaveBuilding || ins.sign == MXMEnterBuilding) {
        paph.startPointType = BuildingGate;
        lastPaph.endPointType = BuildingGate;
      }
      
      [self.mutableParagraphs setObject:paph forKey:paph.key];
      [self.mutableKeys addObject:currentKey];
    }
    
    // 设置不同的颜色值
    if (ins.sign == MXMShuttleBus ||
        ins.sign == MXMShuttleBusStation ||
        ins.sign == MXMShuttleBusWaiting ||
        ins.sign == MXMShuttleBusEndTrip) {
      paph.lineColorType = 2;
    } else if ([currentKey containsString:@"outdoor"]) {
      paph.lineColorType = 0;
    } else {
      paph.lineColorType = 1;
    }

    
    if (ins.sign == MXMDownstairs || ins.sign == MXMUpstairs) {
      
      if ([ins.type containsString:@"elevator"] && ins.sign == MXMUpstairs) {
        paph.endPointType = ElevatorUp;
      } else if ([ins.type containsString:@"elevator"] && ins.sign == MXMDownstairs) {
        paph.endPointType = ElevatorDown;
      } else if ([ins.type isEqualToString:@"escalator"] && ins.sign == MXMUpstairs) {
        paph.endPointType = EscalatorUp;
      } else if ([ins.type isEqualToString:@"escalator"] && ins.sign == MXMDownstairs) {
        paph.endPointType = EscalatorDown;
      } else if ([ins.type isEqualToString:@"ramp"] && ins.sign == MXMUpstairs) {
        paph.endPointType = RampUp;
      } else if ([ins.type isEqualToString:@"ramp"] && ins.sign == MXMDownstairs) {
        paph.endPointType = RampDown;
      } else if ([ins.type isEqualToString:@"stairs"] && ins.sign == MXMUpstairs) {
        paph.endPointType = StairsUp;
      } else if ([ins.type isEqualToString:@"stairs"] && ins.sign == MXMDownstairs) {
        paph.endPointType = StairsDown;
      }
      // 去除楼梯上的线
      if (!paph.points.count) {
        NSUInteger fIndex = [ins.interval.firstObject unsignedIntegerValue];
        if (pointList.count) {
          MXMGeoPoint *fp = pointList[fIndex];
          [paph.points addObject:fp];
        }
      }
    } else {
      if (ins.sign == MXMLeaveBuilding || ins.sign == MXMEnterBuilding) {
        paph.endPointType = BuildingGate;
      } else if (ins.sign == MXMFinish) {
        paph.endPointType = StartEndPoint;
      }
      // 整合线段
      NSUInteger fIndex = [ins.interval.firstObject unsignedIntegerValue];
      NSUInteger lIndex = [ins.interval.lastObject unsignedIntegerValue];
      // warning 应该规避数组越限，但通过接口上报情况
      NSRange range;
      if (lIndex >= pointList.count && fIndex >= pointList.count) {
        range = NSMakeRange(pointList.count-1, 1);
      } else if (lIndex >= pointList.count && fIndex < pointList.count) {
        range = NSMakeRange(fIndex, pointList.count-fIndex);
      } else {
        range = NSMakeRange(fIndex, lIndex-fIndex+1);
      }
      if (pointList.count) {
        NSArray *subArr = [pointList subarrayWithRange:range];
        [paph.points addObjectsFromArray:subArr];
      }
    }
  }
  
  _keys = [self.mutableKeys copy];
  _paragraphs = [self.mutableParagraphs copy];
  
  [self.mutableKeys removeAllObjects];
  [self.mutableParagraphs removeAllObjects];
}

#pragma mark - access method

- (NSMutableArray *)mutableKeys
{
  if (!_mutableKeys) {
    _mutableKeys = [NSMutableArray array];
  }
  return _mutableKeys;
}

- (NSMutableDictionary *)mutableParagraphs
{
  if (!_mutableParagraphs) {
    _mutableParagraphs = [NSMutableDictionary dictionary];
  }
  return _mutableParagraphs;
}

- (NSMutableDictionary *)keyMapping
{
  if (!_keyMapping) {
    _keyMapping = [NSMutableDictionary dictionary];
  }
  return _keyMapping;
}


@end

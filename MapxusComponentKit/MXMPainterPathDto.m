//
//  MXMPainterPathDto.m
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/26.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMPainterPathDto.h"
#import "NSString+Compare.h"

@interface MXMPainterPathDto ()

@property (nonatomic, strong) NSMutableArray *mutableKeys;
@property (nonatomic, strong) NSMutableDictionary *mutableParagraphs;

@end

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
        // 上一 instruction 的 key
        NSString *lastKey = self.mutableKeys.lastObject?:@"";
        // 当前 instruction 的预设 key
        NSString *currentKey;
        if ([NSString isEmpty:ins.buildingId] || [NSString isEmpty:ins.floor]) {
            currentKey = @"outdoor";
        } else {
            currentKey = [NSString stringWithFormat:@"%@-%@", ins.buildingId, ins.floor];
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
                currentKey = [currentKey stringByAppendingFormat:@" %d", i];
            }
        }
        
        // 建筑或楼层有变化
        if (![lastKey isEqualToString:currentKey]) {
            MXMParagraph *lastPaph = [self.mutableParagraphs objectForKey:lastKey];

            paph = [[MXMParagraph alloc] init];
            paph.buildingId = ins.buildingId;
            paph.floor = ins.floor;
            paph.key = currentKey;
            paph.startPointType = lastPaph?lastPaph.endPointType:StartEndPoint;

            if (ins.sign == MXMContinueOnStreet && [ins.type isEqualToString:@"gate_building"]) {
                paph.startPointType = BuildingGate;
                lastPaph.endPointType = BuildingGate;
            }
            
            [self.mutableParagraphs setObject:paph forKey:paph.key];
            [self.mutableKeys addObject:currentKey];
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
            if (!paph.points.count) {
                NSUInteger fIndex = [ins.interval.firstObject unsignedIntegerValue];
                MXMGeoPoint *fp = pointList[fIndex];
                [paph.points addObject:fp];
            }
        } else {
            // 整合线段
            NSUInteger fIndex = [ins.interval.firstObject unsignedIntegerValue];
            NSUInteger lIndex = [ins.interval.lastObject unsignedIntegerValue];
#warning 应该规避数组越限，但通过接口上报情况
            NSRange range;
            if (lIndex >= pointList.count && fIndex >= pointList.count) {
                range = NSMakeRange(pointList.count-1, 1);
            } else if (lIndex >= pointList.count && fIndex < pointList.count) {
                range = NSMakeRange(fIndex, pointList.count-fIndex);
            } else {
                range = NSMakeRange(fIndex, lIndex-fIndex+1);
            }
            NSArray *subArr = [pointList subarrayWithRange:range];
            [paph.points addObjectsFromArray:subArr];
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

@end

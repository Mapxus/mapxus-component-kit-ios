//
//  MXMRoutePainter.m
//  MXMComponentKit
//
//  Created by Chenghao Guo on 2018/10/17.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMRoutePainter.h"

@interface MXMRoutePainter ()

@property (nonatomic, weak) MGLMapView *mapView;
@property (nonatomic, weak) MapxusMap *map;
@property (nonatomic, strong) NSMutableDictionary *lineBound;

@end

@implementation MXMRoutePainter

- (instancetype)initWithMapView:(MGLMapView *)mapView map:(MapxusMap *)map
{
    self = [super init];
    if (self) {
        self.routeScaleFit = YES;
        self.mapView = mapView;
        self.map = map;
    }
    return self;
}

- (void)paintRouteUsingRequest:(MXMRouteSearchRequest *)request Result:(MXMRouteSearchResponse *)result
{
    // 1.clears data before drawing
    [self cleanRoute];
    [self.lineBound removeAllObjects];
    // 2.Take the first path in the path group
    MXMPath *path = result.paths.firstObject;
    NSArray *pointList = path.points.coordinates;
    
    NSMutableArray *addLineFeatures = [NSMutableArray array];
    // 3.Supplementary starting line
    {
        MXMGeoPoint *fristPoint = pointList.firstObject;
        CLLocationCoordinate2D routeCoordinates[2];
        routeCoordinates[0] = CLLocationCoordinate2DMake(request.fromLat, request.fromLon);
        routeCoordinates[1] = CLLocationCoordinate2DMake(fristPoint.latitude, fristPoint.longitude);
        
        NSString *key;
        if (![self isEmptyString:request.fromBuilding]) {
            // 获取bounds队列
            key = [NSString stringWithFormat:@"%@-%@", request.fromBuilding, request.fromFloor];
        } else {
            // 获取bounds队列
            key = @"outdoor";
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"key"] = key;
        MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:2];
        feature.attributes = dic;
        
        NSMutableArray *boundsArr;
        boundsArr = [self.lineBound objectForKey:key]?:[NSMutableArray array];
        [boundsArr addObject:feature];
        [self.lineBound setObject:boundsArr forKey:key];
        [addLineFeatures addObject:feature];
    }
    
    // 4.Supplementary finish line
    {
        MXMGeoPoint *lastPoint = pointList.lastObject;
        CLLocationCoordinate2D routeCoordinates[2];
        routeCoordinates[0] = CLLocationCoordinate2DMake(lastPoint.latitude, lastPoint.longitude);
        routeCoordinates[1] = CLLocationCoordinate2DMake(request.toLat, request.toLon);
        
        NSString *key;
        if (![self isEmptyString:request.toBuilding]) {
            // 获取bounds队列
            key = [NSString stringWithFormat:@"%@-%@", request.toBuilding, request.toFloor];
        } else {
            // 获取bounds队列
            key = @"outdoor";
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"key"] = key;
        MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:2];
        feature.attributes = dic;
        
        NSMutableArray *boundsArr;
        boundsArr = [self.lineBound objectForKey:key]?:[NSMutableArray array];
        [boundsArr addObject:feature];
        [self.lineBound setObject:boundsArr forKey:key];
        [addLineFeatures addObject:feature];
    }

    MGLShapeSource *addLineSource = [[MGLShapeSource alloc] initWithIdentifier:@"addLineSource" features:addLineFeatures options:nil];
    [self.mapView.style addSource:addLineSource];
    // 添加线渲染层
    MGLLineStyleLayer *addLineLayer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-addLine-layer" source:addLineSource];
    addLineLayer.lineWidth = [NSExpression expressionForConstantValue:@5];
    addLineLayer.lineColor = [NSExpression expressionForConstantValue:[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1]];
    addLineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    addLineLayer.lineDashPattern = [NSExpression expressionForConstantValue:@[@(1), @(2)]];
    [self.mapView.style addLayer:addLineLayer];
    
    //
    NSMutableArray *lineFeatures = [NSMutableArray array];
    NSMutableArray *connectorFeatures = [NSMutableArray array];
    NSString *fristKey = nil;
    NSString *fristBuildingId = nil;
    NSString *fristFloor = nil;

    // 添加起始点透明图标
    NSMutableDictionary *startAttributes = [NSMutableDictionary dictionary];
    if (request.fromBuilding) {
        startAttributes[@"key"] = [NSString stringWithFormat:@"%@-%@", request.fromBuilding, request.fromFloor];
        startAttributes[@"building"] = request.fromBuilding;
    } else {
        startAttributes[@"key"] = @"outdoor";
    }
    startAttributes[@"iconName"] = @"poi-01";
    MGLPointFeature *startFeature = [[MGLPointFeature alloc] init];
    startFeature.coordinate = CLLocationCoordinate2DMake(request.fromLat, request.fromLon);
    startFeature.attributes = startAttributes;
    [connectorFeatures addObject:startFeature];
    // 添加终点透明图标
    NSMutableDictionary *endAttributes = [NSMutableDictionary dictionary];
    if (request.toBuilding) {
        endAttributes[@"key"] = [NSString stringWithFormat:@"%@-%@", request.toBuilding, request.toFloor];
        endAttributes[@"building"] = request.toBuilding;
    } else {
        endAttributes[@"key"] = @"outdoor";
    }
    endAttributes[@"iconName"] = @"poi-01";
    MGLPointFeature *toFeature = [[MGLPointFeature alloc] init];
    toFeature.coordinate = CLLocationCoordinate2DMake(request.toLat, request.toLon);
    toFeature.attributes = endAttributes;
    [connectorFeatures addObject:toFeature];

    //
    int i = 0;
    for (MXMInstruction *ins in path.instructions) {
        if (ins.sign == MXMDownstairs || ins.sign == MXMUpstairs) {
            
            NSString *iconName;
            if ([ins.type isEqualToString:@"elevator_customer"] && ins.sign == MXMUpstairs) {
                iconName = @"elevator-good-up-01";
            } else if ([ins.type isEqualToString:@"elevator_customer"] && ins.sign == MXMDownstairs) {
                iconName = @"elevator-good-down-01";

            } else if ([ins.type isEqualToString:@"elevator_good"] && ins.sign == MXMUpstairs) {
                iconName = @"elevator-good-up-01";

            } else if ([ins.type isEqualToString:@"elevator_good"] && ins.sign == MXMDownstairs) {
                iconName = @"elevator-good-down-01";

            } else if ([ins.type isEqualToString:@"escalator"] && ins.sign == MXMUpstairs) {
                iconName = @"escalator-up-01";

            } else if ([ins.type isEqualToString:@"escalator"] && ins.sign == MXMDownstairs) {
                iconName = @"escalator-down-01";

            } else if ([ins.type isEqualToString:@"ramp"] && ins.sign == MXMUpstairs) {
                iconName = @"ramp-up-01";

            } else if ([ins.type isEqualToString:@"ramp"] && ins.sign == MXMDownstairs) {
                iconName = @"ramp-down-01";

            } else if ([ins.type isEqualToString:@"stairs"] && ins.sign == MXMUpstairs) {
                iconName = @"stairs-up-01";

            } else if ([ins.type isEqualToString:@"stairs"] && ins.sign == MXMDownstairs) {
                iconName = @"stairs-down-01";

            }
            
            // 当前楼层转折点
            NSNumber *fristIndex = ins.interval.firstObject;
            MXMGeoPoint *fristPoint = pointList[[fristIndex integerValue]];
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            if (ins.buildingId) {
                attributes[@"key"] = [NSString stringWithFormat:@"%@-%@", ins.buildingId, ins.floor];
            } else {
                attributes[@"key"] = @"outdoor";
            }
            attributes[@"iconName"] = iconName;
            MGLPointFeature *pointFeature = [[MGLPointFeature alloc] init];
            pointFeature.coordinate = CLLocationCoordinate2DMake(fristPoint.latitude, fristPoint.longitude);
            pointFeature.attributes = attributes;
            [connectorFeatures addObject:pointFeature];
            // 下一楼层转折点
            // 通过下一个instrunction拿到下个楼层
            MXMInstruction *nextIns = (i+1 < path.instructions.count) ? path.instructions[i+1] : nil;
            NSNumber *lastIndex = ins.interval.lastObject;
            MXMGeoPoint *lastPoint = pointList[[lastIndex integerValue]];
            NSMutableDictionary *attributes2 = [NSMutableDictionary dictionary];
            if (nextIns.buildingId) {
                attributes2[@"key"] = [NSString stringWithFormat:@"%@-%@", nextIns.buildingId, nextIns.floor];
            } else {
                attributes2[@"key"] = @"outdoor";
            }
            attributes2[@"iconName"] = iconName;
            MGLPointFeature *lastPointFeature = [[MGLPointFeature alloc] init];
            lastPointFeature.coordinate = CLLocationCoordinate2DMake(lastPoint.latitude, lastPoint.longitude);
            lastPointFeature.attributes = attributes2;
            [connectorFeatures addObject:lastPointFeature];
        } else {
            // 重置bounds集
            NSString *key;
            if (![self isEmptyString:ins.buildingId]) {
                // 获取bounds队列
                key = [NSString stringWithFormat:@"%@-%@", ins.buildingId, ins.floor];
                if (fristKey == nil) {
                    fristKey = [key copy];
                }
                if (fristBuildingId == nil) {
                    fristBuildingId = ins.buildingId;
                }
                if (fristFloor == nil) {
                    fristFloor = ins.floor;
                }
            } else {
                // 获取bounds队列
                key = @"outdoor";
                if (fristKey == nil) {
                    fristKey = [key copy];
                }
            }

            // 整合线段
            int t = 0;
            NSUInteger fIndex = [ins.interval.firstObject unsignedIntegerValue];
            NSUInteger lIndex = [ins.interval.lastObject unsignedIntegerValue];
            NSArray *subArr = [pointList subarrayWithRange:NSMakeRange(fIndex, lIndex-fIndex+1)];
            CLLocationCoordinate2D routeCoordinates[subArr.count];
            for (MXMGeoPoint *p in subArr) {
                routeCoordinates[t] = CLLocationCoordinate2DMake(p.latitude, p.longitude);
                t++;
            }
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"key"] = key;
//            dic[@"lineType"] = [key isEqualToString:@"outdoor"]? @"outdoor": @"indoor";
            MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:subArr.count];
            feature.attributes = dic;
            
            NSMutableArray *boundsArr;
            boundsArr = [self.lineBound objectForKey:key]?:[NSMutableArray array];
            [boundsArr addObject:feature];
            [self.lineBound setObject:boundsArr forKey:key];
            [lineFeatures addObject:feature];
        }
        i++;
    }

    // 添加线渲染层数据
    MGLShapeSource *lineSource = [[MGLShapeSource alloc] initWithIdentifier:@"lineSource" features:lineFeatures options:nil];
    [self.mapView.style addSource:lineSource];
    // 添加线渲染层
    MGLLineStyleLayer *lineLayer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-line-layer" source:lineSource];
    lineLayer.lineWidth = [NSExpression expressionForConstantValue:@5];
    lineLayer.lineColor = [NSExpression expressionWithFormat:@"MGL_MATCH(key, 'outdoor', %@, %@)",
                           [UIColor colorWithRed:107.0/255.0 green:208.0/255.0 blue:156.0/255.0 alpha:1],
                           [UIColor colorWithRed:0.29 green:0.69 blue:0.83 alpha:1]];
    lineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    [self.mapView.style addLayer:lineLayer];
    // 添加线方向渲染层
    MGLSymbolStyleLayer *arrowLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-arrow-layer" source:lineSource];
    arrowLayer.iconImageName = [NSExpression expressionForConstantValue:@"east-blue-arrow-01"];
    arrowLayer.symbolPlacement = [NSExpression expressionForConstantValue:[NSValue valueWithMGLSymbolPlacement:MGLSymbolPlacementLineCenter]];
    arrowLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    arrowLayer.symbolSpacing = [NSExpression expressionForConstantValue:@1];
    arrowLayer.predicate = [NSPredicate predicateWithFormat:@"$zoomLevel > 15"];
    [self.mapView.style addLayer:arrowLayer];
    
    
    // 添加转折点渲染层数据
    MGLShapeSource *connectorSource = [[MGLShapeSource alloc] initWithIdentifier:@"connectorSource" features:connectorFeatures options:nil];
    [self.mapView.style addSource:connectorSource];
    // 添加转折点渲染层
    MGLSymbolStyleLayer *connectorLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-connector-layer" source:connectorSource];
    connectorLayer.iconImageName = [NSExpression expressionForKeyPath:@"iconName"];
    connectorLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    connectorLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(iconName, 'poi-01', %@, %@)", @(0.4),  @(1)];
    connectorLayer.iconScale = [NSExpression expressionForConstantValue:@(1)];
    connectorLayer.symbolSpacing = [NSExpression expressionForConstantValue:@1];
    connectorLayer.predicate = [NSPredicate predicateWithFormat:@"$zoomLevel > 15"];
    connectorLayer.iconAnchor = [NSExpression expressionWithFormat:@"MGL_MATCH(iconName, 'poi-01', %@, %@)", @"bottom",  @"center"];
    [self.mapView.style addLayer:connectorLayer];
    
    // 首次分层
    [self.map selectBuilding:fristBuildingId floor:fristFloor shouldZoomTo:NO];
    [self changeOnBuilding:fristBuildingId floor:fristFloor];
    
    if (self.routeScaleFit) {
        // 搜索完首次缩放
        NSArray *boundsArr = self.lineBound[fristKey];
        int count = 0;
        for (MGLPolylineFeature *feature in boundsArr) {
            count += feature.pointCount;
        }
        
        CLLocationCoordinate2D fristRouteCoordinates[count];
        int t = 0;
        for (MGLPolylineFeature *feature in boundsArr) {
            for (int i=0; i<feature.pointCount; i++) {
                fristRouteCoordinates[t] = feature.coordinates[i];
                t++;
            }
        }
        [self.mapView setVisibleCoordinates:fristRouteCoordinates count:count edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    }
}

- (void)cleanRoute
{
    // clean history layer
    MGLStyleLayer *layer1 = [self.mapView.style layerWithIdentifier:@"route-line-layer"];
    MGLStyleLayer *layer2 = [self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
    MGLStyleLayer *layer3 = [self.mapView.style layerWithIdentifier:@"route-connector-layer"];
    MGLStyleLayer *layer4 = [self.mapView.style layerWithIdentifier:@"route-addLine-layer"];
    
    layer1 ? [self.mapView.style removeLayer:layer1] : nil;
    layer2 ? [self.mapView.style removeLayer:layer2] : nil;
    layer3 ? [self.mapView.style removeLayer:layer3] : nil;
    layer4 ? [self.mapView.style removeLayer:layer4] : nil;

    MGLSource *source1 = [self.mapView.style sourceWithIdentifier:@"lineSource"];
    MGLSource *source2 = [self.mapView.style sourceWithIdentifier:@"connectorSource"];
    MGLSource *source3 = [self.mapView.style sourceWithIdentifier:@"addLineSource"];

    source1 ? [self.mapView.style removeSource:source1] : nil;
    source2 ? [self.mapView.style removeSource:source2] : nil;
    source3 ? [self.mapView.style removeSource:source3] : nil;
}

- (void)changeOnBuilding:(NSString *)buildingId floor:(NSString *)floor
{
    NSString *key = [NSString stringWithFormat:@"%@-%@", buildingId, floor];

    MGLLineStyleLayer *lineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-line-layer"];
    lineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
    
    MGLLineStyleLayer *addLineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-addLine-layer"];
    addLineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];

    MGLSymbolStyleLayer *arrowLayer = (MGLSymbolStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
    arrowLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1),  @(0.4)];
    
    MGLVectorStyleLayer *connectorLayer = (MGLVectorStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-connector-layer"];
    connectorLayer.predicate = [self createPredicateWith:connectorLayer.predicate floor:floor building:buildingId];
    
    if (self.routeScaleFit) {
        NSArray *boundsArr = self.lineBound[key];
        
        int count = 0;
        for (MGLPolylineFeature *feature in boundsArr) {
            count += feature.pointCount;
        }
        
        CLLocationCoordinate2D routeCoordinates[count];
        int t = 0;
        for (MGLPolylineFeature *feature in boundsArr) {
            for (int i=0; i<feature.pointCount; i++) {
                routeCoordinates[t] = feature.coordinates[i];
                t++;
            }
        }
        [self.mapView setVisibleCoordinates:routeCoordinates count:count edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    }
}

- (NSCompoundPredicate *)createPredicateWith:(id)predicate floor:(NSString *)floorName building:(NSString *)buildingId
{
    NSString *key = [NSString stringWithFormat:@"%@-%@", buildingId, floorName];
    
    // 处理剩下需要添加filter的layer
    id originalPredicate = predicate;
    NSMutableArray *mu = [NSMutableArray arrayWithCapacity:0];
    if ([originalPredicate isKindOfClass:[NSCompoundPredicate class]]) {
        NSArray *sub = ((NSCompoundPredicate *)originalPredicate).subpredicates;
        for (NSCompoundPredicate *s in sub) {
            NSString *str = s.predicateFormat;
            if (![str containsString:@"key =="] &&
                ![str containsString:@"building =="] &&
                ![str containsString:@"key !="] &&
                ![str containsString:@"iconName =="] &&
                ![str containsString:@"iconName !="]) {
                [mu addObject:s];
            }
        }
    } else {
        if (originalPredicate) {
            [mu addObject:originalPredicate];
        }
    }
    
    NSMutableArray *fandb = [NSMutableArray array];
    NSPredicate *f = [NSPredicate predicateWithFormat:@"key == %@", key];
    [fandb addObject:f];
    NSPredicate *i = [NSPredicate predicateWithFormat:@"iconName != %@", @"poi-01"];
    [fandb addObject:i];
    NSCompoundPredicate *subP = [NSCompoundPredicate andPredicateWithSubpredicates:fandb];
    
    NSPredicate *otherP1 = [NSPredicate predicateWithFormat:@"building == %@", buildingId];
    NSPredicate *otherP3 = [NSPredicate predicateWithFormat:@"key != %@", key];
    NSPredicate *otherT = [NSPredicate predicateWithFormat:@"key != %@", @"outdoor"];
    NSPredicate *otherP2 = [NSPredicate predicateWithFormat:@"iconName == %@", @"poi-01"];
    NSCompoundPredicate *osubP3 = [NSCompoundPredicate andPredicateWithSubpredicates:@[otherP1, otherT, otherP2, otherP3]];

    NSMutableArray *orArr = [NSMutableArray array];
    [orArr addObject:osubP3];
    [orArr addObject:subP];
    NSCompoundPredicate *rPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:orArr];
    
    [mu addObject:rPredicate];
    
    NSCompoundPredicate *reSetPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:mu];
    // 重置过滤
    return reSetPredicate;
}

- (NSMutableDictionary *)lineBound
{
    if (!_lineBound) {
        _lineBound = [NSMutableDictionary dictionary];
    }
    return _lineBound;
}

- (BOOL)isEmptyString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

@end

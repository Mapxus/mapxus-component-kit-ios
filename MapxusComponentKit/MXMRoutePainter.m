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
        self.mapView = mapView;
        self.map = map;
    }
    return self;
}


- (void)paintRouteUsingRequest:(MXMRouteSearchRequest *)request Result:(MXMRouteSearchResponse *)result
{
    // 绘制前清除
    [self cleanRoute];
    // 取出方案组中的第一个方案
    MXMRoute *route = result.routes.firstObject;
    // 将取出方案的二维数组整理成一维数组
    NSMutableArray *lineList = [NSMutableArray array];
    for (MXMLeg *leg in route.legs) {
        for (MXMStep *step in leg.steps) {
            [lineList addObject:step];
        }
    }
    // 补充起点偏移段
    MXMGeoPoint *startPoint = [[MXMGeoPoint alloc] init];
    startPoint.latitude = request.fromLat;
    startPoint.longitude = request.fromLon;
    
    MXMStep *fristStep = lineList.firstObject;
    NSMutableArray *fristStepArr = [NSMutableArray arrayWithArray:fristStep.coordinates];
    MXMCoordinate *fcoor = [[MXMCoordinate alloc] init];
    fcoor.buildingId = request.fromBuilding;
    fcoor.floor = request.fromFloor;
    fcoor.location = startPoint;
    [fristStepArr insertObject:fcoor atIndex:0];
    fristStep.coordinates = fristStepArr;
    // 补充终点偏移段
    MXMGeoPoint *endPoint = [[MXMGeoPoint alloc] init];
    endPoint.latitude = request.toLat;
    endPoint.longitude = request.toLon;
    
    MXMStep *lastStep = lineList.lastObject;
    NSMutableArray *lastStepArr = [NSMutableArray arrayWithArray:lastStep.coordinates];
    MXMCoordinate *lcoor = [[MXMCoordinate alloc] init];
    lcoor.buildingId = request.toBuilding;
    lcoor.floor = request.toFloor;
    lcoor.location = endPoint;
    [lastStepArr addObject:lcoor];
    lastStep.coordinates = lastStepArr;
    // 室内画线数据处理
    NSMutableArray *lineFeatures = [NSMutableArray array];
    NSMutableArray *connectorFeatures = [NSMutableArray array];
    NSString *fristKey = nil;
    NSString *fristBuildingId = nil;
    NSString *fristFloor = nil;
    for (MXMStep *step in lineList) {
        // 去掉转折段，暂由前端处理，以后由服务器处理
        MXMCoordinate *frist = step.coordinates.firstObject;
        MXMCoordinate *last = step.coordinates.lastObject;
        if (frist.floor && last.floor && ![frist.floor isEqualToString:last.floor]) {
            continue;
        }
        // 添加全线段内容
        CLLocationCoordinate2D routeCoordinates[step.coordinates.count];
        int i = 0;
        for (MXMCoordinate *coor in step.coordinates) {
            routeCoordinates[i] = CLLocationCoordinate2DMake(coor.location.latitude, coor.location.longitude);
            i++;
            // 添加转折内容
            if ([coor.type isEqualToString:@"connector"]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if (coor.buildingId) {
                    dic[@"routeType"] = @"indoor";
                    dic[@"building"] = step.buildingId;
                    dic[@"floor"] = step.floor;
                } else {
                    dic[@"routeType"] = @"outdoor";
                }
                MGLPointFeature *pointFeature = [[MGLPointFeature alloc] init];
                pointFeature.coordinate = CLLocationCoordinate2DMake(coor.location.latitude, coor.location.longitude);
                pointFeature.attributes = dic;
                [connectorFeatures addObject:pointFeature];
            }
        }
        NSMutableArray *boundsArr;
        NSString *key;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (![self isEmptyString:step.buildingId]) {
            // 存入线特性
            dic[@"routeType"] = @"indoor";
            dic[@"building"] = step.buildingId;
            dic[@"floor"] = step.floor;
            // 获取经纬集队列
            key = [NSString stringWithFormat:@"%@-%@", step.buildingId, step.floor];
            boundsArr = [self.lineBound objectForKey:key]?:[NSMutableArray array];
            if (fristKey == nil) {
                fristKey = [key copy];
            }
            if (fristBuildingId == nil) {
                fristBuildingId = step.buildingId;
            }
            if (fristFloor == nil) {
                fristFloor = step.floor;
            }
        } else {
            // 存入线特性
            dic[@"routeType"] = @"outdoor";
            // 获取经纬集队列
            key = @"outdoor";
            boundsArr = [self.lineBound objectForKey:key]?:[NSMutableArray array];
            if (fristKey == nil) {
                fristKey = [key copy];
            }
        }
        MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:step.coordinates.count];
        feature.attributes = dic;
        [lineFeatures addObject:feature];
        
        // 重置经纬集
        [boundsArr addObject:feature];
        [self.lineBound setObject:boundsArr forKey:key];
    }
    // 添加线渲染层数据
    MGLShapeSource *lineSource = [[MGLShapeSource alloc] initWithIdentifier:@"lineSource" features:lineFeatures options:nil];
    [self.mapView.style addSource:lineSource];
    // 添加线渲染层
    MGLLineStyleLayer *lineLayer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-line-layer" source:lineSource];
    lineLayer.lineWidth = [NSExpression expressionForConstantValue:@5];
    lineLayer.lineColor = [NSExpression expressionForConstantValue:[UIColor colorWithRed:0.29 green:0.69 blue:0.83 alpha:1]];
    lineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    [self.mapView.style addLayer:lineLayer];
    // 添加线方向渲染层
    MGLSymbolStyleLayer *arrowLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-arrow-layer" source:lineSource];
    arrowLayer.iconImageName = [NSExpression expressionForConstantValue:@"east-blue-arrow-01"];
    arrowLayer.symbolPlacement = [NSExpression expressionForConstantValue:[NSValue valueWithMGLSymbolPlacement:MGLSymbolPlacementLineCenter]];
    arrowLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    arrowLayer.symbolSpacing = [NSExpression expressionForConstantValue:@1];
    arrowLayer.predicate = [NSPredicate predicateWithFormat:@"$zoomLevel > 14"];
    [self.mapView.style addLayer:arrowLayer];
    
    // 添加转折点渲染层数据
    MGLShapeSource *connectorSource = [[MGLShapeSource alloc] initWithIdentifier:@"connectorSource" features:connectorFeatures options:nil];
    [self.mapView.style addSource:connectorSource];
    // 添加转折点渲染层
    MGLSymbolStyleLayer *connectorLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-connector-layer" source:connectorSource];
    connectorLayer.iconImageName = [NSExpression expressionForConstantValue:@"up-down-01"];
    connectorLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    connectorLayer.iconScale = [NSExpression expressionForConstantValue:@(1.3)];
    connectorLayer.symbolSpacing = [NSExpression expressionForConstantValue:@1];
    connectorLayer.predicate = [NSPredicate predicateWithFormat:@"$zoomLevel > 14"];
    [self.mapView.style addLayer:connectorLayer];
    
    // 首次分层
    [self.map selectBuilding:fristBuildingId floor:fristFloor shouldZoomTo:NO];
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
//    NSArray *boundsArr = self.lineBound[fristKey];
//    MGLPolylineFeature *fristLine = boundsArr.firstObject;
//    MGLCoordinateBounds bounds = fristLine.overlayBounds;
//    for (MGLPolylineFeature *feature in boundsArr) {
//        bounds = MGLCoordinateBoundsUnion(bounds, feature.overlayBounds);
//    }
//    [self.mapView setVisibleCoordinateBounds:bounds edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
}

- (void)cleanRoute
{
    // clean history layer
    MGLStyleLayer *layer1 = [self.mapView.style layerWithIdentifier:@"route-line-layer"];
    MGLStyleLayer *layer2 = [self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
    MGLStyleLayer *layer3 = [self.mapView.style layerWithIdentifier:@"route-connector-layer"];
    
    layer1 ? [self.mapView.style removeLayer:layer1] : nil;
    layer2 ? [self.mapView.style removeLayer:layer2] : nil;
    layer3 ? [self.mapView.style removeLayer:layer3] : nil;
    
    MGLSource *source1 = [self.mapView.style sourceWithIdentifier:@"lineSource"];
    MGLSource *source2 = [self.mapView.style sourceWithIdentifier:@"connectorSource"];
    
    source1 ? [self.mapView.style removeSource:source1] : nil;
    source2 ? [self.mapView.style removeSource:source2] : nil;
}

- (void)changeOnBuilding:(NSString *)buildingId floor:(NSString *)floor
{
    MGLVectorStyleLayer *lineLayer = (MGLVectorStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-line-layer"];
    lineLayer.predicate = [self createPredicateWith:lineLayer.predicate floor:floor building:buildingId];
    
    MGLVectorStyleLayer *arrowLayer = (MGLVectorStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
    arrowLayer.predicate = [self createPredicateWith:arrowLayer.predicate floor:floor building:buildingId];
    
    MGLVectorStyleLayer *connectorLayer = (MGLVectorStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-connector-layer"];
    connectorLayer.predicate = [self createPredicateWith:connectorLayer.predicate floor:floor building:buildingId];
    
    
    NSString *key = [NSString stringWithFormat:@"%@-%@", buildingId, floor];
    NSArray *boundsArr = self.lineBound[key];
//    if (boundsArr) {
//        MGLPolylineFeature *fristLine = boundsArr.firstObject;
//        MGLCoordinateBounds bounds = fristLine.overlayBounds;
//        for (MGLPolylineFeature *feature in boundsArr) {
//            bounds = MGLCoordinateBoundsUnion(bounds, feature.overlayBounds);
//        }
//        [self.mapView setVisibleCoordinateBounds:bounds edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
//    }
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

- (NSCompoundPredicate *)createPredicateWith:(id)predicate floor:(NSString *)floorName building:(NSString *)buildingId
{
    // 处理剩下需要添加filter的layer
    id originalPredicate = predicate;
    NSMutableArray *mu = [NSMutableArray arrayWithCapacity:0];
    if ([originalPredicate isKindOfClass:[NSCompoundPredicate class]]) {
        NSArray *sub = ((NSCompoundPredicate *)originalPredicate).subpredicates;
        for (NSCompoundPredicate *s in sub) {
            NSString *str = s.predicateFormat;
            if (![str containsString:@"floor =="] && ![str containsString:@"building =="] && ![str containsString:@"route-type =="]) {
                [mu addObject:s];
            }
        }
    } else {
        if (originalPredicate) {
            [mu addObject:originalPredicate];
        }
    }
    
    NSMutableArray *fandb = [NSMutableArray array];
    NSPredicate *f = [NSPredicate predicateWithFormat:@"floor == %@", floorName];
    [fandb addObject:f];
    NSPredicate *b = [NSPredicate predicateWithFormat:@"building == %@", buildingId];
    [fandb addObject:b];
    NSPredicate *t = [NSPredicate predicateWithFormat:@"routeType == %@", @"indoor"];
    [fandb addObject:t];
    NSCompoundPredicate *subP = [NSCompoundPredicate andPredicateWithSubpredicates:fandb];
    
    NSMutableArray *orArr = [NSMutableArray array];
    NSPredicate *otherT = [NSPredicate predicateWithFormat:@"routeType == %@", @"outdoor"];
    [orArr addObject:otherT];
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

NS_INLINE MGLCoordinateBounds MGLCoordinateBoundsUnion(MGLCoordinateBounds bounds1, MGLCoordinateBounds bounds2) {
    MGLCoordinateBounds unionBounds;
    unionBounds.sw.latitude = MIN(bounds1.sw.latitude, bounds2.sw.latitude);
    unionBounds.sw.longitude = MIN(bounds1.sw.longitude, bounds2.sw.longitude);
    unionBounds.ne.latitude = MAX(bounds1.ne.latitude, bounds2.ne.latitude);
    unionBounds.ne.longitude = MAX(bounds1.ne.longitude, bounds2.ne.longitude);
    return unionBounds;
}

@end

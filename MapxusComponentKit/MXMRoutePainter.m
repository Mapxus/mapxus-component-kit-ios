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

- (void)paintRouteUsingResult:(MXMRouteSearchResponse *)result
{
    // 1.clears data before drawing
    [self cleanRoute];
    // 2.Take the first path in the path group
    MXMPath *firstPath = result.paths.firstObject;
    MXMIndoorPoint *startP = result.wayPointList.firstObject;
    MXMIndoorPoint *endP = result.wayPointList.lastObject;
    self.dto = [[MXMPainterPathDto alloc] initWithPath:firstPath startPoint:startP endPoint:endP];
    
    // 3.Supplementary starting line
    NSMutableArray *addLineFeatures = [NSMutableArray array];
    {
        NSString *firstKey = self.dto.keys.firstObject;
        if (firstKey) {
            MXMParagraph *firstPaph = self.dto.paragraphs[firstKey];
            NSArray *pointList = firstPaph.points;
            MXMGeoPoint *fristPoint = pointList.firstObject;
            
            CLLocationCoordinate2D routeCoordinates[2];
            routeCoordinates[0] = CLLocationCoordinate2DMake(startP.latitude, startP.longitude);
            routeCoordinates[1] = CLLocationCoordinate2DMake(fristPoint.latitude, fristPoint.longitude);
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if ([self isEmptyString:startP.buildingId]) {
                dic[@"key"] = @"outdoor";
            } else {
                dic[@"key"] = firstKey;
            }
            MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:2];
            feature.attributes = dic;
            
            [addLineFeatures addObject:feature];
        }
    }

    // 4.Supplementary finish line
    {
        NSString *lastKey = self.dto.keys.lastObject;
        if (lastKey) {
            MXMParagraph *lastPaph = self.dto.paragraphs[lastKey];
            NSArray *pointList = lastPaph.points;
            MXMGeoPoint *lastPoint = pointList.lastObject;
            
            CLLocationCoordinate2D routeCoordinates[2];
            routeCoordinates[0] = CLLocationCoordinate2DMake(endP.latitude, endP.longitude);
            routeCoordinates[1] = CLLocationCoordinate2DMake(lastPoint.latitude, lastPoint.longitude);
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if ([self isEmptyString:endP.buildingId]) {
                dic[@"key"] = @"outdoor";
            } else {
                dic[@"key"] = lastKey;
            }
            MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:2];
            feature.attributes = dic;
            
            [addLineFeatures addObject:feature];
        }
    }

    // 添加虚线段
    MGLShapeSource *addLineSource = [[MGLShapeSource alloc] initWithIdentifier:@"addLineSource" features:addLineFeatures options:nil];
    [self.mapView.style addSource:addLineSource];
    // 添加线渲染层
    MGLLineStyleLayer *addLineLayer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-addLine-layer" source:addLineSource];
    addLineLayer.lineWidth = [NSExpression expressionForConstantValue:@5];
    addLineLayer.lineColor = [NSExpression expressionForConstantValue:[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1]];
    addLineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    addLineLayer.lineDashPattern = [NSExpression expressionForConstantValue:@[@(1), @(2)]];
    [self.mapView.style addLayer:addLineLayer];

    
    // 添加路线
    NSMutableArray *lineFeatures = [NSMutableArray array];
    NSMutableArray *connectorFeatures = [NSMutableArray array];

//    // 添加起始点透明图标
//    NSMutableDictionary *startAttributes = [NSMutableDictionary dictionary];
//    if (startP.buildingId) {
//        startAttributes[@"key"] = [NSString stringWithFormat:@"%@-%@", startP.buildingId, startP.floor];
//        startAttributes[@"building"] = startP.buildingId;
//    } else {
//        startAttributes[@"key"] = @"outdoor";
//    }
//    startAttributes[@"iconName"] = @"poi-01";
//    MGLPointFeature *startFeature = [[MGLPointFeature alloc] init];
//    startFeature.coordinate = CLLocationCoordinate2DMake(startP.latitude, startP.longitude);
//    startFeature.attributes = startAttributes;
//    [connectorFeatures addObject:startFeature];
//    // 添加终点透明图标
//    NSMutableDictionary *endAttributes = [NSMutableDictionary dictionary];
//    if (endP.buildingId) {
//        endAttributes[@"key"] = [NSString stringWithFormat:@"%@-%@", endP.buildingId, endP.floor];
//        endAttributes[@"building"] = endP.buildingId;
//    } else {
//        endAttributes[@"key"] = @"outdoor";
//    }
//    endAttributes[@"iconName"] = @"poi-01";
//    MGLPointFeature *toFeature = [[MGLPointFeature alloc] init];
//    toFeature.coordinate = CLLocationCoordinate2DMake(endP.latitude, endP.longitude);
//    toFeature.attributes = endAttributes;
//    [connectorFeatures addObject:toFeature];
    
    // 添加路线
    for (MXMParagraph *paph in self.dto.paragraphs.allValues) {
        // 当前楼层转折点
        NSString *startIconName = [self getIconNameWith:paph.startPointType];
        if (startIconName) {
            MXMGeoPoint *fristPoint = paph.points.firstObject;
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            if (paph.buildingId) {
                attributes[@"key"] = [NSString stringWithFormat:@"%@-%@", paph.buildingId, paph.floor];
            } else {
            attributes[@"key"] = @"outdoor";
            }
            attributes[@"iconName"] = startIconName;
            MGLPointFeature *pointFeature = [[MGLPointFeature alloc] init];
            pointFeature.coordinate = CLLocationCoordinate2DMake(fristPoint.latitude, fristPoint.longitude);
            pointFeature.attributes = attributes;
            [connectorFeatures addObject:pointFeature];
        }
        // 到下一楼层转折点
        NSString *endIconName = [self getIconNameWith:paph.endPointType];
        if (endIconName) {
            MXMGeoPoint *lastPoint = paph.points.lastObject;
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            if (paph.buildingId) {
                attributes[@"key"] = [NSString stringWithFormat:@"%@-%@", paph.buildingId, paph.floor];
            } else {
                attributes[@"key"] = @"outdoor";
            }
            attributes[@"iconName"] = endIconName;
            MGLPointFeature *pointFeature = [[MGLPointFeature alloc] init];
            pointFeature.coordinate = CLLocationCoordinate2DMake(lastPoint.latitude, lastPoint.longitude);
            pointFeature.attributes = attributes;
            [connectorFeatures addObject:pointFeature];
        }

        
        // 整合线段
        int t = 0;
        CLLocationCoordinate2D routeCoordinates[paph.points.count];
        for (MXMGeoPoint *p in paph.points) {
            routeCoordinates[t] = CLLocationCoordinate2DMake(p.latitude, p.longitude);
            t++;
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (paph.buildingId) {
            dic[@"key"] = [NSString stringWithFormat:@"%@-%@", paph.buildingId, paph.floor];
        } else {
            dic[@"key"] = @"outdoor";
        }
        MGLPolylineFeature *feature = [MGLPolylineFeature polylineWithCoordinates:routeCoordinates count:paph.points.count];
        feature.attributes = dic;
        
        [lineFeatures addObject:feature];
    }

    NSBundle *bundle = [NSBundle bundleForClass:[MXMRoutePainter class]];
    UIImage *image = [UIImage imageNamed:@"right" inBundle:bundle compatibleWithTraitCollection:nil];
    [self.mapView.style setImage:image forName:@"right"];

    // 添加线渲染层数据
    MGLShapeSource *lineSource = [[MGLShapeSource alloc] initWithIdentifier:@"lineSource" features:lineFeatures options:nil];
    [self.mapView.style addSource:lineSource];
    // 添加线渲染层
    MGLLineStyleLayer *lineLayer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-line-layer" source:lineSource];
    lineLayer.lineWidth = [NSExpression expressionForConstantValue:@8];
    lineLayer.lineColor = [NSExpression expressionWithFormat:@"MGL_MATCH(key, 'outdoor', %@, %@)",
                           [UIColor colorWithRed:107.0/255.0 green:208.0/255.0 blue:156.0/255.0 alpha:1],
                           [UIColor colorWithRed:0.29 green:0.69 blue:0.83 alpha:1]];
    lineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    lineLayer.lineJoin = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineJoin:(MGLLineJoinRound)]];
    [self.mapView.style addLayer:lineLayer];
    // 添加线方向渲染层
    MGLSymbolStyleLayer *arrowLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-arrow-layer" source:lineSource];
//    arrowLayer.iconImageName = [NSExpression expressionForConstantValue:@"east-blue-arrow-01"];
    arrowLayer.iconImageName = [NSExpression expressionForConstantValue:@"right"];
    arrowLayer.symbolPlacement = [NSExpression expressionForConstantValue:[NSValue valueWithMGLSymbolPlacement:MGLSymbolPlacementLine]];
    arrowLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    arrowLayer.symbolSpacing = [NSExpression expressionForConstantValue:@30];
//    arrowLayer.predicate = [NSPredicate predicateWithFormat:@"$zoomLevel > 15"];
    [self.mapView.style addLayer:arrowLayer];

    
    // 添加转折点渲染层数据
    MGLShapeSource *connectorSource = [[MGLShapeSource alloc] initWithIdentifier:@"connectorSource" features:connectorFeatures options:nil];
    [self.mapView.style addSource:connectorSource];
    // 添加转折点渲染层
    MGLSymbolStyleLayer *connectorLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-connector-layer" source:connectorSource];
    connectorLayer.iconImageName = [NSExpression expressionForKeyPath:@"iconName"];
    connectorLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    connectorLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(iconName, 'poi-01', %@, %@)", @(0.4),  @(1)];
    connectorLayer.iconScale = [NSExpression expressionForConstantValue:@(0.8)];
    connectorLayer.symbolSpacing = [NSExpression expressionForConstantValue:@1];
    connectorLayer.predicate = [NSPredicate predicateWithFormat:@"$zoomLevel > 15"];
    connectorLayer.iconAnchor = [NSExpression expressionWithFormat:@"MGL_MATCH(iconName, 'poi-01', %@, %@)", @"bottom",  @"center"];
    [self.mapView.style addLayer:connectorLayer];

    // 首次分层
//    [self.map selectBuilding:fristBuildingId floor:fristFloor shouldZoomTo:NO];
}

- (NSString *)getIconNameWith:(RoutePainterNodeType)type
{
    NSString *iconName;
    switch (type) {
        case ElevatorGoodUp:
            iconName = @"elevator-good-up-01";
            break;
        case ElevatorGoodDown:
            iconName = @"elevator-good-down-01";
            break;
        case EscalatorUp:
            iconName = @"escalator-up-01";
            break;
        case EscalatorDown:
            iconName = @"escalator-down-01";
            break;
        case RampUp:
            iconName = @"ramp-up-01";
            break;
        case RampDown:
            iconName = @"ramp-down-01";
            break;
        case StairsUp:
            iconName = @"stairs-up-01";
            break;
        case StairsDown:
            iconName = @"stairs-down-01";
            break;
        default:
            break;
    }
    return iconName;
}

- (void)cleanRoute
{
    self.dto = nil;
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

- (void)changeWithKey:(NSString *)key
{
    MXMParagraph *paph = [self.dto.paragraphs objectForKey:key];
    MGLLineStyleLayer *lineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-line-layer"];
    lineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
    
    MGLLineStyleLayer *addLineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-addLine-layer"];
    addLineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
    
    MGLSymbolStyleLayer *arrowLayer = (MGLSymbolStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
    arrowLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1),  @(0.4)];
    
    MGLVectorStyleLayer *connectorLayer = (MGLVectorStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-connector-layer"];
    connectorLayer.predicate = [self createPredicateWith:connectorLayer.predicate floor:paph.floor building:paph.buildingId];
    
    if (self.routeScaleFit) {
        NSInteger count = paph.points.count;
        CLLocationCoordinate2D routeCoordinates[count];
        int t = 0;
        for (MXMGeoPoint *p in paph.points) {
            routeCoordinates[t] = CLLocationCoordinate2DMake(p.latitude, p.longitude);
            t++;
        }
        [self.mapView setVisibleCoordinates:routeCoordinates count:count edgePadding:self.FittedEdgeInsets animated:YES];
    }
}

- (void)changeOnBuilding:(NSString *)buildingId floor:(NSString *)floor
{
    NSString *key = [NSString stringWithFormat:@"%@-%@", buildingId, floor];
    [self changeWithKey:key];
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

//
//  MXMRoutePainter.m
//  MXMComponentKit
//
//  Created by Chenghao Guo on 2018/10/17.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMRoutePainter.h"
#import "NSString+Compare.h"


static NSString *arrowIconString = @"arrowIcon";
static NSString *startIconString = @"startIcon";
static NSString *endIconString = @"endIcon";
static NSString *elevatorUpIconString = @"elevatorUpIcon";
static NSString *elevatorDownIconString = @"elevatorDownIcon";
static NSString *escalatorUpIconString = @"escalatorUpIcon";
static NSString *escalatorDownIconString = @"escalatorDownIcon";
static NSString *rampUpIconString = @"rampUpIcon";
static NSString *rampDownIconString = @"rampDownIcon";
static NSString *stairsUpIconString = @"stairsUpIcon";
static NSString *stairsDownIconString = @"stairsDownIcon";
static NSString *buildingGateIconString = @"buildingGateIcon";


@interface MXMRoutePainter ()
@property (nonatomic, weak) MGLMapView *mapView;
@end


@implementation MXMRoutePainter

- (instancetype)initWithMapView:(MGLMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.indoorLineColor = [UIColor colorWithRed:0.29 green:0.69 blue:0.83 alpha:1];
        self.outdoorLineColor = [UIColor colorWithRed:0.42 green:0.82 blue:0.61 alpha:1];
        self.dashLineColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1];
        self.arrowSymbolSpacing = @30;
        [self addDefaultImage];
    }
    return self;
}

// 配置默认图标
- (void)addDefaultImage
{
    NSBundle *bundle = [NSBundle bundleForClass:[MXMRoutePainter class]];
    self.arrowIcon = [UIImage imageNamed:@"right" inBundle:bundle compatibleWithTraitCollection:nil];
    self.startIcon = [UIImage imageNamed:@"start_marker" inBundle:bundle compatibleWithTraitCollection:nil];
    self.endIcon = [UIImage imageNamed:@"end_marker" inBundle:bundle compatibleWithTraitCollection:nil];
    self.elevatorUpIcon = [UIImage imageNamed:@"elevator-up" inBundle:bundle compatibleWithTraitCollection:nil];
    self.elevatorDownIcon = [UIImage imageNamed:@"elevator-down" inBundle:bundle compatibleWithTraitCollection:nil];
    self.escalatorUpIcon = [UIImage imageNamed:@"escalator-up" inBundle:bundle compatibleWithTraitCollection:nil];
    self.escalatorDownIcon = [UIImage imageNamed:@"escalator-down" inBundle:bundle compatibleWithTraitCollection:nil];
    self.rampUpIcon = [UIImage imageNamed:@"ramp-up" inBundle:bundle compatibleWithTraitCollection:nil];
    self.rampDownIcon = [UIImage imageNamed:@"ramp-down" inBundle:bundle compatibleWithTraitCollection:nil];
    self.stairsUpIcon = [UIImage imageNamed:@"stairs-up" inBundle:bundle compatibleWithTraitCollection:nil];
    self.stairsDownIcon = [UIImage imageNamed:@"stairs-down" inBundle:bundle compatibleWithTraitCollection:nil];
    self.buildingGateIcon = [UIImage imageNamed:@"gate_building" inBundle:bundle compatibleWithTraitCollection:nil];
}

- (void)putIconInMapView
{
    [self.mapView.style setImage:self.arrowIcon forName:arrowIconString];
    [self.mapView.style setImage:self.startIcon forName:startIconString];
    [self.mapView.style setImage:self.endIcon forName:endIconString];
    [self.mapView.style setImage:self.elevatorUpIcon forName:elevatorUpIconString];
    [self.mapView.style setImage:self.elevatorDownIcon forName:elevatorDownIconString];
    [self.mapView.style setImage:self.escalatorUpIcon forName:escalatorUpIconString];
    [self.mapView.style setImage:self.escalatorDownIcon forName:escalatorDownIconString];
    [self.mapView.style setImage:self.rampUpIcon forName:rampUpIconString];
    [self.mapView.style setImage:self.rampDownIcon forName:rampDownIconString];
    [self.mapView.style setImage:self.stairsUpIcon forName:stairsUpIconString];
    [self.mapView.style setImage:self.stairsDownIcon forName:stairsDownIconString];
    [self.mapView.style setImage:self.buildingGateIcon forName:buildingGateIconString];
}

- (void)paintRouteUsingResult:(MXMRouteSearchResponse *)result
{
    [self putIconInMapView];
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
            if ([NSString isEmpty:startP.buildingId]) {
                dic[@"key"] = @"outdoor";
            } else {
                dic[@"key"] = [NSString stringWithFormat:@"%@-%@", firstPaph.buildingId, firstPaph.floor];
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
            if ([NSString isEmpty:endP.buildingId]) {
                dic[@"key"] = @"outdoor";
            } else {
                dic[@"key"] = [NSString stringWithFormat:@"%@-%@", lastPaph.buildingId, lastPaph.floor];
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
    addLineLayer.lineWidth = [NSExpression expressionForConstantValue:@8];
    addLineLayer.lineColor = [NSExpression expressionForConstantValue:self.dashLineColor];
    addLineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    addLineLayer.lineDashPattern = [NSExpression expressionForConstantValue:@[@(1), @(2)]];
    [self.mapView.style addLayer:addLineLayer];

    
    // 添加路线
    NSMutableArray *lineFeatures = [NSMutableArray array];
    NSMutableArray *connectorFeatures = [NSMutableArray array];

    // 添加起始点透明图标
    NSMutableDictionary *startAttributes = [NSMutableDictionary dictionary];
    if (startP.buildingId) {
        startAttributes[@"key"] = [NSString stringWithFormat:@"%@-%@", startP.buildingId, startP.floor];
    } else {
        startAttributes[@"key"] = @"outdoor";
    }
    startAttributes[@"iconName"] = startIconString;
    MGLPointFeature *startFeature = [[MGLPointFeature alloc] init];
    startFeature.coordinate = CLLocationCoordinate2DMake(startP.latitude, startP.longitude);
    startFeature.attributes = startAttributes;
    [connectorFeatures addObject:startFeature];
    // 添加终点透明图标
    NSMutableDictionary *endAttributes = [NSMutableDictionary dictionary];
    if (endP.buildingId) {
        endAttributes[@"key"] = [NSString stringWithFormat:@"%@-%@", endP.buildingId, endP.floor];
    } else {
        endAttributes[@"key"] = @"outdoor";
    }
    endAttributes[@"iconName"] = endIconString;
    MGLPointFeature *toFeature = [[MGLPointFeature alloc] init];
    toFeature.coordinate = CLLocationCoordinate2DMake(endP.latitude, endP.longitude);
    toFeature.attributes = endAttributes;
    [connectorFeatures addObject:toFeature];
    
    
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

    // 添加线渲染层数据
    MGLShapeSource *lineSource = [[MGLShapeSource alloc] initWithIdentifier:@"lineSource" features:lineFeatures options:nil];
    [self.mapView.style addSource:lineSource];
    
    // 添加线渲染层
    MGLLineStyleLayer *lineLayer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-line-layer" source:lineSource];
    lineLayer.lineWidth = [NSExpression expressionForConstantValue:@8];
    lineLayer.lineColor = [NSExpression expressionWithFormat:@"MGL_MATCH(key, 'outdoor', %@, %@)",
                           self.outdoorLineColor,
                           self.indoorLineColor];
    lineLayer.lineCap = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineCap:MGLLineCapRound]];
    lineLayer.lineJoin = [NSExpression expressionForConstantValue:[NSValue valueWithMGLLineJoin:(MGLLineJoinRound)]];
    [self.mapView.style addLayer:lineLayer];
    // 添加线方向渲染层
    MGLSymbolStyleLayer *arrowLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-arrow-layer" source:lineSource];
    arrowLayer.iconImageName = [NSExpression expressionForConstantValue:arrowIconString];
    arrowLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    arrowLayer.symbolPlacement = [NSExpression expressionForConstantValue:[NSValue valueWithMGLSymbolPlacement:MGLSymbolPlacementLine]];
    arrowLayer.symbolSpacing = [NSExpression expressionForConstantValue:self.arrowSymbolSpacing];
    [self.mapView.style addLayer:arrowLayer];

    
    // 添加转折点渲染层数据
    MGLShapeSource *connectorSource = [[MGLShapeSource alloc] initWithIdentifier:@"connectorSource" features:connectorFeatures options:nil];
    [self.mapView.style addSource:connectorSource];
    
    // 添加转折点渲染层
    MGLSymbolStyleLayer *connectorLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"route-connector-layer" source:connectorSource];
    connectorLayer.iconImageName = [NSExpression expressionForKeyPath:@"iconName"];
    connectorLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    connectorLayer.symbolSpacing = [NSExpression expressionForConstantValue:@1];
    [self.mapView.style addLayer:connectorLayer];
}

- (NSString *)getIconNameWith:(MXMParagraphTurningType)type
{
    NSString *iconName;
    switch (type) {
        case ElevatorUp:
            iconName = elevatorUpIconString;
            break;
        case ElevatorDown:
            iconName = elevatorDownIconString;
            break;
        case EscalatorUp:
            iconName = escalatorUpIconString;
            break;
        case EscalatorDown:
            iconName = escalatorDownIconString;
            break;
        case RampUp:
            iconName = rampUpIconString;
            break;
        case RampDown:
            iconName = rampDownIconString;
            break;
        case StairsUp:
            iconName = stairsUpIconString;
            break;
        case StairsDown:
            iconName = stairsDownIconString;
            break;
        case BuildingGate:
            iconName = buildingGateIconString;
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

- (void)changeOnBuilding:(nullable NSString *)buildingId floor:(nullable NSString *)floor
{
    NSString *key;
    if ([NSString isEmpty:buildingId] || [NSString isEmpty:floor]) {
        key = @"outdoor";
        // 线条变色
        MGLLineStyleLayer *lineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-line-layer"];
        lineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@)", @"outdoor", @(1), @(0.4)];
        // 虚线段变色
        MGLLineStyleLayer *addLineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-addLine-layer"];
        addLineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@)", @"outdoor", @(1), @(0.4)];
        // 方向图标变色
        MGLSymbolStyleLayer *arrowLayer = (MGLSymbolStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
        arrowLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@)", @"outdoor", @(1), @(0.4)];
        // 转折点变色及隐藏
        MGLSymbolStyleLayer *connectorLayer = (MGLSymbolStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-connector-layer"];
        connectorLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@)", @"outdoor", @(1), @(0.4)];
        connectorLayer.predicate = [self createPredicateWith:key];
    } else {
        key = [NSString stringWithFormat:@"%@-%@", buildingId, floor];
        // 线条变色
        MGLLineStyleLayer *lineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-line-layer"];
        lineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
        // 虚线段变色
        MGLLineStyleLayer *addLineLayer = (MGLLineStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-addLine-layer"];
        addLineLayer.lineOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
        // 方向图标变色
        MGLSymbolStyleLayer *arrowLayer = (MGLSymbolStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-arrow-layer"];
        arrowLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
        // 转折点变色及隐藏
        MGLSymbolStyleLayer *connectorLayer = (MGLSymbolStyleLayer *)[self.mapView.style layerWithIdentifier:@"route-connector-layer"];
        connectorLayer.iconOpacity = [NSExpression expressionWithFormat:@"MGL_MATCH(key, %@, %@, %@, %@, %@)", key, @(1), @"outdoor", @(1), @(0.4)];
        connectorLayer.predicate = [self createPredicateWith:key];
    }
}


- (void)focusOnKeys:(NSArray<NSString*> *)keys edgePadding:(UIEdgeInsets)insets
{
    NSMutableArray *points = [NSMutableArray array];
    for (NSString *key in keys) {
        MXMParagraph *paph = [self.dto.paragraphs objectForKey:key];
        if (paph.points) {
            [points addObjectsFromArray:paph.points];
        }
    }
    
    NSInteger count = points.count;
    if (count > 0) {
        CLLocationCoordinate2D routeCoordinates[count];
        int i = 0;
        for (MXMGeoPoint *p in points) {
            routeCoordinates[i] = CLLocationCoordinate2DMake(p.latitude, p.longitude);
            i++;
        }
        [self.mapView setVisibleCoordinates:routeCoordinates count:count edgePadding:insets animated:YES];
    }
}


- (NSCompoundPredicate *)createPredicateWith:(NSString *)key
{
    NSPredicate *P1 = [NSPredicate predicateWithFormat:@"iconName == %@", startIconString];
    NSPredicate *P2 = [NSPredicate predicateWithFormat:@"iconName == %@", endIconString];
    NSPredicate *P3 = [NSPredicate predicateWithFormat:@"key == %@", key];
    NSPredicate *P4 = [NSPredicate predicateWithFormat:@"$zoomLevel > 15.7"];
    
    NSMutableArray *orArr = [NSMutableArray array];
    [orArr addObject:P1];
    [orArr addObject:P2];
    
    NSMutableArray *andArr = [NSMutableArray array];
    [andArr addObject:P3];
    [andArr addObject:P4];
    NSCompoundPredicate *aPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:andArr];

    [orArr addObject:aPredicate];
    
    NSCompoundPredicate *rPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:orArr];
    return rPredicate;
}

@end

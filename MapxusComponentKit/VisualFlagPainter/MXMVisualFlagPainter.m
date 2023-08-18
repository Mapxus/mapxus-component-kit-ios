//
//  MXMVisualFlagPainter.m
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2018/11/30.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMVisualFlagPainter.h"
#import "JXJsonFunctionDefine.h"

@interface MXMVisualFlagPainter () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) MGLMapView *mapView;

@end

@implementation MXMVisualFlagPainter

- (instancetype)initWithMapView:(MGLMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapTap:)];
        singleTap.delegate = self;
        [self.mapView addGestureRecognizer:singleTap];
    }
    return self;
}

- (void)handleMapTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [tap locationInView:tap.view];
        CGFloat width = 10;
        CGRect rect = CGRectMake(point.x - width / 2, point.y - width / 2, width, width);
        
        NSArray *clusters = [self.mapView visibleFeaturesInRect:rect inStyleLayersWithIdentifiers:[NSSet setWithObject:@"clusteredPorts"]];
        
        if (clusters.count) {
            MGLPointFeature *cluster = (MGLPointFeature *)clusters.firstObject;
            NSDictionary *ext = cluster.attributes;
            if (self.circleOnClickBlock) {
                self.circleOnClickBlock(ext);
            }
        }
    }
}

- (void)cleanLayer
{
    MGLStyleLayer *layer1 = [self.mapView.style layerWithIdentifier:@"clusteredPorts"];
    
    layer1 ? [self.mapView.style removeLayer:layer1] : nil;
    
    MGLSource *source1 = [self.mapView.style sourceWithIdentifier:@"visualLineSource"];
    
    source1 ? [self.mapView.style removeSource:source1] : nil;
}

- (void)renderFlagUsingNodes:(NSArray<NodeDictionary*> *)nodes
{
    [self cleanLayer];
    NSMutableArray *featureList = [NSMutableArray array];
    for (NSDictionary *dic in nodes) {
        double lat = [dic[@"latitude"] doubleValue];
        double lon = [dic[@"longitude"] doubleValue];
        
        MGLPointFeature *pointFeature = [[MGLPointFeature alloc] init];
        pointFeature.coordinate = CLLocationCoordinate2DMake(lat, lon);
        pointFeature.attributes = dic;
        [featureList addObject:pointFeature];
    }
    
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"visualLineSource" features:featureList options:nil];

    MGLCircleStyleLayer *circlesLayer = [[MGLCircleStyleLayer alloc] initWithIdentifier:@"clusteredPorts" source:source];
    circlesLayer.circleOpacity = [NSExpression expressionForConstantValue:@0.75];
    circlesLayer.circleColor = [NSExpression expressionForConstantValue:[UIColor colorWithRed:73.0/255.0 green:177.0/255.0 blue:211.0/255.0 alpha:0.75]];
    NSDictionary *stops = @{
                            @15: @(1),
                            @16: @(3),
                            @17: @(4),
                            @18: @(5),
                            @19: @(7),
                            @20: @(8),
                            @22: @(18),
                            };
    circlesLayer.circleRadius = [NSExpression expressionWithFormat:@"mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', %@, %@)",
                                @0, stops];    
    [self.mapView.style addSource:source];
    [self.mapView.style addLayer:circlesLayer];
}

- (void)changeOnFloorId:(NSString *)floorId
{
    MGLVectorStyleLayer *lineLayer = (MGLVectorStyleLayer *)[self.mapView.style layerWithIdentifier:@"clusteredPorts"];
    lineLayer.predicate = [NSPredicate predicateWithFormat:@"floorId == %@", floorId];
}

//- (NSPredicate *)createPredicateWith:(id)predicate floor:(NSString *)floorName building:(NSString *)buildingId
//{
//    NSPredicate *f = [NSPredicate predicateWithFormat:@"floor == %@", floorName];
//    return f;
//}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

//
//  MXMVisualFlagPainter.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2018/11/30.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>

typedef NSDictionary<NSString*, id> NodeDictionary;

NS_ASSUME_NONNULL_BEGIN


/**
 Defines the type of code block that is executed when the annotation is clicked
 @param node Information about the visual data carried on the annotation
 */
typedef void(^CircleOnClickBlock)(NodeDictionary *node);


/**
 * Visual map annotations painter
 */
@interface MXMVisualFlagPainter : NSObject


/**
 Block of code executed after clicking on an annotation
 */
@property (nonatomic, copy) CircleOnClickBlock circleOnClickBlock;


/**
 Initialisation
 @param mapView Rendering view
 @return Painter object
 */
- (instancetype)initWithMapView:(MGLMapView *)mapView;


/**
 Pass in rendering data
 @param nodes The list of `MXMNode` that transformed to json object
 */
- (void)renderFlagUsingNodes:(NSArray<NodeDictionary*> *)nodes;


/**
 Clear all visual annotations
 */
- (void)cleanLayer;


/**
 Toggles the display of the visual annotations corresponding to the floor of the building. This can be called in the `MapxusMapDelegate` - mapView: didChangeFloor: atBuilding: callback method.
 @param floorId The ID of floor you want to show
 */
- (void)changeOnFloorId:(NSString *)floorId;



@end

NS_ASSUME_NONNULL_END

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



/// This class is responsible for painting visual map annotations.
@interface MXMVisualFlagPainter : NSObject


/// This property is a block of code that gets executed when an annotation is clicked.
@property (nonatomic, copy) CircleOnClickBlock circleOnClickBlock;


/// Initializer method for the painter object.
///
/// @param mapView The view where the rendering will take place.
/// @return An instance of the painter object.
- (instancetype)initWithMapView:(MGLMapView *)mapView;


/// This method is used to pass in rendering data.
///
/// @param nodes The list of `MXMNode` objects that have been transformed into JSON objects.
- (void)renderFlagUsingNodes:(NSArray<NodeDictionary*> *)nodes;


/// This method is used to clear all visual annotations.
- (void)cleanLayer;


/// This method toggles the display of the visual annotations corresponding to the floor of the building.
///
/// @param floorId The ID of the floor you want to show.
///
/// @discussion
/// It can be called in the `MapxusMapDelegate` - mapView: didChangeFloor: atBuilding: callback method.
- (void)changeOnFloorId:(NSString *)floorId;

@end

NS_ASSUME_NONNULL_END

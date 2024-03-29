//
//  MXMPainterPathDto.h
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/26.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MXMCommonObj.h>
#import <MapxusComponentKit/MXMParagraph.h>


NS_ASSUME_NONNULL_BEGIN


/**
 * Planning the route collated data model
 */
@interface MXMPainterPathDto : NSObject

/// Start point
@property (nonatomic, strong, readonly) MXMIndoorPoint *startPoint DEPRECATED_MSG_ATTRIBUTE("`startPoint` is deprecated, please use `wayPoints`");

/// End point
@property (nonatomic, strong, readonly) MXMIndoorPoint *endPoint DEPRECATED_MSG_ATTRIBUTE("`endPoint` is deprecated, please use `wayPoints`");

@property (nonatomic, strong, readonly) NSArray<MXMIndoorPoint *> *wayPoints;

/**
 Key in planning order, where outdoor passages are separated by indoor passages by outdoor-1, outdoor-2 or buildingId-floor-1... to distinguish them.
 The indoor sections are grouped together by buildingId and floor.
 */
@property (nonatomic, strong, readonly) NSArray<NSString*> *keys;

/// Details of each paragraph
@property (nonatomic, strong, readonly) NSDictionary<NSString *, MXMParagraph *> *paragraphs;

/**
 Initialisation functions
 @param path One of the path form planning interface  `-(void)MXMRouteSearch:`
 @param start Start point
 @param end End point
 @return MXMPainterPathDto object
 */
- (instancetype)initWithPath:(MXMPath *)path startPoint:(MXMIndoorPoint *)start endPoint:(MXMIndoorPoint *)end;

- (instancetype)initWithPath:(MXMPath *)path wayPoints:(NSArray<MXMIndoorPoint *> *)points;

@end

NS_ASSUME_NONNULL_END

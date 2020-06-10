//
//  MXMParagraph.m
//  MapxusComponentKit
//
//  Created by Chenghao Guo on 2019/5/13.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMParagraph.h"
#import <YYModel/YYModel.h>

@implementation MXMParagraph

- (NSMutableArray<MXMGeoPoint *> *)points
{
    if (!_points) {
        _points = [NSMutableArray array];
    }
    return _points;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end

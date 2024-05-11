//
//  LocalBuildingProxy.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/8.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXMLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalBuildingProxy : NSObject

- (void)queryLocalBuildingByLocation:(CLLocation *)location completion:(void(^)(MXMLocation *result))completion;

@end

NS_ASSUME_NONNULL_END

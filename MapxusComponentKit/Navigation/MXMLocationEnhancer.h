//
//  MXMLocationEnhancer.h
//  MapxusComponentKit
//
//  Created by guochenghao on 2023/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// This module is designed to enhance the accuracy of route search and improve navigation adsorption when the user is outdoors and indoor positioning is unavailable.
@interface MXMLocationEnhancer : NSObject


/// Shared instance of the MXMLocationEnhancer class.
+ (instancetype)shared;


/// Starts the operation of the module.
- (void)start;


/// Stops the operation of the module.
- (void)stop;

@end

NS_ASSUME_NONNULL_END

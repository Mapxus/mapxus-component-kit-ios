//
//  MXMLocationEnhancer.h
//  MapxusComponentKit
//
//  Created by guochenghao on 2023/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// This module is designed to improve route search accuracy and enhance navigation adsorption 
/// when the user is outdoors and indoor positioning is unavailable.
@interface MXMLocationEnhancer : NSObject

+ (instancetype)shared;

// Starting to run the module
- (void)start;

// Halting the operation of the module
- (void)stop;

@end

NS_ASSUME_NONNULL_END

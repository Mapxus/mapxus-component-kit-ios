//
//  MXMNavigationPathDTO.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/8.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Data for the navigation function
 */
@interface MXMNavigationPathDTO : NSObject

/**
 * Converting route data into navigation data
 *
 * @param path Selected planning route
 */
- (instancetype)initWithPath:(MXMPath *)path;

@end

NS_ASSUME_NONNULL_END

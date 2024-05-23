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

/// This class represents the data for the navigation function.
@interface MXMNavigationPathDTO : NSObject


/// This method converts route data into navigation data.
///
/// @param path The selected planning route.
- (instancetype)initWithPath:(MXMPath *)path;

@end

NS_ASSUME_NONNULL_END

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
 * 导航功能的数据对象
 */
@interface MXMNavigationPathDTO : NSObject

/**
 * 把路线数据转换成导航数据
 *
 * @param path 选定的规划路线
 */
- (instancetype)initWithPath:(MXMPath *)path;

@end

NS_ASSUME_NONNULL_END

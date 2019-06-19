//
//  MXMLoggerService.h
//  MapxusBaseSDK
//
//  Created by Chenghao Guo on 2019/4/12.
//  Copyright © 2019 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 持有MXMLogger的单例
 */
@interface MXMLoggerService : NSObject

// 单例输出日志
+ (void)logMsg:(NSString *)msg;
// 打开日志
+ (void)enableLog:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END

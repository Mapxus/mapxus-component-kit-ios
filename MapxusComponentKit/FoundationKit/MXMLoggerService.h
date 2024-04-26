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
日志级别：比如DEBUG、INFO、WARN、ERROR等。
时间戳：记录日志的时间，通常精确到毫秒。
消息内容：实际的日志信息。
*/

/**
 Holding a single instance of MXMLogger
 */
@interface MXMLoggerService : NSObject

// Print log
+ (void)logMsg:(NSString *)msg;
// Log enable
+ (void)enableLog:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END

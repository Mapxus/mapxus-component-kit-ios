//
//  NSString+Compare.h
//  Phchat
//
//  Created by Chenghao Guo on 2018/7/24.
//  Copyright © 2018年 XiaoPao Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Compare)

/**
 *  判断字符串是否为空
 *
 *  @param string 检测目标字符
 *
 *  @return YES:字符串无有效值， NO:字符串有有效值
 */
+ (BOOL)isEmpty:(NSString *)string;


@end

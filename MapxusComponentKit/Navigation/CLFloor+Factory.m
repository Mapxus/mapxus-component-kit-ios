//
//  CLFloor+Factory.m
//  BeeMapDemo
//
//  Created by Chenghao Guo on 2018/12/28.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "CLFloor+Factory.h"

@implementation CLFloor (Factory)

+ (CLFloor *)createFloorWihtLevel:(NSInteger)level
{
    CLFloor *floor = [[CLFloor alloc] init];
    [floor setValue:@(level) forKey:@"level"];
    return floor;
}

@end

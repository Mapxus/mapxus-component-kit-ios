//
//  MXMMapServices+Private.h
//  MapxusMapSDK
//
//  Created by Chenghao Guo on 2018/7/16.
//  Copyright © 2018年 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <MapxusBaseSDK/MapxusBaseSDK.h>

@interface MXMMapServices ()

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *secret;

- (void)getTokenComplete:(void (^)(NSString * token))complete;

@end

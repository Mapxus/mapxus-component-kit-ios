//
//  LocalBuildingProxy.h
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/8.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapxusMapSDK/MapxusMapSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SearchResult)( MXMReverseGeoCodeSearchResult * _Nullable result, NSError * _Nullable error);

@interface LocalBuildingProxy : NSObject

- (void)searchLocalBuildingWithLocation:(CLLocation *)location completion:(SearchResult)completion;

@end

NS_ASSUME_NONNULL_END

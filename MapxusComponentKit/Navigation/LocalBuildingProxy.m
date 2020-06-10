//
//  LocalBuildingProxy.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/8.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "LocalBuildingProxy.h"


@interface LocalBuildingProxy () <MXMGeoCodeSearchDelegate>

@property (nonatomic, strong) MXMGeoCodeSearch *api;
@property (nonatomic, strong) LocalBuildingProxy *retainCycle;
@property (nonatomic, copy) SearchResult block;

@end

@implementation LocalBuildingProxy

- (MXMGeoCodeSearch *)api {
    if (!_api) {
        _api = [[MXMGeoCodeSearch alloc] init];
    }
    return _api;
}

- (void)searchLocalBuildingWithLocation:(CLLocation *)location completion:(SearchResult)completion {
    self.block = completion;
    self.retainCycle = self;
    self.api.delegate = self;
    MXMReverseGeoCodeSearchOption *opt = [[MXMReverseGeoCodeSearchOption alloc] init];
    opt.location = location.coordinate;
    CLFloor *floor = location.floor;
    if (floor) {
        opt.ordinalFloor = [NSNumber numberWithInteger:floor.level];
    }
    [self.api reverseGeoCode:opt];
}

- (void)onGetReverseGeoCode:(MXMGeoCodeSearch *)searcher result:(MXMReverseGeoCodeSearchResult *)result error:(NSError *)error {
    if (self.block) {
        self.block(result, error);
    }
    self.retainCycle = nil;
}

@end

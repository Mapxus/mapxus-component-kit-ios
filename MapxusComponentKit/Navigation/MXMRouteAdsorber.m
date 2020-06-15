//
//  MXMRouteAdsorber.m
//  MapxusComponentKit
//
//  Created by chenghao guo on 2020/6/9.
//  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

#import "MXMRouteAdsorber.h"
#import "LocalBuildingProxy.h"
#import "MXMRouteProjection.h"
#import "MXMLoggerService.h"

struct ProjectResult {
    MXMAdsorptionState state;
    CLLocation *location;
};

@interface MXMRouteAdsorber ()

@property (nonatomic, strong) MXMNavigationPathDTO *pathDTO;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong, nullable) CLLocation *previousLocation;
@property (nonatomic, strong) dispatch_queue_t subQueue;

@end

@implementation MXMRouteAdsorber

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maximumDrift = 20;
        self.numberOfAllowedDrifts = 3;
        self.subQueue = dispatch_queue_create("com.mapxus.locationQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)updateNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO {
    self.count = 0;
    self.previousLocation = nil;
    self.pathDTO = navigationPathDTO;
}

- (void)calculateTheAdsorptionLocationFromActual:(CLLocation *)actual {
    if (self.pathDTO == nil) {
        [MXMLoggerService logMsg:@"Mapxus Error: NavigationPathDTO is nil, please call `- updateNavigationPathDTO:`"];
        return ;
    }
    
    dispatch_async(self.subQueue, ^{
        LocalBuildingProxy *proxy = [[LocalBuildingProxy alloc] init];
        [proxy searchLocalBuildingWithLocation:actual completion:^(MXMReverseGeoCodeSearchResult * _Nullable result, NSError * _Nullable error) {
            NSString *buildingId = nil;
            NSString *floor = nil;
            if (result) {
                buildingId = result.building.buildingId;
                floor = result.floor.code;
            }
            NSString *key = [MXMNavigationPathDTO generateKeyUsingBuildinngId:buildingId andFloor:floor];
            struct ProjectResult final = [self calculateNewLocationWithCurrent:actual key:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTheAdsorptionLocation:buildingID:floor:state:fromActual:)]) {
                    [self.delegate refreshTheAdsorptionLocation:final.location buildingID:buildingId floor:floor state:final.state fromActual:actual];
                }
            });
        }];
    });
}

- (struct ProjectResult)calculateNewLocationWithCurrent:(CLLocation *)current key:(NSString *)key {
    struct ProjectResult result;
    CLLocation *projectLocation = [MXMRouteProjection getProjectedResultWithPathDTO:self.pathDTO userPosition:current key:key maximumDrift:self.maximumDrift];
    if (projectLocation) {
        self.count = 0;
        self.previousLocation = projectLocation;
        result.location = projectLocation;
        result.state = MXMAdsorptionStateDefault;
        return result;
    } else {
        // 如果未开始吸附，则不会重新计算路线
        if (self.previousLocation == nil) {
            result.location = current;
            result.state = MXMAdsorptionStateNotStartBinding;
            return result;
        }
        if (self.count > self.numberOfAllowedDrifts) {
            result.location = current;
            result.state = MXMAdsorptionStateDriftsNumberExceeded;
            return result;
        } else {
            self.count++;
            result.location = self.previousLocation;
            result.state = MXMAdsorptionStateDrifting;
            return result;
        }
    }
}

@end

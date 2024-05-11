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

@interface ProjectResult : NSObject
@property (nonatomic, assign) MXMAdsorptionState state;
@property (nonatomic, strong, nullable) CLLocation *location;
@property (nonatomic, strong, nullable) NSString *venueId;
@property (nonatomic, strong, nullable) NSString *buildingId;
@property (nonatomic, strong, nullable) NSString *floorId;
@property (nonatomic, strong, nullable) NSString *floorCode;
@end

@implementation ProjectResult
@end



@interface MXMRouteAdsorber ()

@property (nonatomic, strong) LocalBuildingProxy *buildingProxy;
@property (nonatomic, strong, nullable) MXMNavigationPathDTO *pathDTO;
@property (nonatomic, strong, nullable) ProjectResult *previousResult;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation MXMRouteAdsorber

- (instancetype)init {
  self = [super init];
  if (self) {
    self.maximumDrift = 20;
    self.numberOfAllowedDrifts = 3;
  }
  return self;
}

- (void)updateNavigationPathDTO:(MXMNavigationPathDTO *)navigationPathDTO {
  self.count = 0;
  self.previousResult = nil;
  self.pathDTO = navigationPathDTO;
}

- (void)calculateTheAdsorptionLocationFromActual:(CLLocation *)actual {
  if (self.pathDTO == nil) {
    [MXMLoggerService logMsg:@"Mapxus Error: NavigationPathDTO is nil, please call `- updateNavigationPathDTO:`"];
    return ;
  }
  
  [self.buildingProxy queryLocalBuildingByLocation:actual completion:^(MXMLocation *result) {
    NSString *venueId = result.venueId;
    NSString *buildingId = result.buildingId;
    NSString *floorId = result.floorId;
    NSString *floorCode = result.floorCode;
    NSString *key = [MXMNavigationPathDTO generateKeyUsingBuildingId:buildingId andFloor:floorCode];
    ProjectResult *final = [self calculateNewLocationWithCurrent:actual key:key venueId:venueId buildingId:buildingId floorId:floorId floorCode:floorCode];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTheAdsorptionLocation:venueId:buildingId:floorId:state:fromActual:)]) {
        [self.delegate refreshTheAdsorptionLocation:final.location
                                            venueId:final.venueId
                                         buildingId:final.buildingId
                                            floorId:final.floorId
                                              state:final.state
                                         fromActual:actual];
      } else if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTheAdsorptionLocation:buildingID:floor:state:fromActual:)]) {
        [self.delegate refreshTheAdsorptionLocation:final.location
                                         buildingID:final.buildingId
                                              floor:final.floorCode
                                              state:final.state
                                         fromActual:actual];
      }
    });
  }];
}

- (ProjectResult *)calculateNewLocationWithCurrent:(CLLocation *)current
                                               key:(NSString *)key
                                           venueId:(NSString *)venueId
                                        buildingId:(NSString *)buildingId
                                           floorId:(NSString *)floorId
                                         floorCode:(NSString *)floorCode {
  ProjectResult *result = [[ProjectResult alloc] init];
  CLLocation *projectLocation = [MXMRouteProjection getProjectedResultWithPathDTO:self.pathDTO userPosition:current key:key maximumDrift:self.maximumDrift];
  if (projectLocation) {
    self.count = 0;
    
    result.location = projectLocation;
    result.state = MXMAdsorptionStateDefault;
    result.venueId = venueId;
    result.buildingId = buildingId;
    result.floorId = floorId;
    result.floorCode = floorCode;
    
    self.previousResult = result;
    return result;
  } else {
    // 如果未开始吸附，则不会重新计算路线
    if (self.previousResult == nil) {
      result.location = current;
      result.state = MXMAdsorptionStateNotStartBinding;
      result.venueId = venueId;
      result.buildingId = buildingId;
      result.floorId = floorId;
      result.floorCode = floorCode;
      return result;
    }
    if (self.count > self.numberOfAllowedDrifts) {
      result.location = current;
      result.state = MXMAdsorptionStateDriftsNumberExceeded;
      result.venueId = venueId;
      result.buildingId = buildingId;
      result.floorId = floorId;
      result.floorCode = floorCode;
      return result;
    } else {
      self.count++;
      result.location = self.previousResult.location;
      result.state = MXMAdsorptionStateDrifting;
      result.venueId = self.previousResult.venueId;
      result.buildingId = self.previousResult.buildingId;
      result.floorId = self.previousResult.floorId;
      result.floorCode = self.previousResult.floorCode;
      return result;
    }
  }
}

- (LocalBuildingProxy *)buildingProxy {
  if (!_buildingProxy) {
    _buildingProxy = [[LocalBuildingProxy alloc] init];
  }
  return _buildingProxy;
}

@end

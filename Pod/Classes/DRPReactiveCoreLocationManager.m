//
//  DRPReactiveCoreLocationManager.m
//  Comment Box
//
//  Created by Jason Ederle on 9/10/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPReactiveCoreLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface DRPReactiveCoreLocationManager () <CLLocationManagerDelegate>
{
  RACReplaySubject *_locationSubject;
  RACReplaySubject *_authorizationSubject;
  CLLocationManager *_locationManager;
}

@end

@implementation DRPReactiveCoreLocationManager

+ (instancetype)sharedLocationManager
{
  static DRPReactiveCoreLocationManager *_sharedLocationManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedLocationManager = [[DRPReactiveCoreLocationManager alloc] init];
  });
  return _sharedLocationManager;
}

- (id)init
{
  self = [super init];
  if (self) {
    // setup location signal
    _locationSubject = [RACReplaySubject replaySubjectWithCapacity:1];
    [_locationSubject sendNext:nil];
    _authorizationSubject = [RACReplaySubject replaySubjectWithCapacity:1];
    
    // setup authorization signal
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    [_authorizationSubject sendNext:@(status)];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }
  return self;
}

- (void)startUpdatingLocation
{
  [_locationManager startUpdatingLocation];
  
  if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [_locationManager requestWhenInUseAuthorization];
  }
}

- (void)stopUpdatingLocation
{
  [_locationManager stopUpdatingLocation];
}

// get CLLocation when location changes
- (RACSignal *)locationChangedSignal
{
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [_locationSubject subscribe:subscriber];
    return nil;
  }];
}

// get NSNumber of current and future CLAuthorizationStatus values
- (RACSignal *)authorizationChangedSignal
{
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [_authorizationSubject subscribe:subscriber];
    return nil;
  }];
}

#pragma mark CoreLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
  [_locationSubject sendNext:locations.lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  [_authorizationSubject sendNext:@(status)];
}

@end

//
//  DRPReactiveCoreLocationManager.h
//  Comment Box
//
//  Created by Jason Ederle on 9/10/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DRPReactiveCoreLocationManager : NSObject

+ (instancetype)sharedLocationManager;

// start updating location (might prompt for permission)
- (void)startUpdatingLocation;

// stop updating location
- (void)stopUpdatingLocation;

// get CLLocation when location changes
- (RACSignal *)locationChangedSignal;

// get NSNumber of current and future CLAuthorizationStatus values
- (RACSignal *)authorizationChangedSignal;

@end

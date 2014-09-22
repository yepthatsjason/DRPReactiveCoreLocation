//
//  DRPLocationCache.h
//  Comment Box
//
//  Created by Jason Ederle on 6/14/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// common info keys
#define kLocationInfoKeyPlaces @"Places"
#define kLocationInfoKeyPlacemarks @"Placemarks"

@interface DRPLocationCache : NSObject

+ (id)sharedLocationCache;

- (NSDictionary *)getInfoForLocation:(CLLocationCoordinate2D)coord;

- (void)setInfo:(NSDictionary *)info forLocation:(CLLocationCoordinate2D)coord;

- (id<NSCoding>)getInfoValueForKey:(NSString *)key forLocation:(CLLocationCoordinate2D)coord;

- (void)save;

@end

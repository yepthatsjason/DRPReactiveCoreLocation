//
//  DRPLocationCache.m
//  Comment Box
//
//  Created by Jason Ederle on 6/14/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPLocationCache.h"
#import "DRPLogging.h"

static NSString * const kLocationCacheName = @"locations.cache";

@interface DRPLocationCache ()
{
  NSMutableDictionary *_locations;
}
@end

@implementation DRPLocationCache

+ (id)sharedLocationCache
{
  static dispatch_once_t onceToken;
  static DRPLocationCache *_cache;
  dispatch_once(&onceToken, ^{
    _cache = [[DRPLocationCache alloc] init];
  });
  return _cache;
}

- (id)init
{
  self = [super init];
  if (self) {
    _locations = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self cacheFileURL] path]];
    if (!_locations) {
      _locations = [NSMutableDictionary dictionary];
      DRPLogDebug(@"Creating new location cache");
    }
  }
  return self;
}

- (NSString *)keyForLocation:(CLLocationCoordinate2D)coord
{
  return [NSString stringWithFormat:@"lat:%f lon:%f", coord.latitude, coord.longitude];
}

- (NSDictionary *)getInfoForLocation:(CLLocationCoordinate2D)coord
{
  NSString *locationKey = [self keyForLocation:coord];
  
  DRPRequireAndReturnValue(locationKey, nil, kDRPLogError, @"Failed to create key for location");
  
  return  [_locations objectForKey:locationKey];
}

- (void)setInfo:(NSDictionary *)info forLocation:(CLLocationCoordinate2D)coord
{
  DRPRequireAndReturn(info, kDRPLogError, @"Can't set nil info for location");
  
  NSString *locationKey = [self keyForLocation:coord];
  
  DRPRequireAndReturn(locationKey, kDRPLogError, @"Failed to create key for location");

  [_locations setObject:info forKey:locationKey];
}

- (id<NSCoding>)getInfoValueForKey:(NSString *)key forLocation:(CLLocationCoordinate2D)coord
{
  DRPRequireAndReturnValue(key, nil, kDRPLogError, @"Can't fetch nil key value from info");
  
  NSString *locationKey = [self keyForLocation:coord];
  
  DRPRequireAndReturnValue(locationKey, nil, kDRPLogError, @"Failed to create key for location");
  
  NSDictionary *info = [_locations objectForKey:locationKey];
  
  if (!info) {
    return nil;
  }
  
  return [info objectForKey:key];
}

- (void)save
{
  BOOL successful = [NSKeyedArchiver archiveRootObject:_locations toFile:[[self cacheFileURL] path]];
  
  DRPRequireAndReturn(successful, kDRPLogError, @"Failed to save location cache to disk");
}

- (NSURL *)cacheFileURL
{
  NSURL *documentDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
  return [documentDirURL URLByAppendingPathComponent:kLocationCacheName isDirectory:NO];
}

@end

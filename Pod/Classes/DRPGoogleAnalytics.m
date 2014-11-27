//
//  DRPGoogleAnalytics.m
//  Comment Box
//
//  Created by Jason Ederle on 9/14/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPGoogleAnalytics.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <GoogleAnalytics-iOS-SDK/GAILogger.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import "DRPLogging.h"

static NSString * const kDefaultCategory = @"client";
static const NSInteger kDefaultDispatchInterval = 15;
static const NSInteger kMillisPerSec = 1000;

// shared singleton
DRPGoogleAnalytics *_gAnalytics = nil;

@interface DRPGoogleAnalytics ()
{
  NSMutableDictionary *_timedEvents;
  id<GAITracker> _tracker;
}
@end

@implementation DRPGoogleAnalytics

// this class is a singleton
+ (id)sharedInstance
{
  if (!_gAnalytics) {
    DRPLogError(@"You must call setupAnalytics before API is usable");
    return nil;
  }
  return _gAnalytics;
}

// this must be called once before sharedInstance can be used
+ (void)setupAnalyticsWithKey:(NSString *)key
                     logLevel:(GAILogLevel)logLevel
              trackExceptions:(BOOL)trackExceptions
                    trackIDFA:(BOOL)trackIDFA
{
  [GAI sharedInstance].trackUncaughtExceptions = trackExceptions;
  [GAI sharedInstance].dispatchInterval = kDefaultDispatchInterval;
  [[[GAI sharedInstance] logger] setLogLevel:logLevel];
  [[GAI sharedInstance] trackerWithTrackingId:key];
  [[[GAI sharedInstance] defaultTracker] setAllowIDFACollection:trackIDFA];
  
  _gAnalytics = [[DRPGoogleAnalytics alloc] init];
}

- (id)init
{
  self = [super init];
  if (self) {
    _timedEvents = [NSMutableDictionary dictionary];
    _tracker = [[GAI sharedInstance] defaultTracker];
  }
  return self;
}

- (void)logAction:(NSString *)action
         category:(NSString *)category
            label:(NSString *)label
            value:(NSNumber *)value
{
  NSDictionary *info = [[GAIDictionaryBuilder createEventWithCategory:category
                                                               action:action
                                                                label:label
                                                                value:value] build];
  [_tracker send:info];
}

- (void)logAction:(NSString *)action
{
  [self logAction:action
         category:kDefaultCategory
            label:nil
            value:nil];
}

- (void)logAction:(NSString *)action value:(NSNumber *)value
{
  [self logAction:action
         category:kDefaultCategory
            label:nil
            value:value];
}

- (void)markStart:(NSString *)action
{
  DRPRequireAndReturn(action, kDRPLogError, @"Can't start timer with nil action");
  [_timedEvents setObject:[NSDate date] forKey:action];
}

- (void)markStop:(NSString *)action
{
  [self markStop:action category:kDefaultCategory label:nil];
}

- (void)markStop:(NSString *)action category:(NSString *)category label:(NSString *)label
{
  DRPRequireAndReturn(action, kDRPLogError, @"Can't stop timer with nil action");
  
  NSDate *start = _timedEvents[action];
  
  DRPRequireAndReturn(start, kDRPLogError, @"Can't stop timer that wasn't started");
  
  NSTimeInterval timing = [[NSDate date] timeIntervalSinceDate:start] * kMillisPerSec;
  NSNumber *timingNum = [NSNumber numberWithDouble:timing];
  
  NSDictionary *info = [[GAIDictionaryBuilder createTimingWithCategory:category
                                                              interval:timingNum
                                                                  name:action
                                                                 label:label] build];
  [_tracker send:info];
  
  [_timedEvents removeObjectForKey:action];
}

- (void)clearScreenName
{
  [self setScreenName:nil];
}

- (void)setScreenName:(NSString *)screenName
{
  [_tracker set:kGAIDescription value:screenName];
  if (screenName) {
    [_tracker send:[[GAIDictionaryBuilder createScreenView] build]];
  }
}

// identify a user with an ID
- (void)setUserId:(NSString *)userId
{
  [_tracker set:kGAIUserId value:userId];
}

@end

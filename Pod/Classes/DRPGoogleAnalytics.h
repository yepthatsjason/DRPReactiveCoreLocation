//
//  DRPGoogleAnalytics.h
//  Comment Box
//
//  Created by Jason Ederle on 9/14/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>

@interface DRPGoogleAnalytics : NSObject

// this class is a singleton
+ (id)sharedInstance;

// this must be called once before sharedInstance can be used
+ (void)setupAnalyticsWithKey:(NSString *)key
                     logLevel:(GAILogLevel)logLevel
              trackExceptions:(BOOL)trackExceptions
                    trackIDFA:(BOOL)trackIDFA;

// log action
- (void)logAction:(NSString *)action
         category:(NSString *)category
            label:(NSString *)label
            value:(NSNumber *)value;

// log action with a value
- (void)logAction:(NSString *)action value:(NSNumber *)value;

// log action
- (void)logAction:(NSString *)action;

// start timed event
- (void)markStart:(NSString *)action;

// stop and log timed event
- (void)markStop:(NSString *)action;

// stop and log timed event
- (void)markStop:(NSString *)action category:(NSString *)category label:(NSString *)label;

// set the curren screen name being displayed on the tracker
- (void)setScreenName:(NSString *)screenName;

// clears the current screen name
- (void)clearScreenName;

// identify a user with an ID
- (void)setUserId:(NSString *)userId;

@end

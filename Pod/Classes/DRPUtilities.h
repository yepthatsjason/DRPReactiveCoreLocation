//
//  DRPUtilities.h
//  Comment Box
//
//  Created by Jason Ederle on 3/15/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>
#import <CoreLocation/CoreLocation.h>

// return valid string or empty string if nil
#define DRPValidStr(x) ((x) ? x : @"")

#define DRPMeteresInMile 1610
#define DRPDefaultSearchRadiusInMeteres (10 * DRPMeteresInMile) // 10 mi in meteres

// add value into dictionary if not nil
void DRPSafeSetObject(NSMutableDictionary *dict, id<NSCopying> key, id value);

// merge value from src dict into dst dict if value isn't null
void DRPMergeValueForKey(NSDictionary *srcDict, NSMutableDictionary *dstDict, id<NSCopying> srcKey, id<NSCopying> dstKey);

// Blur radius constants
extern const int DRPBlurLevelLow;
extern const int DRPBlurLevelMedium;
extern const int DRPBlurLevelHigh;

@interface DRPUtilities : NSObject

+ (MBProgressHUD *)showProgressHUDWithText:(NSString *)loadingText rootView:(UIView *)rootView;

+ (void)hideProgressHUDInRootView:(UIView *)rootView;

+ (NSString *)profilePicURLFromFacebookID:(NSString *)facebookID;

+ (NSString *)profilePicURLFromFacebookID:(NSString *)facebookID size:(NSInteger)size;

+ (void)showAlertMessage:(NSString *)message;

+ (NSURL *)getDataStorageURLForFile:(NSString *)name;

+ (NSURL *)getTempFileURLWithExtension:(NSString *)ext;

+ (NSURL *)getTempFileURL;

+ (UIImage*)imageFromView:(UIView *)aView;

+ (UIImage*)blurImage:(UIImage *)originalImage radius:(int)blurRadius;

+ (UIImage*)blurImage:(UIImage *)originalImage;

+ (UIView*)viewFromImage:(UIImage *)aImage;

+ (id)appDelegate;

+ (UILabel *)shadowLabelWithSize:(CGFloat)size color:(UIColor *)textColor;

+ (void)addShadowToView:(UIView *)view;

+ (BOOL)isDateCurrentYear:(NSDate *)date;

+ (BOOL)isDateToday:(NSDate *)date;

+ (NSDate *)beginningOfDayForDate:(NSDate *)date;

+ (NSString *)shortDateTimeString:(NSDate *)date;

+ (CGFloat)getStatusBarOffset;

+ (BOOL)isScrollViewNearBottom:(UIScrollView *)scrollView;

+ (BOOL)isDate:(NSDate *)date pastThreashold:(NSTimeInterval)threashold;

+ (NSString *)getReadableStringInMilesForMeteres:(NSInteger)meteres;

+ (NSString *)formattedFriendlyDistanceFromMeteres:(CGFloat)meteres;

+ (BOOL)isGoogleMapsInstalled;

+ (void)openLocationInAppleMaps:(CLLocation *)location;

+ (void)openLocationInGoogleMaps:(CLLocation *)location;

@end

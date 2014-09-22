//
//  DRPUtilities.m
//  Comment Box
//
//  Created by Jason Ederle on 3/15/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <GPUImage/GPUImage.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <MapKit/MapKit.h>
#import "DRPLogging.h"

const CGFloat DRPIOS7StatusBarOffset = 20;
const CGFloat DRPIOS6StatusBarOffset = 0;

const int DRPBlurLevelLow = 2;
const int DRPBlurLevelMedium = 3;
const int DRPBlurLevelHigh = 6;

static const CGFloat kInfiniteScrollRatio = .6;

static const NSInteger kDefaultFacebookProfilePicSize = 100;

static const NSInteger kSecondsInDay = 86400;
static const CGFloat kHUDMinShowTime = .5;

static const double kMeteresPerMile = 1609.34;
static const double kMeteresPerFoot = 0.3048;

static NSString * const kGoogleMapsURIPrefix = @"comgooglemaps://";

static NSString * const kDateFormatMonthDayYear = @"MMM d y";
static NSString * const kDateFormatMonthDay = @"MMM d";
static NSString * const kDateFormatDay = @"EEEE";

void DRPSafeSetObject(NSMutableDictionary *dict, id<NSCopying> key, id value)
{
  if (value) {
    [dict setObject:value forKey:key];
  }
}

void DRPMergeValueForKey(NSDictionary *srcDict, NSMutableDictionary *dstDict, id<NSCopying> srcKey, id<NSCopying> dstKey)
{
  DRPRequireAndReturn(srcKey, kDRPLogError, @"Can't merge nil key");
  dstKey = (!dstKey) ? dstKey : srcKey;
  id value = srcDict[srcKey];
  if (value) {
    dstDict[dstKey] = value;
  }
}

@implementation DRPUtilities

+ (MBProgressHUD *)showProgressHUDWithText:(NSString *)loadingText rootView:(UIView *)rootView
{
  MBProgressHUD *progressView = [[MBProgressHUD alloc] initWithView:rootView];
  progressView.labelText = loadingText;
  progressView.minShowTime = kHUDMinShowTime;
  progressView.removeFromSuperViewOnHide = YES;
  [rootView addSubview:progressView];
  [progressView show:YES];
  return progressView;
}

+ (void)hideProgressHUDInRootView:(UIView *)rootView
{
  [MBProgressHUD hideHUDForView:rootView animated:YES];
}

+ (NSString *)profilePicURLFromFacebookID:(NSString *)facebookID
{
  return [[self class] profilePicURLFromFacebookID:facebookID size:kDefaultFacebookProfilePicSize];
}

+ (NSString *)profilePicURLFromFacebookID:(NSString *)facebookID size:(NSInteger)size
{
  return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%d&height=%d&return_ssl_resources=1", facebookID, (int)size, (int)size];
}

+ (void)showAlertMessage:(NSString *)message
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh\u2026"
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil, nil];
  [alertView show];
}

+ (NSURL*)getDataStorageURLForFile:(NSString *)name
{
  NSArray *fileURLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
  NSURL *baseURL = [fileURLs firstObject];
  return [baseURL URLByAppendingPathComponent:name];
}

+ (NSURL *)getTempFileURLWithExtension:(NSString *)ext
{
  NSURL *tmpURL = [self getTempFileURL];
  return [tmpURL URLByAppendingPathExtension:ext];
}

+ (NSURL *)getTempFileURL
{
  NSURL *tmpFileURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
  return [tmpFileURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
}

+ (UIImage*)imageFromView:(UIView *)aView
{
  UIGraphicsBeginImageContext(aView.bounds.size);
  [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return viewImage;
}

+ (UIImage *)gpuImageBlur:(UIImage *)image radius:(CGFloat)radius
{
  static dispatch_once_t onceToken;
  static GPUImageiOSBlurFilter *blurFilter = nil;
  static GPUImageSaturationFilter *saturationFilter = nil;
  dispatch_once(&onceToken, ^{
    blurFilter = [[GPUImageiOSBlurFilter alloc] init];
    blurFilter.blurRadiusInPixels = radius;
    saturationFilter = [[GPUImageSaturationFilter alloc] init];
    saturationFilter.saturation = 2;
    
    [saturationFilter addTarget:blurFilter];
  });
  
  // GPU image crashes if image is empty
  DRPRequireAndReturnValue(image && image.size.width && image.size.height, nil, kDRPLogError, @"Can't blur empty image");
  
  GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
  
  DRPRequireAndReturnValue(picture, nil, kDRPLogError, @"Failed to create GPUImage");
  
  [picture addTarget:saturationFilter];
  [saturationFilter addTarget:blurFilter];
  
  UIImage *blurImage = [blurFilter imageByFilteringImage:image];
  
  return blurImage;
}

+ (UIImage*)blurImage:(UIImage *)originalImage radius:(int)blurRadius
{
  return [self gpuImageBlur:originalImage radius:blurRadius];
}

+ (UIImage*)blurImage:(UIImage *)originalImage
{
  return [self gpuImageBlur:originalImage radius:DRPBlurLevelLow];
}

+ (UIView*)viewFromImage:(UIImage *)aImage
{
  UIImageView *imageView = [[UIImageView alloc] initWithImage:aImage];
  [imageView sizeToFit];
  return imageView;
}

+ (id)appDelegate
{
  return [[UIApplication sharedApplication] delegate];
}

+ (UILabel *)shadowLabelWithSize:(CGFloat)size color:(UIColor *)textColor
{
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.font = [UIFont systemFontOfSize:size];
  label.textColor = textColor;
  
  // setup shadow
  label.layer.shadowColor = [[UIColor blackColor] CGColor];
  label.layer.shadowOffset = CGSizeMake(1, 2);
  label.layer.shadowRadius = 1.5;
  label.layer.shadowOpacity = 1;
  
  return label;
}

+ (void)addShadowToView:(UIView *)view
{
  view.layer.shadowColor = [[UIColor blackColor] CGColor];
  view.layer.shadowOffset = CGSizeMake(1, 2);
  view.layer.shadowRadius = 2;
  view.layer.shadowOpacity = .7;
}

+ (BOOL)isDateCurrentYear:(NSDate *)date
{
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
  NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
  
  if (todayComponents.year == dateComponents.year) {
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)isDateYesterday:(NSDate *)date
{
  NSDate *todayStart = [DRPUtilities beginningOfDayForDate:[NSDate date]];
  NSDate *yesterday = [NSDate dateWithTimeIntervalSince1970:todayStart.timeIntervalSince1970 - kSecondsInDay];
  NSDate *dateStart = [DRPUtilities beginningOfDayForDate:date];

  if (dateStart.timeIntervalSince1970 == yesterday.timeIntervalSince1970) {
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)isDateToday:(NSDate *)date
{
  NSDate *todayStart = [DRPUtilities beginningOfDayForDate:[NSDate date]];
  NSDate *dateStart = [DRPUtilities beginningOfDayForDate:date];
  
  if (dateStart.timeIntervalSince1970 == todayStart.timeIntervalSince1970) {
    return YES;
  } else {
    return NO;
  }
}

+ (NSDate *)beginningOfDayForDate:(NSDate *)date
{
  NSInteger seconds = (NSInteger)date.timeIntervalSince1970;
  NSTimeInterval remainder = seconds % kSecondsInDay;
  seconds -= remainder;
  return  [NSDate dateWithTimeIntervalSince1970:seconds];
}

// Returns true if date is withthin "n" days from days (in the past)
+ (BOOL)isDate:(NSDate *)date withinNumDaysOld:(int)numDaysAgo
{
  NSDate *dateStart = [DRPUtilities beginningOfDayForDate:date];
  NSDate *todayStart = [DRPUtilities beginningOfDayForDate:[NSDate date]];
  NSTimeInterval latestSeconds = todayStart.timeIntervalSince1970 - (numDaysAgo * kSecondsInDay);
  
  // if date is newer than today, then false
  if (dateStart.timeIntervalSince1970 <= todayStart.timeIntervalSince1970 &&
      dateStart.timeIntervalSince1970 >= latestSeconds)
  {
    return YES;
  } else {
    return NO;
  }
}

// Returns most optimal human friendly date string
+ (NSString *)shortDateTimeString:(NSDate *)date
{
  static NSDateFormatter *formatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    formatter = [[NSDateFormatter alloc] init];
  });
  
  if ([DRPUtilities isDateToday:date]) {
    return @"Today";
  } else if ([DRPUtilities isDateYesterday:date]) {
    return @"Yesterday";
  } else if ([DRPUtilities isDate:date withinNumDaysOld:7]) {
    [formatter setDateFormat:kDateFormatDay];
    return [formatter stringFromDate:date];
  } else if ([DRPUtilities isDateCurrentYear:date]) {
    [formatter setDateFormat:kDateFormatMonthDay];
    return [formatter stringFromDate:date];
  } else {
    [formatter setDateFormat:kDateFormatMonthDayYear];
    return [formatter stringFromDate:date];
  }
}

+ (CGFloat)getStatusBarOffset
{
  if ([[UIApplication sharedApplication] respondsToSelector:@selector(ignoreSnapshotOnNextApplicationLaunch)]) {
    return DRPIOS7StatusBarOffset;
  } else {
    return DRPIOS6StatusBarOffset;
  }
}

+ (BOOL)isScrollViewNearBottom:(UIScrollView *)scrollView
{
  
  CGFloat visibleMaxY = scrollView.contentOffset.y + scrollView.contentInset.top + CGRectGetHeight(scrollView.bounds);
  CGFloat threashold =  scrollView.contentSize.height * kInfiniteScrollRatio;
  return (int)visibleMaxY >= (int)threashold;
}

+ (BOOL)isDate:(NSDate *)date pastThreashold:(NSTimeInterval)threashold
{
  if (!date) {
    return YES;
  }
  
  NSInteger expireTime = (NSInteger)(date.timeIntervalSince1970 + threashold);
  if (expireTime <= (NSInteger)[[NSDate date] timeIntervalSince1970]) {
    return YES;
  } else {
    return NO;
  }
}

+ (NSString *)getReadableStringInMilesForMeteres:(NSInteger)meteres
{
  int miles = (int)((float)meteres / 1609.34f);
  
  return [NSString stringWithFormat:@"%d mi", miles];
}

+ (NSString *)formattedFriendlyDistanceFromMeteres:(CGFloat)meteres
{
  if ((double)meteres < (double)kMeteresPerMile) {
    CGFloat feet = meteres / kMeteresPerFoot;
    return [NSString stringWithFormat:@"%d ft", (int)feet];
  } else {
    CGFloat miles = meteres / kMeteresPerMile;
    return [NSString stringWithFormat:@"%.1f mi", miles]; // FIXME LOC - US only
  }
}

+ (BOOL)isGoogleMapsInstalled
{
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kGoogleMapsURIPrefix]];
}

+ (void)openLocationInAppleMaps:(CLLocation *)location
{
  MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
  MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
  [mapItem openInMapsWithLaunchOptions:nil];
}

+ (void)openLocationInGoogleMaps:(CLLocation *)location
{
  NSString *lat = @(location.coordinate.latitude).stringValue;
  NSString *lon = @(location.coordinate.longitude).stringValue;
  NSString *nativeMapsStringURL = [NSString stringWithFormat:@"%@?q=%@,%@&center=%@,%@&zoom=20", kGoogleMapsURIPrefix, lat, lon, lat, lon];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nativeMapsStringURL]];
}

@end

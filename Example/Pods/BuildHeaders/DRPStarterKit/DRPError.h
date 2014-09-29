//  Copyright (c) 2014 Jason Ederle. All rights reserved.

#import <UIKit/UIKit.h>

/**
 * Attention Computer Dudes..
 * Please always add new error codes to the bottom of this enum
 * so that the error codes don't get mixed up with different versions of
 * the application. Also please directly assign an error number to so it's
 * easier to figure out what error 32 means, instead of having to count 32 enum entries.
 */
typedef enum {
  kDRPErrorGeneric = -1,
  kDRPErrorNone = 0,
  kDRPErrorFailedToQueryServer = 1,
  kDRPErrorInvalidArgument = 2,
  kDRPErrorNoInternetConnection = 3,
  kDRPErrorFailedToParseServerResponse = 4,
  kDRPErrorOperationNotSupported = 5,
  kDRPErrorFailedToSaveToNetwork = 6,
  kDRPErrorFailedToCreateNewEvent = 7
} DRPErrorCode;

// create a bunch error with an error code and optional message
NSError* DRPMakeError(DRPErrorCode errorCode, NSString *format, ...);
NSError* DRPMakeErrorWithUnderlyingError(DRPErrorCode errorCode, NSError *underlyingError, NSString *format, ...);

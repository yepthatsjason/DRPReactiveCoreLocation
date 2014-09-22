//  Copyright (c) 2014 Jason Ederle. All rights reserved.

#import "DRPError.h"

NSError* DRPMakeErrorWithUnderlyingErrorAndArgs(DRPErrorCode errorCode, NSError *underlyingError, NSString *format, va_list args)
{
  NSError *error = nil;
  NSMutableDictionary *info = [NSMutableDictionary dictionary];
  NSString *errorMsg;

  if (format) {
    errorMsg = [[NSString alloc] initWithFormat:format arguments:args];
    [info setObject:errorMsg forKey:NSLocalizedDescriptionKey];
  }
  
  if (underlyingError) {
    [info setObject:underlyingError forKey:NSUnderlyingErrorKey];
  }

  error = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:errorCode userInfo:info];

  return error;
}

// create a bunch error with an error code and optional message
NSError* DRPMakeError(DRPErrorCode errorCode, NSString *format, ...)
{
  NSError *error = nil;
  va_list args;
  va_start(args, format);
  
  error = DRPMakeErrorWithUnderlyingErrorAndArgs(errorCode, nil, format, args);
  
  va_end(args);
  return error;
}

NSError* DRPMakeErrorWithUnderlyingError(DRPErrorCode errorCode, NSError *underlyingError, NSString *format, ...)
{
  NSError *error = nil;
  va_list args;
  va_start(args, format);
  
  error = DRPMakeErrorWithUnderlyingErrorAndArgs(errorCode, underlyingError, format, args);
  
  va_end(args);
  return error;
}

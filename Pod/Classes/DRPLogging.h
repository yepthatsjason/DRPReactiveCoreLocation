//  Copyright (c) 2014 Jason Ederle. All rights reserved.

#import <AssertMacros.h>
#import <Foundation/Foundation.h>

typedef enum {
  kDRPLogNone = -1,      // no logging
  kDRPLogError,          // big problem
  kDRPLogWarning,        // little problem
  kDRPLogInfo,           // interesting situation
  kDRPLogDebug           // trying to find problem
} DRPLogLevel;

// log a message with a logging level
void DRPLog(DRPLogLevel logLevel, NSString *format, ...);

// set log level
void DRPLogLevelSet(DRPLogLevel newLevel);

// handy shorthand macros for logging
#define DRPLogDebug(msg...) DRPLog(kDRPLogDebug, msg)
#define DRPLogInfo(msg...) DRPLog(kDRPLogInfo, msg)
#define DRPLogWarning(msg...) DRPLog(kDRPLogWarning, msg)
#define DRPLogError(msg...) DRPLog(kDRPLogError, msg)

// require a condition be true else return
#define DRPRequireAndReturn(cond, level, msg...) \
do { \
  if(!(cond)) { \
    DRPLog(level, msg); \
    return; \
  } \
} while (0)

// require a condition be true else return and log message
#define DRPRequireAndReturnValue(cond, retVal, level, msg...) \
do { \
  if(!(cond)) { \
    DRPLog(level, msg); \
    return retVal; \
  } \
} while (0)

#define DRPAssert(cond, msg...) \
do { \
  if(!(cond)) { \
    NSString *assertionMsg = [NSString stringWithFormat:@"Failed Assertion, %s:%u: %@", __FILE__, __LINE__, msg]; \
    DRPLogError(assertionMsg); \
    assert([assertionMsg cStringUsingEncoding:NSUTF8StringEncoding]); \
  } \
} while (0)

#define DRPFailAssert(msg...) DRPAssert(NO, msg)

#define DRPRequireAndReturnNil(cond, msg...) DRPRequireAndReturnValue(cond, nil, kDRPLogError, msg)
#define DRPFailRequireAndReturnNil(msg...) DRPRequireAndReturnValue(NO, nil, kDRPLogError, msg)

// assert if we're not on the main thread
#define DRPAssertIsMainThread() DRPAssert([NSThread isMainThread], @"You must be on the main thread")

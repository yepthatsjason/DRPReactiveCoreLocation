//  Copyright (c) 2014 Jason Ederle. All rights reserved.

#import "DRPLogging.h"

// current log level
static DRPLogLevel _currentLogLevel = kDRPLogDebug;

// get string of log level
static NSString* _DRPLogLevelToString(DRPLogLevel level)
{
  if (level == kDRPLogDebug) {
    return @"DEBUG";
  } else if (level == kDRPLogInfo) {
    return @"INFO";
  } else if (level == kDRPLogWarning) {
    return @"WARNING";
  } else if (level == kDRPLogError) {
    return @"ERROR";
  } else  if (level == kDRPLogNone) {
    return @"NONE";
  } else {
    return @"UNKNOWN";
  }
}

// log a message if it's within the current log level
static void _DRPLogString(DRPLogLevel logLevel, NSString *msg)
{
  if (logLevel != kDRPLogNone && logLevel <= _currentLogLevel) {
    NSLog(@"%@ - %@", _DRPLogLevelToString(logLevel), msg);
  }
}

// log a message
void DRPLog(DRPLogLevel logLevel, NSString *format, ...)
{
  va_list args;
  va_start(args, format);
  
  _DRPLogString(logLevel, [[NSString alloc] initWithFormat:format arguments:args]);
  
  va_end(args);
}

// set log level
void DRPLogLevelSet(DRPLogLevel newLevel)
{
  _currentLogLevel = newLevel;
}


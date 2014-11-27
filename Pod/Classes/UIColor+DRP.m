//
//  UIColor+DRP.m
//  Pods
//
//  Created by Jason Ederle on 11/27/14.
//
//

#import "UIColor+DRP.h"

@implementation UIColor (DRP)

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
  const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
  UInt32 x = (UInt32)strtol(cStr+1, NULL, 16);
  return [UIColor colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
  unsigned char r, g, b;
  b = col & 0xFF;
  g = (col >> 8) & 0xFF;
  r = (col >> 16) & 0xFF;
  return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end

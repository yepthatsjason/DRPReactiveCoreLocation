//
//  DRPGradiantView.m
//  Comment Box
//
//  Created by Jason Ederle on 4/16/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPGradiantView.h"

@implementation DRPGradiantView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.userInteractionEnabled = NO;
      _endColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
      _startColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL)isOpaque
{
  return NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  NSArray *colors = @[(id)[_startColor CGColor], (id)[_endColor CGColor]];
  const CGFloat locations[] = {0, 1};
  
  // fill clear first
  [[UIColor clearColor] set];
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
  [path fill];
  
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
  CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
                              gradient,
                              CGPointMake(0, 0),
                              CGPointMake(0, self.bounds.size.height),
                              kCGGradientDrawsAfterEndLocation);
  
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);
}

@end

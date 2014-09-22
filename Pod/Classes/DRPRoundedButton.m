//
//  DRPRoundedButton.m
//  Comment Box
//
//  Created by Jason Ederle on 9/13/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPRoundedButton.h"

@implementation DRPRoundedButton

- (id)init
{
  self = [super init];
  if (self) {
    _backgroundColor = [UIColor blueColor];
    self.clipsToBounds = YES;
  }
  return self;
}

- (void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  self.layer.cornerRadius = ceilf(CGRectGetHeight(self.frame) / 2);
}

- (void)setHighlighted:(BOOL)highlighted
{
  [super setHighlighted:highlighted];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  CGFloat cornerRadius = ceilf(CGRectGetHeight(self.bounds) / 2);
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
  
  if (self.highlighted) {
    [[_backgroundColor colorWithAlphaComponent:.8] setFill];
  } else {
    [_backgroundColor setFill];
  }
  
  [path fill];
}

@end

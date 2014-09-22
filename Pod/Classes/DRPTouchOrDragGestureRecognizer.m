//
//  DRPTouchOrDragGestureRecognizer.m
//  Comment Box
//
//  Created by Jason Ederle on 8/2/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPTouchOrDragGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation DRPTouchOrDragGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
  self = [super initWithTarget:target action:action];
  if (self) {
    self.cancelsTouchesInView = NO;
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.state == UIGestureRecognizerStatePossible) {
    self.state = UIGestureRecognizerStateRecognized;
  } else {
    self.state = UIGestureRecognizerStateFailed;
  }
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
  return NO;
}

@end

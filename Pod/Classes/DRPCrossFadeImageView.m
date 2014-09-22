//
//  DRPCrossFadeImageView.m
//  Comment Box
//
//  Created by Jason Ederle on 5/4/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPCrossFadeImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <DRPLogging.h>

static const CGFloat DRPDefaultCrossFadeDuration = .4;
static const NSTimeInterval DRPFadeThreashold = .1;

@interface DRPCrossFadeImageView() {
  UIImageView *_contentImageView;
  NSDate *_dateImageCleared;
}
@end

@implementation DRPCrossFadeImageView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _crossFadeDuration = DRPDefaultCrossFadeDuration;
    self.backgroundColor = [UIColor lightGrayColor];
    _contentImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _contentImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_contentImageView];
  }
  return self;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
  [super setContentMode:contentMode];
  _contentImageView.contentMode = contentMode;
}

- (BOOL)isImage:(UIImage *)image1 equalToImage:(UIImage *)image2
{
  if (!image1 || !image2) {
    return NO;
  }
  
  if (image1 == image2) {
    return YES;
  } else {
    return NO;
  }
}

- (UIImage *)image
{
  return _contentImageView.image;
}

- (void)setImage:(UIImage *)newImage
{
  if (newImage == _contentImageView.image) {
    if (!newImage) {
      _dateImageCleared = [NSDate date];
    }
    return;
  }
  
  BOOL isReadyForTransition = NO;
  
  if (newImage) {
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeDiff = nowTime - _dateImageCleared.timeIntervalSince1970;
    
    // if the image data arrives really quickly just set it immediately
    if (_contentImageView.image == nil && timeDiff > DRPFadeThreashold) {
      isReadyForTransition = YES;
    }
  } else {
    _dateImageCleared = [NSDate date];
  }

  if (isReadyForTransition) {
    if (_contentImageView.image) {
      NSLog(@"BUG -- why are we cross fading between images?!?!");
    }
    [self _setImageWithCrossFade:newImage];
  } else {
    [self _setImageWithoutCrossFade:newImage];
  }
  
  [_contentImageView setNeedsDisplay];
  [self setNeedsDisplay];
}

- (void)_setImageWithCrossFade:(UIImage *)newImage
{
  DRPAssertIsMainThread();
  
  _contentImageView.image = newImage;
  _contentImageView.alpha = 0;
  [UIView animateWithDuration:_crossFadeDuration animations:^{
    _contentImageView.alpha = 1;
  }];
}

- (void)_setImageWithoutCrossFade:(UIImage *)image
{
  _contentImageView.image = image;
  _contentImageView.alpha = image ? 1 : 0;
  [_contentImageView setNeedsDisplay];
}

@end

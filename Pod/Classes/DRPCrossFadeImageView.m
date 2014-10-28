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
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>

static const CGFloat DRPDefaultCrossFadeDuration = .4;

@interface DRPCrossFadeImageView() {
  UIImageView *_contentImageView;
  NSString *_currentImageKey;
  id<SDWebImageOperation> _downloadOperation;
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
    _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_contentImageView];
  }
  return self;
}

- (void)setImageWithURL:(NSURL *)url;
{
  NSString *cacheKey = nil;
  
  if (url) {
    cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
  }
  
  // check if we're already showing this image
  if (([cacheKey isEqualToString:_currentImageKey]) ||
      (!cacheKey && !_currentImageKey))
  {
    return;
  }

  // cancel and pending downloads
  if (_downloadOperation) {
    [_downloadOperation cancel];
    _downloadOperation = nil;
  }
  
  _currentImageKey = cacheKey;
  
  // if nil just clear the image
  if (!cacheKey) {
    [self _setImageWithoutCrossFade:nil];
    [_contentImageView setNeedsDisplay];
    [self setNeedsDisplay];
    return;
  }
  
  [[[SDWebImageManager sharedManager] imageCache] queryDiskCacheForKey:cacheKey done:^(UIImage *image, SDImageCacheType cacheType) {
    if (image) {
      [self _setImageWithoutCrossFade:image];
    } else {
      [self _downloadImage:url crossfade:YES];
    }
  }];
}

- (void)_downloadImage:(NSURL *)url crossfade:(BOOL)crossfade
{
  SDWebImageCompletionWithFinishedBlock completion =
  ^(UIImage *downloadedImage, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
  {
    if (!finished) {
      return;
    }
    
    if (crossfade) {
      [self _setImageWithCrossFade:downloadedImage];
    } else {
      [self _setImageWithoutCrossFade:downloadedImage];
    }
    _downloadOperation = nil;
  };
  
  [self _setImageWithoutCrossFade:nil];
  [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                  options:0
                                                 progress:nil
                                                completed:completion];
}

- (void)_setImageWithCrossFade:(UIImage *)newImage
{
  DRPAssertIsMainThread();
  
  UIImage *processedImage = newImage;
  if (_processingBlock) {
    processedImage = _processingBlock(newImage);
  }
  
  _contentImageView.image = processedImage;
  _contentImageView.alpha = 0;
  [UIView animateWithDuration:_crossFadeDuration animations:^{
    _contentImageView.alpha = 1;
  }];
}

- (void)_setImageWithoutCrossFade:(UIImage *)newImage
{
  UIImage *processedImage = newImage;
  if (_processingBlock) {
    processedImage = _processingBlock(newImage);
  }
  
  _contentImageView.image = processedImage;
  _contentImageView.alpha = processedImage ? 1 : 0;
  [_contentImageView setNeedsDisplay];
}

- (UIImageView *)contentImageView
{
  return _contentImageView;
}

@end

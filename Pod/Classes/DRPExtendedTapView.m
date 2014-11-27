//
//  DRPExtendedTapView.m
//  Atmosphere
//
//  Created by Jason Ederle on 10/18/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPExtendedTapView.h"
#import "DRPLogging.h"

@interface DRPExtendedTapView ()
{
  UIView *_extendedDebugView;
}
@end

@implementation DRPExtendedTapView

- (instancetype)initWithContentView:(UIView *)contentView extendedEdges:(UIEdgeInsets)extension
{
  DRPRequireAndReturnValue(contentView, nil, kDRPLogError, @"extend nil view");
  DRPRequireAndReturnValue(extension.top >= 0
                           && extension.left >= 0
                           && extension.bottom >= 0
                           && extension.right >= 0, nil, kDRPLogError, @"can't have negative extension");
  
  self = [super initWithFrame:contentView.bounds];
  if (self) {
    _contentView = contentView;
    _extensions = extension;
    _contentViewSize = _contentView.bounds.size;
    [self addSubview:contentView];
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (BOOL)isOpaque
{
  return NO;
}

- (void)setContentViewSize:(CGSize)contentViewSize
{
  _contentViewSize = contentViewSize;
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  _extendedDebugView.frame = [self extendedRect];
  _contentView.frame = CGRectMake(0,
                                  0,
                                  _contentViewSize.width,
                                  _contentViewSize.height);
}

- (void)setShowExtendedRegion:(BOOL)showExtendedRegion
{
  if (showExtendedRegion) {
    _extendedDebugView = [[UIView alloc] initWithFrame:[self extendedRect]];
    _extendedDebugView.backgroundColor = [UIColor redColor];
    [self insertSubview:_extendedDebugView belowSubview:_contentView];
  } else {
    [_extendedDebugView removeFromSuperview];
  }
}

- (CGRect)extendedRect
{
  CGRect contentFrame = [_contentView convertRect:_contentView.frame toView:self];
  CGRect tapRect = CGRectMake(CGRectGetMinX(contentFrame) - _extensions.left,
                              CGRectGetMinY(contentFrame) - _extensions.top,
                              CGRectGetWidth(contentFrame) + _extensions.left + _extensions.right,
                              CGRectGetHeight(contentFrame) + _extensions.top + _extensions.bottom);
  return tapRect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  CGRect tapRect = [self extendedRect];
  
  // test if the point falls into our extended tap region
  if (point.x >= CGRectGetMinX(tapRect) && point.x <= CGRectGetMaxX(tapRect) &&
      point.y >= CGRectGetMinY(tapRect) && point.y <= CGRectGetMaxY(tapRect))
  {
    return _contentView;
  }
  return nil;
}

@end

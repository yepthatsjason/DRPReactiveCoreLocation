//
//  DRPWrapperCollectionViewCell.m
//  Comment Box
//
//  Created by Jason Ederle on 4/26/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPWrapperCollectionViewCell.h"

@implementation DRPWrapperCollectionViewCell

- (id)initWithView:(UIView *)wrappedView frame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _wrappedView = wrappedView;
    self.clipsToBounds = YES;
  }
  return self;
}

- (void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  _wrappedView.frame = self.bounds;
}

- (void)setWrappedView:(UIView *)wrappedView
{
  if (_wrappedView) {
    [_wrappedView removeFromSuperview];
    _wrappedView = nil;
  }
  
  _wrappedView = wrappedView;
  
  if (wrappedView) {
    _wrappedView.frame = self.contentView.bounds;
    [self.contentView addSubview:_wrappedView];
  }
}

@end

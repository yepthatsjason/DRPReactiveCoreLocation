//
//  DRPEmptyView.m
//  Comment Box
//
//  Created by Jason Ederle on 8/17/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPTableStateView.h"

static const UIEdgeInsets kInsets = {10, 10, 10, 10};
static const CGFloat kImageVerticalPadding = 20;

@implementation DRPTableStateView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageLabel.textColor = [UIColor colorWithRed:.46 green:.49 blue:.55 alpha:1];
    _messageLabel.font = [UIFont systemFontOfSize:18];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_messageLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize messageSize = [_messageLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds) - kInsets.left - kInsets.right, CGFLOAT_MAX)];
  CGSize imageSize = _imageView.image ? _imageView.image.size : CGSizeZero;
  
  _messageLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - messageSize.width) / 2,
                                   (CGRectGetHeight(self.bounds) - messageSize.height - imageSize.height - kImageVerticalPadding) / 2,
                                   messageSize.width,
                                   messageSize.height);
  
  _imageView.frame = CGRectMake((CGRectGetWidth(self.bounds) - imageSize.width) / 2,
                                CGRectGetMaxY(_messageLabel.frame) + kImageVerticalPadding,
                                imageSize.width,
                                imageSize.height);
}

@end

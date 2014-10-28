//
//  DRPCrossFadeImageView.h
//  Comment Box
//
//  Created by Jason Ederle on 5/4/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIImage* (^DRPCrossFadeProcessingBlock)(UIImage * rawImage);

@interface DRPCrossFadeImageView : UIView
@property (readwrite) CGFloat crossFadeDuration;
@property (copy, nonatomic) DRPCrossFadeProcessingBlock processingBlock;

// this is integrated with SDWebImage to download the URL and crossfade we if image isn't cached
- (void)setImageWithURL:(NSURL *)url;

@end

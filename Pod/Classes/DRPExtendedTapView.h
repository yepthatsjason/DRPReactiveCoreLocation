//
//  DRPExtendedTapView.h
//  Atmosphere
//
//  Created by Jason Ederle on 10/18/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This class wraps a view to extend it's touchable area by forwarding events onto
 * the contentView if the tap falls within the extensions spedific from it's existing contentSize
 */
@interface DRPExtendedTapView : UIView
@property (readonly, nonatomic) UIView *contentView;
@property (nonatomic) CGSize contentViewSize;
@property (readonly, nonatomic) UIEdgeInsets extensions;
@property (nonatomic) BOOL showExtendedRegion; // useful for debugging or tuning tap regions

// wraps contentView and sets contentViewSize from it's current bounds size, extending taps additional extension distance
- (instancetype)initWithContentView:(UIView *)contentView extendedEdges:(UIEdgeInsets)extension;

@end

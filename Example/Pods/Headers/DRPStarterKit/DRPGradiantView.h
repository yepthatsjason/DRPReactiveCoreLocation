//
//  DRPGradiantView.h
//  Comment Box
//
//  Created by Jason Ederle on 4/16/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRPGradiantView : UIView

// start color is lowest y-value color (defaults to clear)
@property (strong, nonatomic) UIColor *startColor;

// end color is highest y-value color (defaults to black)
@property (strong, nonatomic) UIColor *endColor;

@end

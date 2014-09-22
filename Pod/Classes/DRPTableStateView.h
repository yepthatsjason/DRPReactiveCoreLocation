//
//  DRPEmptyView.h
//  Comment Box
//
//  Created by Jason Ederle on 8/17/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

// View used by UITableView+Loading for state messages
@interface DRPTableStateView : UIView
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIImageView *imageView;
@end

//
//  DRPParallaxTableViewController.h
//  Comment Box
//
//  Created by Jason Ederle on 5/10/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPViewBackedTableViewController.h"

@interface DRPParallaxTableViewController : UITableViewController <UITableViewDelegate>
@property (strong, nonatomic) UIView *headerView;
@property (nonatomic) CGFloat headerHeight;

@end

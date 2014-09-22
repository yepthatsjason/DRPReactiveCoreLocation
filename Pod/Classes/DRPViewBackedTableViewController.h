//
//  DRPViewBackedTableViewController.h
//  Comment Box
//
//  Created by Jason Ederle on 6/5/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Class wraps the UITableView with a top level view container for adding other subviews
 * without them being inside the scroll view.
 */
@interface DRPViewBackedTableViewController : UITableViewController
@property (readonly, nonatomic) UIView *rootView;
@end

//
//  DRPViewBackedTableViewController.m
//  Comment Box
//
//  Created by Jason Ederle on 6/5/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPViewBackedTableViewController.h"

@implementation DRPViewBackedTableViewController

// wrap the table view with a root view handle for HUD's or other root controls
- (void)loadView
{
  [super loadView];
  
  UITableView *originalTableView = self.tableView;

  _rootView = [[UIView alloc] initWithFrame:self.view.frame];
  _rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  originalTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  originalTableView.delegate = self;
  originalTableView.dataSource = self;
  
  [_rootView addSubview:self.tableView];
  
  self.view = _rootView;
  self.tableView = originalTableView;
}

@end

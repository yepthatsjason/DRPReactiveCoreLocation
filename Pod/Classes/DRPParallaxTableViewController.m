//
//  DRPParallaxTableViewController.m
//  Comment Box
//
//  Created by Jason Ederle on 5/10/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPParallaxTableViewController.h"

static CGFloat DRPDefaultHeaderHeight = 150;

@implementation DRPParallaxTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    _headerHeight = DRPDefaultHeaderHeight;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.automaticallyAdjustsScrollViewInsets = NO;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.delegate = self;
}

- (void)setHeaderView:(UIView *)headerView
{
  if (_headerView) {
    [_headerView removeFromSuperview];
  }
  
  _headerView = headerView;
  
  if (_headerView) {
    [self.tableView addSubview:_headerView];
  }
  
  [self updateHeaderContentInsets];
  [_headerView setNeedsLayout];
}

- (void)updateHeaderContentInsets
{
  if (_headerView) {
    _headerView.frame = CGRectMake(0,
                                   -_headerHeight,
                                   CGRectGetWidth(self.tableView.bounds),
                                   _headerHeight);
    self.tableView.contentOffset = CGPointMake(0, -_headerHeight);
    UIEdgeInsets insets = UIEdgeInsetsMake(self.headerHeight, 0, 0, 0);
    self.tableView.contentInset = insets;
    [_headerView setNeedsLayout];
  } else {
    self.tableView.contentInset = UIEdgeInsetsZero;
  }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
  double adj = _headerHeight - headerHeight;
  
  // if the header get's smaller, we move the scroll position up to avoid jitter
  if (_headerHeight && adj < 0) {
    CGPoint contentOffset = self.tableView.contentOffset;
    self.tableView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + adj);
  }
  
  _headerHeight = headerHeight;
  [self updateHeaderContentInsets];
  

  [self.tableView setNeedsLayout];
  [self scrollViewDidScroll:self.tableView];
}

#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat yOffset  = scrollView.contentOffset.y;
  if (yOffset < -_headerHeight) {
    CGRect f = _headerView.frame;
    f.origin.y = yOffset;
    f.size.height =  -yOffset;
    _headerView.frame = f;
  }
}

@end

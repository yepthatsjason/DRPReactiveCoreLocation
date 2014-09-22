//
//  UITableView+Loading.m
//  Comment Box
//
//  Created by Jason Ederle on 8/17/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "UITableView+Loading.h"
#import <objc/runtime.h>

#import "DRPTableStateView.h"
#import "DRPLoadingFooterView.h"
#import "DRPLogging.h"

static const CGFloat kDefaultLoadingViewHeight = 40;

static char kViewStateDictKey;
static char kViewStateKey;

static NSString * const kViewStateDefaultErrorMessage = @"Oops, we had trouble loading that";
static NSString * const kViewStateDefaultEmptyMessage = @"Nothing to show";
static NSString * const kViewStateDefaultAccessDeniedMessage = @"Permission denied for resource";

typedef NS_ENUM(NSInteger, UITableViewStateAttribute)
{
  UITableVIewStateAttributeUnknown = -1,
  UITableViewStateAttributeMessage,
  UITableViewStateAttributeImage,
  UITableViewStateAttributeView,
  UITableViewStateAttributeSeperatorStyle
};

@implementation UITableView (Loading)

- (void)setViewState:(UITableViewState)viewState
{
  if (viewState == [self viewState]) {
    return;
  }
  
  if (viewState == UITableViewStateContent) {
    [self _showViewForState:UITableViewStateLoading show:NO];
    [self _showViewForState:UITableViewStateError show:NO];
    [self _showViewForState:UITableViewStateEmpty show:NO];
    [self _showViewForState:UITableViewStateAccessDenied show:NO];
  } else if (viewState == UITableViewStateLoading) {
    [self _showViewForState:UITableViewStateError show:NO];
    [self _showViewForState:UITableViewStateEmpty show:NO];
    [self _showViewForState:UITableViewStateAccessDenied show:NO];
    [self _showViewForState:UITableViewStateLoading show:YES];
  } else if (viewState == UITableViewStateError) {
    [self _showViewForState:UITableViewStateEmpty show:NO];
    [self _showViewForState:UITableViewStateAccessDenied show:NO];
    [self _showViewForState:UITableViewStateLoading show:NO];
    [self _showViewForState:UITableViewStateError show:YES];
  } else if (viewState == UITableViewStateEmpty) {
    [self _showViewForState:UITableViewStateAccessDenied show:NO];
    [self _showViewForState:UITableViewStateLoading show:NO];
    [self _showViewForState:UITableViewStateError show:NO];
    [self _showViewForState:UITableViewStateEmpty show:YES];
  } else if (viewState == UITableViewStateAccessDenied) {
    [self _showViewForState:UITableViewStateLoading show:NO];
    [self _showViewForState:UITableViewStateError show:NO];
    [self _showViewForState:UITableViewStateEmpty show:NO];
    [self _showViewForState:UITableViewStateAccessDenied show:YES];
  } else {
    DRPLogError(@"Can't change view state to unknown value: %d", (int)viewState);
    return;
  }
  
  objc_setAssociatedObject(self, &kViewStateKey, @(viewState), OBJC_ASSOCIATION_RETAIN);
  
  self.separatorStyle = [self getCellSeperatorStyleForState:viewState];

  [self setNeedsLayout];
}

// get current view state
- (UITableViewState)viewState
{
  NSNumber *viewStateNum = objc_getAssociatedObject(self, &kViewStateKey);
  if (!viewStateNum) {
    return UITableViewStateContent;
  }
  return (UITableViewState)viewStateNum.integerValue;
}

- (void)_showViewForState:(UITableViewState)state show:(BOOL)shouldShow
{
  // infinite loading is a little different
  if (state == UITableViewStateLoading) {
    if (shouldShow) {
      UIView *loadingView = [self _getValueForState:UITableViewStateLoading attribute:UITableViewStateAttributeView];
      self.tableFooterView = loadingView;
    } else {
      self.tableFooterView = nil;
      // when removing, we slide the content down to offset the removed loading view to avoid change in position
      if (((double)self.contentOffset.y + self.contentInset.top) != 0) {
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + kDefaultLoadingViewHeight);
      }
    }
  } else {
    // all other state views just set the background
    if (shouldShow) {
      DRPTableStateView *view = [self _getValueForState:state attribute:UITableViewStateAttributeView];
      self.backgroundView = view;
    } else {
      self.backgroundView = nil;
    }
  }
  
  [self setNeedsDisplay];
}

// set a custom view a state
- (void)setCustomView:(UIView *)view forState:(UITableViewState)state
{
  [self _setValue:view forState:state attribute:UITableViewStateAttributeView];
}

- (void)configureViewState:(UITableViewState)state
                   message:(NSString *)message
                     image:(UIImage *)image;
{
  [self _setValue:message forState:state attribute:UITableViewStateAttributeMessage];
  [self _setValue:image forState:state attribute:UITableViewStateAttributeImage];
  
  // clear view so it's rebuilt with new values
  [self _setValue:nil forState:state attribute:UITableViewStateAttributeView];
}

// set cell seperator style when in state. Defaults to UITableViewCellSeparatorStyleNone.
- (void)setCellSeperatorStyle:(UITableViewCellSeparatorStyle)style forState:(UITableViewState)state
{
  [self _setValue:@(style) forState:state attribute:UITableViewStateAttributeSeperatorStyle];
}

- (UITableViewCellSeparatorStyle)getCellSeperatorStyleForState:(UITableViewState)state
{
  // footer loading uses content cell seperator since it's inline
  state = (state == UITableViewStateLoading) ? UITableViewStateContent : state;
  
  NSNumber *styleNum = [self _getValueForState:state attribute:UITableViewStateAttributeSeperatorStyle];
  if (!styleNum) {
    return UITableViewCellSeparatorStyleNone;
  } else {
    return (UITableViewCellSeparatorStyle)styleNum.intValue;
  }
}

#pragma mark Default View States

- (NSString *)_getDefaultMessageForState:(UITableViewState)state
{
  if (state == UITableViewStateEmpty) {
    return kViewStateDefaultEmptyMessage;
  } else if (state == UITableViewStateError) {
    return kViewStateDefaultErrorMessage;
  } else if (state == UITableViewStateAccessDenied) {
    return kViewStateDefaultAccessDeniedMessage;
  } else {
    return nil;
  }
}

- (UIView *)_getDefaultViewForState:(UITableViewState)state
{
  // loading view is a different default style
  if (state == UITableViewStateLoading) {
    DRPLoadingFooterView *loadingView = [self _defaultLoadingView];
    return loadingView;
  }
  
  DRPTableStateView *view = [[DRPTableStateView alloc] initWithFrame:self.bounds];
  view.messageLabel.text = [self _getValueForState:state attribute:UITableViewStateAttributeMessage];
  view.imageView.image = [self _getValueForState:state attribute:UITableViewStateAttributeImage];

  return view;
}

// get a simple loading view
- (DRPLoadingFooterView *)_defaultLoadingView
{
  DRPLoadingFooterView *loadingView = [[DRPLoadingFooterView alloc] initWithFrame:CGRectMake(0,
                                                                                             0,
                                                                                             CGRectGetWidth(self.bounds),
                                                                                             kDefaultLoadingViewHeight)];
  loadingView.showTopSeperator = NO;
  loadingView.showBottomSeperator = NO;
  loadingView.backgroundColor = [UIColor clearColor];
  [loadingView animateActivitySpinner:YES];
  return loadingView;
}

#pragma mark Customize default state views

- (void)_setValue:(id)value forState:(UITableViewState)state attribute:(UITableViewStateAttribute)attribute
{
  NSString *key = [self _getKeyForState:state attribute:attribute];
  if (value) {
    [[self _getViewStateDictionary] setObject:value forKey:key];
  } else {
    [[self _getViewStateDictionary] removeObjectForKey:key];
  }
}

- (id)_getValueForState:(UITableViewState)state attribute:(UITableViewStateAttribute)attribute
{
  NSString *key = [self _getKeyForState:state attribute:attribute];
  id value = [[self _getViewStateDictionary] objectForKey:key];

  // some attributes have default values
  if (!value) {
    if (attribute == UITableViewStateAttributeMessage) {
      value = [self _getDefaultMessageForState:state];
    } else if (attribute == UITableViewStateAttributeView) {
      value = [self _getDefaultViewForState:state];
      // cache this value for next time
      if (value) {
        [self _setValue:value forState:state attribute:attribute];
      }
    }
  }
  return value;
}

- (NSMutableDictionary *)_getViewStateDictionary
{
  NSMutableDictionary *info = objc_getAssociatedObject(self, &kViewStateDictKey);
  if (!info) {
    info = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &kViewStateDictKey, info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return info;
}

- (NSString *)_getKeyForState:(UITableViewState)state attribute:(UITableViewStateAttribute)attribute
{
  return [NSString stringWithFormat:@"%d_%d", (int)state, (int)attribute];
}

@end

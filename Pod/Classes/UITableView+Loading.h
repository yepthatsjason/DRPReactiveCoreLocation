//
//  UITableView+Loading.h
//  Comment Box
//
//  Created by Jason Ederle on 8/17/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UITableViewState) {
  UITableViewStateUnknown = -1,
  UITableViewStateContent,
  UITableViewStateLoading,
  UITableViewStateError,
  UITableViewStateEmpty,
  UITableViewStateAccessDenied,  // used for location, camera roll, etc.
};

/**
 * This category adds support for a viewState enum that can change
 * the state of the table to show loading indicators, error views, 
 * and empty views. The default versions of the loading view is a
 * simple sipinner in the footer of the view. The default for the
 * error and empty views is a title message with an image.
 */
@interface UITableView (Loading)

// change view state
- (void)setViewState:(UITableViewState)viewState;

// get current view state
- (UITableViewState)viewState;

// set a custom view a state
- (void)setCustomView:(UIView *)view forState:(UITableViewState)state;

// set cell seperator style when in state. Defaults to UITableViewCellSeparatorStyleNone.
- (void)setCellSeperatorStyle:(UITableViewCellSeparatorStyle)style forState:(UITableViewState)state;

// customize one of the generic DRPTableViewState views
- (void)configureViewState:(UITableViewState)state
                   message:(NSString *)message
                     image:(UIImage *)image;

@end

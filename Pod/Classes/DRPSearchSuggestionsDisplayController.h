//
//  DRPSearchDisplayController.h
//  Comment Box
//
//  Created by Jason Ederle on 8/2/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DRPSearchDisplayControllerDelegate;

@interface DRPSearchSuggestionsDisplayController : NSObject
@property (weak, nonatomic) id<DRPSearchDisplayControllerDelegate> delegate;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIView *resultsView;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL resultsViewVisible;
@property (strong, nonatomic) UIColor *statusBarColor;

- (id)initWithSearchBar:(UISearchBar *)searchBar viewController:(UIViewController *)viewController;

// hide navigation bar and show search results view
- (void)setActive:(BOOL)active;

@end

@protocol DRPSearchDisplayControllerDelegate <NSObject>
@optional
- (void)willShowResultsViewForSearchDisplayController:(DRPSearchSuggestionsDisplayController *)controller;
@end

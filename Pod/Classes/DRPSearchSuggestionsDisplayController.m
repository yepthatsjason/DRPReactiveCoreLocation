//
//  DRPSearchDisplayController.m
//  Comment Box
//
//  Created by Jason Ederle on 8/2/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPSearchSuggestionsDisplayController.h"
#import "DRPTouchOrDragGestureRecognizer.h"

@interface DRPSearchSuggestionsDisplayController () <UISearchBarDelegate>
{
  UIView *_statusBarBackgroundView;
  UIColor *_originalViewColor;
  UIView *searchBarParentView;
  id<UISearchBarDelegate, NSObject> _searchBarDelegate;
  DRPTouchOrDragGestureRecognizer *_touchResultsRecognizer;
}
@end

@implementation DRPSearchSuggestionsDisplayController

- (id)initWithSearchBar:(UISearchBar *)searchBar viewController:(UIViewController *)viewController
{
  self = [super init];
  if (self) {
    _searchBar = searchBar;
    _viewController = viewController;
    _statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _statusBarColor = [UIColor colorWithRed:.78 green:.78 blue:.80 alpha:1];
    _touchResultsRecognizer = [[DRPTouchOrDragGestureRecognizer alloc] initWithTarget:self action:@selector(_didTapOnResultsView:)];
    
    // hijack the delegate and proxy to it
    _searchBarDelegate = _searchBar.delegate;
    _searchBar.delegate = self;
    [_searchBar addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:NULL];
  }
  return self;
}

- (void)dealloc
{
  if (_searchBar) {
    [_searchBar removeObserver:self forKeyPath:@"delegate"];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (_searchBar.delegate == self) {
    return;
  }
  _searchBarDelegate = _searchBar.delegate;
  _searchBar.delegate = self;
}

- (void)setActive:(BOOL)active
{
  if (_active == active) {
    return;
  }
  _active = active;

  if (active) {
    [_searchBar setShowsCancelButton:YES animated:YES];
    [_viewController.navigationController setNavigationBarHidden:YES animated:YES];
    [self _updateStatusBarColor:_statusBarColor];
    [self setResultsViewVisible:YES];
    [_searchBar becomeFirstResponder];
    _touchResultsRecognizer.enabled = YES;
    [self addGestureRecognizer:_touchResultsRecognizer toView:_resultsView];
  } else {
    _touchResultsRecognizer.enabled = NO;
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_viewController.navigationController setNavigationBarHidden:NO animated:YES];
    [self _updateStatusBarColor:nil];
    [self setResultsViewVisible:NO];
    [_searchBar resignFirstResponder];
  }
}

// hack to get the same behavior as a UISearchDisplayController
- (void)_forceEnableCancelButton
{
  for (UIView *parentView in _searchBar.subviews) {
    for (UIView *view in parentView.subviews) {
      if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        button.enabled = YES;
      }
    }
  }
}

- (void)setResultsViewVisible:(BOOL)visible
{
  if (visible) {
    [self _showResultsView];
  } else {
    [self _hideResultsView];
  }
  _resultsViewVisible = visible;
}

- (void)_showResultsView
{
  if (!_resultsView || _resultsViewVisible) {
    return;
  }
  
  if ([_viewController.view isKindOfClass:[UIScrollView class]]) {
    [(UIScrollView *)_viewController.view setScrollEnabled:NO];
  }
  
  CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
  CGRect tabFrame = _viewController.tabBarController.tabBar.bounds;
  CGRect barFrame = _searchBar.bounds;
  CGRect resultsFrame = CGRectMake(0,
                                   CGRectGetHeight(barFrame),
                                   CGRectGetWidth(_viewController.view.bounds),
                                   CGRectGetHeight(_viewController.view.bounds) - CGRectGetHeight(barFrame) - CGRectGetHeight(tabFrame) - CGRectGetHeight(statusFrame));
  
  _resultsView.frame = resultsFrame;
  
  if ([_delegate respondsToSelector:@selector(willShowResultsViewForSearchDisplayController:)]) {
    [_delegate willShowResultsViewForSearchDisplayController:self];
  }
  
  if (!_resultsView.superview) {
    [_viewController.view addSubview:_resultsView];
  }
}

- (void)_hideResultsView
{
  if (!_resultsView || !_resultsViewVisible) {
    return;
  }
  
  if ([_viewController.view isKindOfClass:[UIScrollView class]]) {
    [(UIScrollView *)_viewController.view setScrollEnabled:YES];
  }
  
  [_resultsView removeFromSuperview];
}

- (void)_updateStatusBarColor:(UIColor *)color
{
  if (!color) {
    [_statusBarBackgroundView removeFromSuperview];
    _viewController.view.backgroundColor = _originalViewColor;
  } else {
    if (!_originalViewColor) {
      _originalViewColor = _viewController.view.backgroundColor;
    }
    _viewController.view.backgroundColor = color;
  }
}

- (void)_didTapOnResultsView:(id)sender
{
  if (_searchBar.isFirstResponder) {
    [_searchBar resignFirstResponder];
    [self _forceEnableCancelButton];
  }
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)addRecognizer toView:(UIView *)view
{
  NSArray *recognizers = [view gestureRecognizers];
  if (!recognizers) {
    recognizers = @[];
  }
  
  for (UIGestureRecognizer *rec in recognizers) {
    if (rec == addRecognizer) {
      return;
    }
  }
  
  NSMutableArray *newRecognizers = [NSMutableArray arrayWithArray:recognizers];
  [newRecognizers addObject:addRecognizer];
  view.gestureRecognizers = newRecognizers;
}

#pragma mark Search Bar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
    return [_searchBarDelegate searchBarShouldBeginEditing:searchBar];
  }
  return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
    [_searchBarDelegate searchBarTextDidBeginEditing:searchBar];
  }
  [self setActive:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
    return [_searchBarDelegate searchBarShouldEndEditing:searchBar];
  }
  return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
    [_searchBarDelegate searchBarTextDidEndEditing:searchBar];
  }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
    [_searchBarDelegate searchBar:searchBar textDidChange:searchText];
  }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
    return [_searchBarDelegate searchBar:searchBar shouldChangeTextInRange:range replacementText:text];
  }
  return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
    [_searchBarDelegate searchBarSearchButtonClicked:searchBar];
  }
  [self setActive:NO];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
    [_searchBarDelegate searchBarBookmarkButtonClicked:searchBar];
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
    [_searchBarDelegate searchBarCancelButtonClicked:searchBar];
  }
  [self setActive:NO];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
    [_searchBarDelegate searchBarResultsListButtonClicked:searchBar];
  }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
  if ([_searchBarDelegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
    [_searchBarDelegate searchBarTextDidBeginEditing:searchBar];
  }
}

@end

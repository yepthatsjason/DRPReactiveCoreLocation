//
//  DRPWebViewController.m
//  Comment Box
//
//  Created by Jason Ederle on 9/13/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPWebViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface DRPWebViewController () <UIWebViewDelegate>
{
  UIWebView *_webView;
  NSURL *_loadURL;
  MBProgressHUD *_progressHUD;
}
@end

@implementation DRPWebViewController

- (id)initWithTitle:(NSString *)title url:(NSURL *)url
{
  self = [super init];
  if (self) {
    _loadURL = url;
    self.navigationItem.title = title;
  }
  return self;
}

- (void)loadView
{
  _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  _webView.delegate = self;
  self.view = _webView;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [_webView loadRequest:[NSURLRequest requestWithURL:_loadURL]];
}

- (void)_showProgressHUD:(BOOL)show
{
  if (show) {
    if (_progressHUD.superview) {
      return;
    }
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    _progressHUD.labelText = @"Loading\u2026";
    _progressHUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:_progressHUD];
    [_progressHUD show:YES];
  } else {
    [_progressHUD hide:YES];
  }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
  [self _showProgressHUD:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  [self _showProgressHUD:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [self _showProgressHUD:NO];
  
  NSString *failedURLString = [[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey] lowercaseString];
  
  // ignore failured loads when website tries to open a native URL
  if (![failedURLString hasPrefix:@"http"]) {
    return;
  }
  
  NSString *message = @"We failed to load this webpage. Please check your internet connection and try again";
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh Oh\u2026"
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil, nil];
  [alertView show];
}

@end

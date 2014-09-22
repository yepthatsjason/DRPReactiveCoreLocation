//
//  DRPActionSheet.m
//  Comment Box
//
//  Created by Jason Ederle on 6/6/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPActionSheet.h"
#import "DRPLogging.h"

static NSString * const kActionTitleKey = @"ActionTitle";
static NSString * const kActionHandlerKey = @"ActionHandler";
static NSString * const kCancelTitle = @"Cancel";

@interface DRPActionSheet () <UIActionSheetDelegate> {
  NSMutableArray *_options;
  BOOL _didAddCancel;
}
@end

@implementation DRPActionSheet

- (id)initWithActionSheetTitle:(NSString *)title
{
  self = [super init];
  if (self) {
    _options = [NSMutableArray array];
    _didAddCancel = NO;
    _cancelButtonTitle = kCancelTitle;
    _addCancelButton = YES;
    _actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                               delegate:self
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
  }
  return self;
}

// Add an option with a block to handle its selection
- (void)addActionSheetButton:(NSString *)title action:(DRPActionSheetOptionHandler)handler
{
  DRPRequireAndReturn(title, kDRPLogError, @"Can't add action sheet button with nil title");
  
  NSDictionary *newOptions = nil;
  if (handler) {
    newOptions = @{
                   kActionTitleKey : title,
                   kActionHandlerKey : handler
                   };
  } else {
    newOptions = @{
                   kActionTitleKey : title
                   };
  }

  [_options addObject:newOptions];
  [_actionSheet addButtonWithTitle:title];
}

// Display the action sheet hosted from a view
- (void)showActionSheetFromView:(UIView *)view
{
  DRPRequireAndReturn(view, kDRPLogError, @"Can't show action sheet from nil view");
  
  if (_addCancelButton && !_didAddCancel) {
    [self addActionSheetButton:_cancelButtonTitle action:nil];
    _actionSheet.cancelButtonIndex = _options.count - 1;
  }
  
  [_actionSheet showInView:view];
}

#pragma mark Action Sheet Delegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSDictionary *option = _options[buttonIndex];
  DRPActionSheetOptionHandler handler = option[kActionHandlerKey];
  
  if (!handler) {
    return;
  }
  
  handler();
}

@end

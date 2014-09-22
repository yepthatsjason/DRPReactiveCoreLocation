//
//  DRPActionSheet.h
//  Comment Box
//
//  Created by Jason Ederle on 6/6/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRPActionSheet;

typedef void (^DRPActionSheetOptionHandler)();

@interface DRPActionSheet : NSObject
@property (readonly, nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) BOOL addCancelButton; //default YES
@property (strong, nonatomic) NSString *cancelButtonTitle; // default "Cancel"

// Create empty action sheet with a title
- (id)initWithActionSheetTitle:(NSString *)title;

// Add an option with a block to handle its selection
- (void)addActionSheetButton:(NSString *)title action:(DRPActionSheetOptionHandler)handler;

// Display the action sheet hosted from a view
- (void)showActionSheetFromView:(UIView *)view;

@end

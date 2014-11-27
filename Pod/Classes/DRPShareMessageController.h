//
//  DRPShareMessageController.h
//  Atmosphere
//
//  Created by Jason Ederle on 9/30/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DRPShareMessageControllerStatus) {
  kDRPShareMessageControllerStatusUnknown = -1,
  kDRPShareMessageControllerStatusSent,
  kDRPShareMessageControllerStatusCancelled,
  kDRPShareMessageControllerStatusFailed
};

/**
 * This class manages sending a message through SMS or email
 * through the Apple message UI view controllers depending
 * on their availablity. A delegate is used to report the finish
 * status of the flow.
 */
@protocol DRPShareMessageControllerDelegate;
@interface DRPShareMessageController : NSObject
@property (weak, nonatomic) id<DRPShareMessageControllerDelegate> delegate;
@property (strong, nonatomic) NSString *emailToAddress;

- (id)initWithSubject:(NSString *)subject
              message:(NSString *)message
                media:(NSURL *)mediaURL
            mediaName:(NSString *)mediaName
                 host:(UIViewController *)hostingViewController;

// preset message composer, and optionally show action sheet allowing user to pick method (SMS or Email)
- (void)showMessageComposer:(BOOL)presentOptionsIfAvailable
                      title:(NSString *)actionSheetTitle;

// show SMS if available else email
- (void)showBestMessageComposer;

// email composer
- (void)showEmailMessageComposer;

// sms composer
- (void)showSMSMessagComposer;

@end

@protocol DRPShareMessageControllerDelegate

// callback with final status of the share message operation
- (void)shareMessageController:(DRPShareMessageController *)controller
                   finalStatus:(DRPShareMessageControllerStatus)status;

@end


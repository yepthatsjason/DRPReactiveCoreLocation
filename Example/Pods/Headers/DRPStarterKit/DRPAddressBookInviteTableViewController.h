//
//  DRPAddressBookInviteTableViewController.h
//  Comment Box
//
//  Created by Jason Ederle on 7/27/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DRPInviteStatus)
{
  DRPInviteStatusUnknown = -1,
  DRPInviteStatusCancelled,
  DRPInviteStatusSent,
  DRPInviteStatusFailed
};

@protocol DRPAddressBookInviteTableViewControllerDelegate;

@interface DRPAddressBookInviteTableViewController : UITableViewController
@property (weak, nonatomic) id<DRPAddressBookInviteTableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *emailSubject;

@end

@protocol DRPAddressBookInviteTableViewControllerDelegate
// callback with the final status of the invite flow
- (void)inviteViewController:(DRPAddressBookInviteTableViewController *)controller
                 finalStatus:(DRPInviteStatus)finalStatus;
@end
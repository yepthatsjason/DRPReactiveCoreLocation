//
//  DRPAddressBookInviteTableViewController.m
//  Comment Box
//
//  Created by Jason Ederle on 7/27/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPAddressBookInviteTableViewController.h"
#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>
#import <MessageUI/MessageUI.h>
#import <ECPhoneNumberFormatter/ECPhoneNumberFormatter.h>
#import "DRPLogging.h"

static const CGSize kAccessoryViewSize = {20, 20};
static NSString * const kPersonCellIdentifier = @"PersonCellIdentifier";
static const UITableViewCellStyle kCellStyle = UITableViewCellStyleSubtitle;

typedef NS_ENUM(NSInteger, DRPInviteType)
{
  kDRPInviteTypeUnknown = -1,
  kDRPInviteTypeSMS,
  kDRPInviteTypeEmail
};

@interface DRPAddressBookInviteTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
  NSArray *_people;
  APAddressBook *_addressBook;
  NSMutableDictionary *_selectedIndexPaths;
  UIImage *_checkEnabledImage;
  UIImage *_checkDisabledImage;
  MFMessageComposeViewController *_smsViewController;
  MFMailComposeViewController *_emailViewController;
  ECPhoneNumberFormatter *_phoneNumberFormatter;
  UIBarButtonItem *_sendButtonItem;
  DRPInviteType _inviteType;
}
@end

@implementation DRPAddressBookInviteTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    _selectedIndexPaths = [NSMutableDictionary dictionary];
    _checkEnabledImage = [UIImage imageNamed:@"check_enabled"];
    _checkDisabledImage = [UIImage imageNamed:@"check_disabled"];
    
    self.navigationItem.title = @"Invite Friends";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    
    _sendButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(inviteAction:)];
    
    if ([MFMessageComposeViewController canSendText]) {
      _inviteType = kDRPInviteTypeSMS;
    } else {
      _inviteType = kDRPInviteTypeEmail;
    }
    
    [self loadPeopleFromAddressBook];
  }
  return self;
}

- (NSString *)getContactTypeInfo:(APContact *)contact
{
  if (_inviteType == kDRPInviteTypeSMS) {
    if (!_phoneNumberFormatter) {
      _phoneNumberFormatter = [[ECPhoneNumberFormatter alloc] init];
    }
    return [_phoneNumberFormatter stringForObjectValue:contact.phones.firstObject];
  } else if (_inviteType == kDRPInviteTypeEmail) {
    return contact.emails.firstObject;
  } else {
    return nil;
  }
}

- (void)loadPeopleFromAddressBook
{
  _addressBook = [[APAddressBook alloc] init];
  _addressBook.fieldsMask = APContactFieldFirstName | APContactFieldLastName | APContactFieldPhones | APContactFieldEmails;
  NSMutableDictionary *discoveredUsers = [NSMutableDictionary dictionary];
  
  _addressBook.filterBlock = ^(APContact *contact) {
    if (!contact.firstName && !contact.lastName) {
      return NO;
    }
    
    if (_inviteType == kDRPInviteTypeSMS) {
      if (!contact.phones.count) {
        return NO;
      }
    } else if (_inviteType == kDRPInviteTypeEmail) {
      if (!contact.emails.count) {
        return NO;
      }
    } else {
      return NO;
    }
    
    // ignore duplicates in users address book, thanks Mobile Me.. geez
    NSString *key = [NSString stringWithFormat:@"%@ - %@ - %@",
                     contact.firstName,
                     contact.lastName,
                     [self getContactTypeInfo:contact]];
    
    if ([discoveredUsers objectForKey:key]) {
      return NO;
    }
    
    [discoveredUsers setObject:@YES forKey:key];
    
    return YES;
  };
  
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
  _addressBook.sortDescriptors = @[sortDescriptor];
  
  [_addressBook loadContacts:^(NSArray *contacts, NSError *error) {
    if (!contacts) {
      DRPLogError(@"Failed to load contents from address book");
      return;
    }
    
    _people = [contacts copy];
    [self.tableView reloadData];
  }];
}

- (void)sendSMSInvite
{
   _smsViewController = [[MFMessageComposeViewController alloc] init];
  _smsViewController.messageComposeDelegate = self;
  _smsViewController.body = _message;
  
  NSMutableArray *recipients = [NSMutableArray array];
  for (NSIndexPath *indexPath in _selectedIndexPaths.allKeys) {
    APContact *contact = _people[indexPath.row];
    [recipients addObject:contact.phones.firstObject];
  }
  
  _smsViewController.recipients = recipients;
  
  [self presentViewController:_smsViewController animated:YES completion:nil];
}

- (void)sendEmailInvite
{
  _emailViewController = [[MFMailComposeViewController alloc] init];
  _emailViewController.mailComposeDelegate = self;
  [_emailViewController setMessageBody:_message isHTML:NO];
  [_emailViewController setSubject:_emailSubject];
  
  NSMutableArray *emails = [NSMutableArray array];
  for (NSIndexPath *indexPath in _selectedIndexPaths) {
    APContact *contact = _people[indexPath.row];
    NSString *email = [self getContactTypeInfo:contact];
    if (email) {
      [emails addObject:email];
    }
  }
  
  [_emailViewController setToRecipients:emails];
  
  [self presentViewController:_emailViewController animated:YES completion:nil];
}

- (void)prepareCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
  APContact *person = _people[indexPath.row];
  NSString *firstName = person.firstName;
  NSString *lastName = person.lastName;
  NSString *fullName = nil;
  
  if (firstName && lastName) {
    fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
  } else {
    fullName = firstName ? firstName : lastName;
  }
  
  cell.textLabel.text = fullName;
  cell.detailTextLabel.text = [self getContactTypeInfo:person];

  if (![cell.accessoryView isKindOfClass:[UIImageView class]]) {
    CGRect imageFrame = CGRectMake(0, 0, kAccessoryViewSize.width, kAccessoryViewSize.height);
    cell.accessoryView = [[UIImageView alloc] initWithFrame:imageFrame];
  }
  
  if ([_selectedIndexPaths objectForKey:indexPath]) {
    [(UIImageView *)cell.accessoryView setImage:_checkEnabledImage];
  } else {
    [(UIImageView *)cell.accessoryView setImage:_checkDisabledImage];
  }
  
  [cell setNeedsLayout];
}

#pragma mark Actions

- (void)cancelAction:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)inviteAction:(id)sender
{
  if (_inviteType == kDRPInviteTypeSMS) {
    [self sendSMSInvite];
  } else if (_inviteType == kDRPInviteTypeEmail) {
    [self sendEmailInvite];
  } else {
    DRPLogError(@"Can't send invite of unknown type: %ld", _inviteType);
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _people.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonCellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:kCellStyle
                                  reuseIdentifier:kPersonCellIdentifier];
  }
  
  [self prepareCell:cell indexPath:indexPath];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static UITableViewCell *cell = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cell = [[UITableViewCell alloc] initWithStyle:kCellStyle reuseIdentifier:nil];
  });
  
  [self prepareCell:cell indexPath:indexPath];
  
  CGSize size = [cell sizeThatFits:CGSizeMake(CGRectGetWidth(self.tableView.bounds), CGFLOAT_MAX)];
  return size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // toggle the selection state
  if ([_selectedIndexPaths objectForKey:indexPath]) {
    [_selectedIndexPaths removeObjectForKey:indexPath];
  } else {
    [_selectedIndexPaths setObject:@YES forKey:indexPath];
  }
  
  if (_selectedIndexPaths.count) {
    self.navigationItem.rightBarButtonItem = _sendButtonItem;
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
  
  [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark SMS Message Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
  DRPInviteStatus status = DRPInviteStatusUnknown;
  if (result == MessageComposeResultCancelled) {
    status = DRPInviteStatusCancelled;
  } else if (result == MessageComposeResultSent) {
    status = DRPInviteStatusSent;
  } else if (result == MessageComposeResultFailed) {
    status = DRPInviteStatusFailed;
  }
  
  [_delegate inviteViewController:self finalStatus:status];
  [_smsViewController dismissViewControllerAnimated:YES completion:^{
    if (status == DRPInviteStatusSent) {
      [self dismissViewControllerAnimated:YES completion:nil];
    }
  }];
}

#pragma mark Email Message Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)erro
{
  DRPInviteStatus status = DRPInviteStatusUnknown;
  if (result == MFMailComposeResultCancelled) {
    status = DRPInviteStatusCancelled;
  } else if (result == MFMailComposeResultSent) {
    status = DRPInviteStatusSent;
  } else if (result == MFMailComposeResultFailed) {
    status = DRPInviteStatusFailed;
  } else if (result == MFMailComposeResultSaved) {
    status = DRPInviteStatusCancelled;
  }
  
  [_delegate inviteViewController:self finalStatus:status];
  [_emailViewController dismissViewControllerAnimated:YES completion:^{
    if (status == DRPInviteStatusSent) {
      [self dismissViewControllerAnimated:YES completion:nil];
    }
  }];
}

@end

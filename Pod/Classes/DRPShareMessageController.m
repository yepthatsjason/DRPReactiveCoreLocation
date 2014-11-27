//
//  DRPShareMessageController.m
//  Atmosphere
//
//  Created by Jason Ederle on 9/30/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPShareMessageController.h"
#import <MessageUI/MessageUI.h>
#import <MagicKit/MagicKit.h>
#import <DRPStarterKit/DRPActionSheet.h>
#import "DRPLogging.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface DRPShareMessageController ()
<MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate>
{
  NSString *_subject;
  NSString *_message;
  NSURL *_mediaURL;
  NSString *_mediaName;
  UIViewController *_hostingViewController;
  MFMailComposeViewController *_emailViewController;
  MFMessageComposeViewController *_smsViewController;
  DRPActionSheet *_actionSheet;
}
@end

@implementation DRPShareMessageController

- (id)initWithSubject:(NSString *)subject
              message:(NSString *)message
                media:(NSURL *)mediaURL
            mediaName:(NSString *)mediaName
                 host:(UIViewController *)hostingViewController
{
  self = [super init];
  if (self) {
    _subject = subject;
    _message = message;
    _mediaURL = mediaURL;
    _mediaName = mediaName ?: @"media";
    _hostingViewController = hostingViewController;
  }
  return self;
}

- (void)showMessageComposer:(BOOL)presentOptionsIfAvailable title:(NSString *)actionSheetTitle
{
  if (presentOptionsIfAvailable &&
      [MFMessageComposeViewController canSendText] &&
      [MFMailComposeViewController canSendMail])
  {
    __weak DRPShareMessageController *weakSelf = self;
    NSString *title = actionSheetTitle ?: @"How would you like to share this?";
    _actionSheet = [[DRPActionSheet alloc] initWithActionSheetTitle:title];
    [_actionSheet addActionSheetButton:@"Text Message" action:^{
      [weakSelf showSMSMessagComposer];
    }];
    [_actionSheet addActionSheetButton:@"Email Message" action:^{
      [weakSelf showEmailMessageComposer];
    }];
    [_actionSheet showActionSheetFromView:_hostingViewController.view];
  } else {
    [self showBestMessageComposer];
  }
}

- (void)showBestMessageComposer
{
  // choose best message sender
  if ([MFMessageComposeViewController canSendText]) {
    [self showSMSMessagComposer];
  } else if ([MFMailComposeViewController canSendMail]) {
    [self showEmailMessageComposer];
  } else {
    DRPLogDebug(@"Device isn't capable of sending txt or or email");
    [_delegate shareMessageController:self finalStatus:kDRPShareMessageControllerStatusCancelled];
  }
}

- (void)showSMSMessagComposer
{
  _smsViewController = [[MFMessageComposeViewController alloc] init];
  _smsViewController.messageComposeDelegate = self;
  _smsViewController.body = _message;
  
  if (_subject && [MFMessageComposeViewController canSendSubject]) {
    _smsViewController.subject = _subject;
  }
  
  if (_mediaURL && [MFMessageComposeViewController canSendAttachments]) {
    NSData *data = [NSData dataWithContentsOfURL:_mediaURL];
    NSString *utiType = [self _getUTITypeForData:data];
    if (!data || !utiType) {
      [_delegate shareMessageController:self finalStatus:kDRPShareMessageControllerStatusFailed];
      return;
    }
    NSString *extension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(utiType),
                                                                                        kUTTagClassFilenameExtension);
    NSString *readableFileName = [NSString stringWithFormat:@"%@.%@", _mediaName, extension];
    [_smsViewController addAttachmentData:data typeIdentifier:utiType filename:readableFileName];
  }
  
  [_hostingViewController presentViewController:_smsViewController animated:YES completion:nil];
}

- (void)showEmailMessageComposer
{
  _emailViewController = [[MFMailComposeViewController alloc] init];
  _emailViewController.mailComposeDelegate = self;
  [_emailViewController setMessageBody:_message isHTML:NO];
  [_emailViewController setSubject:_subject];
  
  if (_emailToAddress) {
    [_emailViewController setToRecipients:@[_emailToAddress]];
  }
  
  if (_mediaURL) {
    NSData *data = [NSData dataWithContentsOfURL:_mediaURL];
    NSString *mimeType = [self _getMimeTypeForData:data];
    NSString *utiType = [self _getUTITypeForData:data];
    if (!data || !mimeType) {
      [_delegate shareMessageController:self finalStatus:kDRPShareMessageControllerStatusFailed];
      return;
    }
    NSString *extension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(utiType),
                                                                                        kUTTagClassFilenameExtension);
    NSString *readableFileName = [NSString stringWithFormat:@"%@.%@", _mediaName, extension];
    [_emailViewController addAttachmentData:data mimeType:mimeType fileName:readableFileName];
  }
  
  [_hostingViewController presentViewController:_emailViewController animated:YES completion:nil];
}

- (NSString *)_getUTITypeForData:(NSData *)data
{
  if (!data) {
    return nil;
  }
  GEMagicResult *magic = [GEMagicKit magicForData:data];
  return magic.uniformType;
}

- (NSString *)_getMimeTypeForData:(NSData *)data
{
  if (!data) {
    return nil;
  }
  GEMagicResult *magic = [GEMagicKit magicForData:data];
  return magic.mimeType;
}

#pragma mark Message Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
  DRPShareMessageControllerStatus status = kDRPShareMessageControllerStatusUnknown;
  if (result == MFMailComposeResultCancelled ||
      result == MFMailComposeResultSaved)
  {
    status = kDRPShareMessageControllerStatusCancelled;
  } else if (result == MFMailComposeResultSent) {
    status = kDRPShareMessageControllerStatusSent;
  } else if (result == MFMailComposeResultFailed) {
    status = kDRPShareMessageControllerStatusFailed;
  }
  
  [_delegate shareMessageController:self finalStatus:status];
  [_emailViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
  DRPShareMessageControllerStatus status = kDRPShareMessageControllerStatusUnknown;
  if (result == MessageComposeResultCancelled) {
    status = kDRPShareMessageControllerStatusCancelled;
  } else if (result == MessageComposeResultSent) {
    status = kDRPShareMessageControllerStatusSent;
  } else if (result == MessageComposeResultFailed) {
    status = kDRPShareMessageControllerStatusFailed;
  }
  
  [_delegate shareMessageController:self finalStatus:status];
  [_smsViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

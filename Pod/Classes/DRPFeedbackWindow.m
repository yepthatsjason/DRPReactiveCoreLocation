//
//  DRPFeedbackWindow.m
//  Atmosphere
//
//  Created by Jason Ederle on 10/15/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPFeedbackWindow.h"
#import "DRPShareMessageController.h"

static NSString * const kMessageFormat = @"We noticed you were shaking %@. Would you like to report a bug or send us feedback?";

@interface DRPFeedbackWindow () <UIAlertViewDelegate>
{
  DRPShareMessageController *_shareController;
}
@end

@implementation DRPFeedbackWindow

- (id)initWithEmail:(NSString *)feedbackEmail frame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _feedbackEmail = feedbackEmail;
  }
  return self;
}

- (UIImage *)_takeScreenshot
{
  [self snapshotViewAfterScreenUpdates:NO];
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
  [self.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return img;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  [super motionEnded:motion withEvent:event];
  
  if (event.subtype == UIEventSubtypeMotionShake) {
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *msg = [NSString stringWithFormat:kMessageFormat, appName];
    UIAlertView *ask = [[UIAlertView alloc] initWithTitle:@"Shake Detected"
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Yes, I have feedback", nil];
    
    ask.delegate = self;
    [ask show];
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    [self showEmailFeedback];
  }
}

- (void)showEmailFeedback
{
  
  // capture screenshot and write to disk
  UIImage *screenshot = [self _takeScreenshot];
  NSData *data = UIImageJPEGRepresentation(screenshot, .85);
  NSString *tempDir = NSTemporaryDirectory();
  NSString *screenshotPath = [NSString stringWithFormat:@"%@/%@.jpeg", tempDir, [[NSUUID UUID] UUIDString]];
  NSURL *screenshotURL = [NSURL fileURLWithPath:screenshotPath];
  [data writeToURL:screenshotURL atomically:YES];
  
  NSString *feedbackMessage = @"Please enter feedback here:\n\n";
  
  // use share controller to send the feedback
  NSString *subject = [NSString stringWithFormat:@"%@ Feedback", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
  _shareController = [[DRPShareMessageController alloc] initWithSubject:subject
                                                                message:feedbackMessage
                                                                  media:screenshotURL
                                                              mediaName:@"screenshot.jpeg"
                                                                   host:self.rootViewController];
  
  _shareController.emailToAddress = _feedbackEmail;
  [_shareController showEmailMessageComposer];
}

#pragma mark Message Delegate


// callback with final status of the share message operation
- (void)shareMessageController:(DRPShareMessageController *)controller
                   finalStatus:(DRPShareMessageControllerStatus)status
{
  _shareController = nil;
}

@end

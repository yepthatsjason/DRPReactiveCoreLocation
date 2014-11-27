//
//  DRPFeedbackWindow.h
//  Atmosphere
//
//  Created by Jason Ederle on 10/15/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <UIKit/UIKit.h>

// Detects shake motion and triggers bug/feedback email
@interface DRPFeedbackWindow : UIWindow
@property (strong, nonatomic) NSString *feedbackEmail;

- (id)initWithEmail:(NSString *)feedbackEmail frame:(CGRect)frame;

@end
